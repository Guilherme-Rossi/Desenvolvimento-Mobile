import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const JogoMatematicaApp());

class JogoMatematicaApp extends StatelessWidget {
  const JogoMatematicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: TelaMatematica()),
    );
  }
}

class TelaMatematica extends StatefulWidget {
  const TelaMatematica({super.key});

  @override
  State<TelaMatematica> createState() => _TelaMatematicaState();
}

class _TelaMatematicaState extends State<TelaMatematica> {
  final _campoController = TextEditingController();
  final _gerador = Random();
  
  late int fatorA;
  late int fatorB;
  String valorDigitado = '';

  @override
  void initState() {
    super.initState();
    _sortearNumeros();
  }

  void _sortearNumeros() {
    fatorA = _gerador.nextInt(10) + 1;
    fatorB = _gerador.nextInt(10) + 1;
  }

  void _resetarJogo() {
    setState(() {
      _sortearNumeros();
      valorDigitado = '';
      _campoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultadoCerto = fatorA * fatorB;
    final tentativa = int.tryParse(valorDigitado);
    final exato = tentativa == resultadoCerto;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$fatorA vezes $fatorB é?',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                padding: const EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _campoController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (texto) => setState(() => valorDigitado = texto),
                ),
              ),
              if (valorDigitado.isNotEmpty)
                Icon(
                  exato ? Icons.thumb_up : Icons.error,
                  color: exato ? Colors.green : Colors.redAccent,
                  size: 30,
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
          ),
          ElevatedButton.icon(
            onPressed: _resetarJogo,
            icon: const Icon(Icons.refresh),
            label: const Text('Sortear Novamente'),
          ),
        ],
      ),
    );
  }
}