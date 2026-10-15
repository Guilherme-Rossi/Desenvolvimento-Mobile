import 'dart:io';
import 'package:aula14_10/helper.dart'; // Certifique-se de que o caminho está correto para o seu projeto
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PetApp(),
    );
  }
}

class PetApp extends StatefulWidget {
  const PetApp({super.key});

  @override
  State<PetApp> createState() => _PetAppState();
}

class _PetAppState extends State<PetApp> {
  // Controladores para Aba Salvar
  final controlaNome = TextEditingController();
  final controlaIdade = TextEditingController();

  // Controladores para Aba Atualizar
  final controlaAtualizarId = TextEditingController();
  final controlaAtualizarNome = TextEditingController();
  final controlaAtualizarIdade = TextEditingController();

  // Controlador para Aba Apagar
  final controlaApagarId = TextEditingController();

  Future<void> salvarNoBanco() async {
    Map<String, dynamic> novoCao = {
      'nome': controlaNome.text,
      'dono': '', 
      'idade': int.tryParse(controlaIdade.text) ?? 0,
    };
    await DatabaseHelper.inserirCao(novoCao);
    controlaNome.clear();
    controlaIdade.clear();
    setState(() {}); 
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet salvo com sucesso!')));
  }

  Future<void> atualizarNoBanco() async {
    int id = int.tryParse(controlaAtualizarId.text) ?? 0;
    Map<String, dynamic> dadosAtualizados = {
      'nome': controlaAtualizarNome.text,
      'idade': int.tryParse(controlaAtualizarIdade.text) ?? 0,
    };
    await DatabaseHelper.atualizarCao(id, dadosAtualizados);
    controlaAtualizarId.clear();
    controlaAtualizarNome.clear();
    controlaAtualizarIdade.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet atualizado com sucesso!')));
  }

  Future<void> apagarNoBanco() async {
    int id = int.tryParse(controlaApagarId.text) ?? 0;
    await DatabaseHelper.apagarCao(id);
    controlaApagarId.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet apagado com sucesso!')));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestão de Pets'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Salvar'),
              Tab(text: 'Listar'),
              Tab(text: 'Atualizar'),
              Tab(text: 'Apagar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. Aba Salvar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: controlaNome,
                    decoration: const InputDecoration(labelText: 'Nome do pet', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controlaIdade,
                    decoration: const InputDecoration(labelText: 'Idade do pet', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: salvarNoBanco,
                    child: const Text('Salvar Pet'),
                  ),
                ],
              ),
            ),

            // 2. Aba Listar
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.buscarTodos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum pet guardado na base de dados.'));
                }

                final listaPets = snapshot.data!;
                return ListView.builder(
                  itemCount: listaPets.length,
                  itemBuilder: (context, index) {
                    final pet = listaPets[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${pet['id']}')),
                        title: Text('Nome: ${pet['nome']}'),
                        subtitle: Text('Idade: ${pet['idade']} anos'),
                      ),
                    );
                  },
                );
              },
            ),

            // 3. Aba Atualizar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: controlaAtualizarId,
                    decoration: const InputDecoration(labelText: 'ID do pet', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controlaAtualizarNome,
                    decoration: const InputDecoration(labelText: 'Novo Nome do pet', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controlaAtualizarIdade,
                    decoration: const InputDecoration(labelText: 'Nova Idade do pet', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: atualizarNoBanco,
                    child: const Text('Atualizar Pet'),
                  ),
                ],
              ),
            ),

            // 4. Aba Apagar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: controlaApagarId,
                    decoration: const InputDecoration(labelText: 'ID do pet a apagar (ver na lista)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: apagarNoBanco,
                    child: const Text('Apagar Pet'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}