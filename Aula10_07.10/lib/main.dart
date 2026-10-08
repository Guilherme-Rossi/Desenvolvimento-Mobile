import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController cepController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  // Variáveis para guardar o estado na interface
  String ruaSalva = '';
  String bairroSalvo = '';
  String cidadeSalva = '';
  String estadoSalvo = '';
  String cepSalvo = '';
  String numeroSalvo = '';

  bool carregando = false;
  String mensagemErro = '';

  @override
  void initState() {
    super.initState();
    carregarDados(); // Carrega os dados na próxima inicialização da APP
  }

  // Função para carregar os dados guardados no SharedPreferences
  void carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      cepSalvo = prefs.getString('cep') ?? '';
      numeroSalvo = prefs.getString('numero') ?? '';
      ruaSalva = prefs.getString('rua') ?? '';
      bairroSalvo = prefs.getString('bairro') ?? '';
      cidadeSalva = prefs.getString('cidade') ?? '';
      estadoSalvo = prefs.getString('estado') ?? '';

      // Se houver dados guardados, preenche os campos de texto para facilitar
      if (cepSalvo.isNotEmpty) cepController.text = cepSalvo;
      if (numeroSalvo.isNotEmpty) numeroController.text = numeroSalvo;
    });
  }

  // Função para buscar o CEP e guardar os dados
  Future<void> buscarESalvar() async {
    if (cepController.text.isEmpty || numeroController.text.isEmpty) {
      setState(() {
        mensagemErro = 'Preencha o CEP e o número da casa.';
      });
      return;
    }

    setState(() {
      carregando = true;
      mensagemErro = '';
    });

    final cepLimpo = cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      final resposta = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
        headers: {'Accept': 'application/json'},
      );

      if (resposta.statusCode == 200) {
        final json = jsonDecode(resposta.body) as Map<String, dynamic>;
        
        if (json.containsKey('erro')) {
          setState(() {
            mensagemErro = 'CEP não encontrado.';
            carregando = false;
          });
          return;
        }

        // Se encontrou, guarda os dados usando shared_preferences[cite: 34]
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cep', json['cep'] ?? '');
        await prefs.setString('numero', numeroController.text);
        await prefs.setString('rua', json['logradouro'] ?? '');
        await prefs.setString('bairro', json['bairro'] ?? '');
        await prefs.setString('cidade', json['localidade'] ?? '');
        await prefs.setString('estado', json['uf'] ?? '');

        // Atualiza a interface com os dados recém-guardados
        carregarDados();
      } else {
        setState(() {
          mensagemErro = 'Falha ao buscar CEP.';
        });
      }
    } catch (e) {
      setState(() {
        mensagemErro = 'Erro de ligação. Tente novamente.';
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  // Permite que o utilizador apague os dados salvos[cite: 34]
  void apagarDados() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove as chaves guardadas[cite: 28]
    await prefs.remove('cep');
    await prefs.remove('numero');
    await prefs.remove('rua');
    await prefs.remove('bairro');
    await prefs.remove('cidade');
    await prefs.remove('estado');

    setState(() {
      cepSalvo = '';
      numeroSalvo = '';
      ruaSalva = '';
      bairroSalvo = '';
      cidadeSalva = '';
      estadoSalvo = '';
      cepController.clear();
      numeroController.clear();
      mensagemErro = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Busca CEP e Morada',
      home: Scaffold(
        appBar: AppBar(title: const Text('O Meu Endereço')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: cepController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Digite o CEP',
                  hintText: 'Ex: 14780-000',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numeroController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número da Casa',
                  hintText: 'Ex: 123',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              
              if (mensagemErro.isNotEmpty)
                Text(mensagemErro, style: const TextStyle(color: Colors.red)),
                
              const SizedBox(height: 12),
              
              ElevatedButton(
                onPressed: carregando ? null : buscarESalvar,
                child: carregando
                    ? const CircularProgressIndicator()
                    : const Text('Buscar e Salvar'),
              ),
              const SizedBox(height: 12),
              
              ElevatedButton(
                onPressed: apagarDados,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apagar Dados Salvos'),
              ),
              
              const Divider(height: 40, thickness: 2),
              
              const Text(
                'Endereço Guardado:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              if (cepSalvo.isNotEmpty)
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CEP: $cepSalvo', style: const TextStyle(fontSize: 16)),
                        Text('Rua: $ruaSalva, Nº $numeroSalvo', style: const TextStyle(fontSize: 16)),
                        Text('Bairro: $bairroSalvo', style: const TextStyle(fontSize: 16)),
                        Text('Cidade: $cidadeSalva - $estadoSalvo', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                const Text('Nenhum endereço guardado no momento.'),
            ],
          ),
        ),
      ),
    );
  }
}