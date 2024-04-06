import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController textEditingControllera = TextEditingController();
  TextEditingController textEditingControllerb = TextEditingController();
  double result = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              TextField(controller: textEditingControllera),
              TextField(controller: textEditingControllerb),
              ElevatedButton(onPressed: onPressed, child: Text("Press me")),
              Text("results:" + result.toString())
            ]),
          ),
        ),
      ),
    );
  }

  void onPressed() {
    double a = double.parse(textEditingControllera.text);
    double b = double.parse(textEditingControllerb.text);
    result = a + b;
    setState(() {
      
    });
  }
}
