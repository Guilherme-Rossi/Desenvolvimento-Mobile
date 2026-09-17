import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TreinoTabuadaApp());
}

class TreinoTabuadaApp extends StatelessWidget {
  const TreinoTabuadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino de Tabuada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TelaTabuada(),
    );
  }
}

class TelaTabuada extends StatefulWidget {
  const TelaTabuada({super.key});

  @override
  State<TelaTabuada> createState() => _TelaTabuadaState();
}

class _TelaTabuadaState extends State<TelaTabuada> {
  final Random _random = Random();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late int _numero1;
  late int _numero2;

  int _acertos = 0;
  int _erros = 0;

  @override
  void initState() {
    super.initState();
    _gerarNovaOperacao();
    _controller.addListener(_validarResposta);
  }

  @override
  void dispose() {
    _controller.removeListener(_validarResposta);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _gerarNovaOperacao() {
    _numero1 = _random.nextInt(10) + 1; 
    _numero2 = _random.nextInt(10) + 1; 
    _controller.clear();
  }

  int get _resultadoCorreto => _numero1 * _numero2;
  bool? get _statusResposta {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return null;

    final valor = int.tryParse(texto);
    if (valor == null) return false;

    return valor == _resultadoCorreto;
  }

  void _validarResposta() {
    
    if (_statusResposta == true) {
      setState(() => _acertos++);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _gerarNovaOperacao();
        });
        _focusNode.requestFocus();
      });
    } else {
      
      setState(() {});
    }
  }

  void _contarErro() {
    if (_statusResposta == false) {
      setState(() => _erros++);
    }
  }

  Widget _buildFeedbackIcon() {
    final status = _statusResposta;

    if (status == null) {
      return const Icon(
        Icons.help_outline,
        size: 48,
        color: Colors.grey,
      );
    }

    if (status) {
      return const Icon(
        Icons.check_circle,
        size: 48,
        color: Colors.green,
        key: ValueKey('correto'),
      );
    }

    return const Icon(
      Icons.cancel,
      size: 48,
      color: Colors.red,
      key: ValueKey('incorreto'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino de Tabuada'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPlacar(
                    icone: Icons.check_circle,
                    cor: Colors.green,
                    valor: _acertos,
                    rotulo: 'Acertos',
                  ),
                  _buildPlacar(
                    icone: Icons.cancel,
                    cor: Colors.red,
                    valor: _erros,
                    rotulo: 'Erros',
                  ),
                ],
              ),
              const SizedBox(height: 40),

            
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Text(
                    '$_numero1 × $_numero2 = ?',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

             
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        hintText: '?',
                        hintStyle: const TextStyle(fontSize: 32),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onSubmitted: (_) => _contarErro(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildFeedbackIcon(),
                  ),
                ],
              ),
              const SizedBox(height: 40),

           
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      setState(_gerarNovaOperacao);
                      _focusNode.requestFocus();
                    },
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Pular'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _acertos = 0;
                        _erros = 0;
                        _gerarNovaOperacao();
                      });
                      _focusNode.requestFocus();
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reiniciar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlacar({
    required IconData icone,
    required Color cor,
    required int valor,
    required String rotulo,
  }) {
    return Column(
      children: [
        Icon(icone, color: cor, size: 32),
        const SizedBox(height: 4),
        Text(
          '$valor',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          rotulo,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
