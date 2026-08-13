import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int x = Random().nextInt(5) + 1;
  String c = "";
  int um = 1;
  int dois = 2;
  int tres = 3;
  int quatro = 4;
  int cinco = 5;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imagens/images.jpg',
                height: 200,
              ),
              const Text('Charlie Chaplin'),
              const Text('Ator e Comediante'),
              Text('Acerte o numero: $c '),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 28.0),
                    ),
                    onPressed: () {
                      setState(() {
                        if (um == x) {
                          print('Acertou');
                          c = "Acertou";
                        }
                      });
                    },
                    child: Text('1'),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 28.0),
                    ),
                    onPressed: () {
                      setState(() {
                        if (dois == x) {
                          print('Acertou');
                          c = "Acertou";
                        }
                      });
                    },
                    child: Text('2'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color.fromRGBO(218, 10, 10, 1),
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 28.0),
                    ),
                    onPressed: () {
                      setState(() {
                        if (tres == x) {
                          print('Acertou');
                          c = "Acertou";
                        }
                      });
                    },
                    child: Text('3'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 46, 13, 231),
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 28.0),
                    ),
                    onPressed: () {
                      setState(() {
                        if (quatro == x) {
                          print('Acertou');
                          c = "Acertou";
                        }
                      });
                    },
                    child: Text('4'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 169, 255, 8),
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 28.0),
                    ),
                    onPressed: () {
                      setState(() {
                        if (cinco == x) {
                          print('Acertou');
                          c = "Acertou";
                        }
                      });
                    },
                    child: Text('5'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
