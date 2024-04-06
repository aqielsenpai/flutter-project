import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String myName = "";
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("My App"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
            Text("Welcome to Flutter"),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: TextField(
                controller: textEditingController,
              ),
            ),
            ElevatedButton(onPressed: onPressed, child: Text("PRESS ME")),
            Text(myName),

          ]),
        ),
      ),
    );
  }

  void onPressed() {
    myName = textEditingController.text;
    print(myName);
    setState(() {
      
    });
  }
}
