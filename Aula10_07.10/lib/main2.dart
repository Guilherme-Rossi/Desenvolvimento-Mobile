import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Editor Markdown',
      home: EditorMarkdown(),
    );
  }
}

class EditorMarkdown extends StatefulWidget {
  const EditorMarkdown({super.key});

  @override
  State<EditorMarkdown> createState() => _EditorMarkdownState();
}

class _EditorMarkdownState extends State<EditorMarkdown> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lerArquivo();
  }

  // 1. Criar a referência para o arquivo organiza.md[cite: 57]
  Future<File> get _arquivo async {
    final diretorio = await getApplicationDocumentsDirectory(); 
    return File('${diretorio.path}/organiza.md'); //[cite: 61]
  }

  // 2. Ler do arquivo[cite: 59]
  Future<void> _lerArquivo() async {
    try {
      final arquivo = await _arquivo;
      final conteudo = await arquivo.readAsString();
      setState(() {
        _controller.text = conteudo; 
      });
    } catch (_) {
    }
  }

  // 3. Escrever no arquivo[cite: 58]
  Future<void> _salvarTexto() async {
    final arquivo = await _arquivo;
    await arquivo.writeAsString(_controller.text); 
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arquivo organiza.md salvo com sucesso!')),
    );
  }

  // 4. Apagar arquivo/texto[cite: 61]
  Future<void> _apagarTexto() async {
    final arquivo = await _arquivo;
    
    if (await arquivo.exists()) {
      await arquivo.delete(); 
    }
    
    setState(() {
      _controller.clear(); 
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arquivo apagado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor organiza.md'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null, 
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Escreva seu texto Markdown aqui...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botão Salvar sem ícone
                ElevatedButton(
                  onPressed: _salvarTexto,
                  child: const Text('Salvar Texto'),
                ),
                // Botão Apagar sem ícone e sem a cor vermelha
                ElevatedButton(
                  onPressed: _apagarTexto,
                  child: const Text('Apagar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}