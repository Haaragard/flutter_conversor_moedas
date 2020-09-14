import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?format=json&key=";

Future main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Conversor de moedas",
      theme: _theme(),
      home: Home(),
    );
  }
}

ThemeData _theme() {
  return ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber)
        ),
        hintStyle: TextStyle(color: Colors.amber),
      )
  );
}

Future<Map> _getData() async {
  http.Response response = await http.get(request + DotEnv().env['API_KEY']);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _realController = TextEditingController();
  final TextEditingController _dolarController = TextEditingController();
  final TextEditingController _euroController = TextEditingController();

  double _real;
  double _dolar;
  double _euro;

  void _realChanged(String text) {
    double real = double.tryParse(text);
    if (real != null) {
      _dolarController.text = (real/_dolar).toStringAsFixed(2);
      _euroController.text = (real/_euro).toStringAsFixed(2);
    } else _clearFields();
  }

  void _dolarChanged(String text) {
    double dolar = double.tryParse(text);
    if (dolar != null) {
      _realController.text = (dolar * this._dolar).toStringAsFixed(2);
      _euroController.text = ((dolar * this._dolar) / this._euro).toStringAsFixed(2);
    } else _clearFields();
  }

  void _euroChanged(String text) {
    double euro = double.tryParse(text);
    if (euro != null) {
      _realController.text = (euro * this._euro).toStringAsFixed(2);
      _dolarController.text = ((euro * this._euro) / this._dolar).toStringAsFixed(2);
    } else _clearFields();
  }

  _clearFields() {
    _realController.text = _dolarController.text = _euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("\$ Conversor \$",
        style: TextStyle(color: Colors.white),
      ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: _getData(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none:
                return LoadingData();
              case ConnectionState.waiting:
                return LoadingData();
              default:
                if (snapshot.hasError) {
                  return ErrorLoadingData();
                } else {
                  this._dolar =
                    snapshot.data["results"]["currencies"]["USD"]["buy"];
                  this._euro =
                    snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return _buildConversorBody();
                }
            }
          }
      ),
    );
  }

  Widget _buildConversorBody() {
    return ListView(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      children: <Widget>[
        Icon(Icons.monetization_on, size: 150.0, color: Colors.amber,),

        // Reais
        buildTextField("Reais", "R\$ ", _realController, _realChanged),

        Divider(),

        // Dolares
        buildTextField("Dólares", "US\$ ", _dolarController, _dolarChanged),

        Divider(),

        // Euros
        buildTextField("Euros", "€ ", _euroController, _euroChanged),

      ],
    );
  }
}

class LoadingData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Carregando dados...",
        style: TextStyle(color: Colors.amber, fontSize: 25.0),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ErrorLoadingData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Erro ao carregar dados ;(",
        style: TextStyle(color: Colors.amber, fontSize: 25.0),
        textAlign: TextAlign.center,
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function onChanged) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: "$label",
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      prefixText: "$prefix",
    ),
    keyboardType: TextInputType.number,
  );
}