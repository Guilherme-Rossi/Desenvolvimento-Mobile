import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trabalho Final',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indiceAba = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria e Descrição'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _indiceAba == 0 ? const EnviarTab() : const VisualizarTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAba,
        onTap: (index) => setState(() => _indiceAba = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: 'Enviar Foto'),
          BottomNavigationBarItem(icon: Icon(Icons.view_carousel), label: 'Ver Galeria'),
        ],
      ),
    );
  }
}

// ABA 1: Enviar
class EnviarTab extends StatefulWidget {
  const EnviarTab({super.key});
  @override
  State<EnviarTab> createState() => _EnviarTabState();
}

class _EnviarTabState extends State<EnviarTab> {
  File? _imagem;
  final TextEditingController _descController = TextEditingController();
  bool _enviando = false;
  final String _baseUrl = "http://10.0.2.2/maritaca";

  Future<void> _tirarFoto() async {
    final XFile? foto = await ImagePicker().pickImage(source: ImageSource.camera);
    if (foto != null) setState(() => _imagem = File(foto.path));
  }

  Future<void> _enviarDados() async {
    if (_imagem == null || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tire a foto e digite a descrição!')));
      return;
    }
    
    setState(() => _enviando = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload_galeria.php'));
      request.fields['descricao'] = _descController.text;
      request.files.add(await http.MultipartFile.fromPath('foto', _imagem!.path));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);

      if (response.statusCode == 200 && json.containsKey('sucesso')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json['sucesso'])));
          setState(() {
            _imagem = null;
            _descController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 250, width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey)),
            child: _imagem != null ? Image.file(_imagem!, fit: BoxFit.cover) : const Center(child: Text('Sem foto')),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _tirarFoto, icon: const Icon(Icons.camera), label: const Text('Tirar Foto')),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Descrição da foto', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _enviando ? null : _enviarDados,
              icon: _enviando 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.upload),
              label: const Text('Salvar no BD e Servidor'),
            ),
          )
        ],
      ),
    );
  }
}

// ABA 2: Mostrar uma por vez
class VisualizarTab extends StatefulWidget {
  const VisualizarTab({super.key});
  @override
  State<VisualizarTab> createState() => _VisualizarTabState();
}

class _VisualizarTabState extends State<VisualizarTab> {
  final String _baseUrl = "http://10.0.2.2/maritaca";
  List<dynamic> _fotos = [];
  int _indiceAtual = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFotos();
  }

  Future<void> _carregarFotos() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/buscar_galeria.php'));
      if (response.statusCode == 200) {
        setState(() {
          _fotos = jsonDecode(utf8.decode(response.bodyBytes));
          _indiceAtual = 0;
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    if (_fotos.isEmpty) return const Center(child: Text("Nenhuma foto no banco de dados."));

    final itemAtual = _fotos[_indiceAtual];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Foto ${_indiceAtual + 1} de ${_fotos.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 300, width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Image.network('$_baseUrl/${itemAtual['caminho']}', fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(itemAtual['descricao'], style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _indiceAtual > 0 ? () => setState(() => _indiceAtual--) : null,
                child: const Text('Anterior'),
              ),
              ElevatedButton(
                onPressed: _indiceAtual < _fotos.length - 1 ? () => setState(() => _indiceAtual++) : null,
                child: const Text('Próxima'),
              ),
            ],
          )
        ],
      ),
    );
  }
}