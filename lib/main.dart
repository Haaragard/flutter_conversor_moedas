import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?format=json&key=";

Future main() async {
  await DotEnv().load('.env');

  print(await _getData());
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
                  final double dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  final double euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return Container(color: Colors.green,);
                }
            }
          }
      ),
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





