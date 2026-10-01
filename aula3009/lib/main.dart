import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Função que busca na API ViaCEP
Future<Endereco> buscaCep(String cep) async {
  // Limpa o CEP, remove traço e espaços
  final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

  final resposta = await http.get(
    Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode == 200) {
    final json = jsonDecode(resposta.body) as Map<String, dynamic>;
    // ViaCEP retorna {"erro": true} quando não encontra
    if (json.containsKey('erro')) {
      throw Exception('CEP não encontrado.');
    }
    return Endereco.fromJson(json);
  } else {
    throw Exception('Falha ao buscar CEP.');
  }
}

// 2. Modelo do endereço
class Endereco {
  final String logradouro; // rua
  final String bairro;
  final String localidade; // cidade
  final String uf; // estado
  final String cep;

  const Endereco({
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.cep,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      logradouro: json['logradouro'] ?? '',
      bairro: json['bairro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      cep: json['cep'] ?? '',
    );
  }
}

// 3. App
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController cepController = TextEditingController();
  Future<Endereco>? enderecoFuturo;

  void buscar() {
    if (cepController.text.isEmpty) return;
    setState(() {
      enderecoFuturo = buscaCep(cepController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busca CEP',
      home: Scaffold(
        appBar: AppBar(title: const Text('Busca CEP - ViaCEP')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: cepController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Digite o CEP',
                  hintText: 'Ex: 14780-000',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => buscar(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: buscar,
                child: const Text('Buscar'),
              ),
              const SizedBox(height: 24),
              if (enderecoFuturo != null)
                FutureBuilder<Endereco>(
                  future: enderecoFuturo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Carregando...');
                    } else if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final e = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CEP: ${e.cep}'),
                          Text('Rua: ${e.logradouro}'),
                          Text('Bairro: ${e.bairro}'),
                          Text('Cidade: ${e.localidade}'),
                          Text('Estado: ${e.uf}'),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
