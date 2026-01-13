import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=63063936";

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    ),
  );
}

Future<Map<String, dynamic>> getData() async {
  final response = await http.get(Uri.parse(request));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Erro ao carregar dados");
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0.0;
  double euro = 0.0;

  void _realChange (String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
  double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChange (String text){

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }
  void _euroChange (String text){

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text(
                "Carregando dados...",
                style: TextStyle(color: Colors.white, fontSize: 25),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Erro ao carregar dados",
                style: TextStyle(color: Colors.white, fontSize: 25),
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data!;
          dolar = data["results"]["currencies"]["USD"]["buy"];
          euro = data["results"]["currencies"]["EUR"]["buy"];

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.monetization_on, size: 150, color: Colors.amber),

                buildTextField("Real", "R\$", realController, _realChange),
                Divider(),
                buildTextField("Dólar", "US\$", dolarController, _dolarChange),
                Divider(),
                buildTextField("Euro", "€", euroController, _euroChange),
              ],
            ),
          );

        },
      ),
    );
  }
}




Widget buildTextField(
    String label,
    String prefix,
    TextEditingController controlador,
    void Function(String) mudar,
    ) {
  return TextField(
    controller: controlador, // ✅ ESSENCIAL
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.white, fontSize: 25),
    keyboardType: TextInputType.number,
    onChanged: mudar,
  );
}
