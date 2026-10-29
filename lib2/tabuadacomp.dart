import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SnackBarExampleApp());

class SnackBarExampleApp extends StatelessWidget {
  const SnackBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Desafio de Multiplicação')),
        body: const Center(child: SnackBarExample()),
      ),
    );
  }
}

class SnackBarExample extends StatefulWidget {
  const SnackBarExample({super.key});

  @override
  State<SnackBarExample> createState() => _SnackBarExampleState();
}

class _SnackBarExampleState extends State<SnackBarExample> {
  final TextEditingController _controller = TextEditingController();

  int _fator = 2;
  int _multiplicador = 1;
  final int _maxMultiplicador = 10;

  @override
  void initState() {
    super.initState();
    _carregarPosicao();
  }

  // Slide 27: Carrega a posição salva
  Future<void> _carregarPosicao() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fator = prefs.getInt('fator') ?? 2;
      _multiplicador = prefs.getInt('multiplicador') ?? 1;
    });
  }

  // Slide 27: Salva a posição atual
  Future<void> _salvarPosicao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fator', _fator);
    await prefs.setInt('multiplicador', _multiplicador);
  }

  // Slide 28: Adiciona dígito de 0 a 9 e verifica automaticamente
  void _adicionarDigito(int digito) {
    setState(() {
      _controller.text += digito.toString();
    });

    final String resultadoEsperado = (_fator * _multiplicador).toString();

    // Verifica automaticamente assim que atingir a quantidade de dígitos da resposta
    if (_controller.text.length >= resultadoEsperado.length) {
      _processarResposta();
    }
  }

  void _processarResposta() {
    final int? resposta = int.tryParse(_controller.text.trim());
    _controller.clear();

    ScaffoldMessenger.of(context).clearSnackBars();

    if (resposta == (_fator * _multiplicador)) {
      setState(() {
        if (_multiplicador < _maxMultiplicador) {
          _multiplicador++;
        } else {
          _fator++;
          _multiplicador = 1;
        }
      });
      _salvarPosicao();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acertou!'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      final int fatorAnterior = _fator;
      final int multiplicadorAnterior = _multiplicador;

      setState(() {
        _fator++;
        _multiplicador = 1;
      });
      _salvarPosicao();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Errou, clique aqui para continuar.'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Continuar',
            onPressed: () {
              setState(() {
                _fator = fatorAnterior;
                _multiplicador = multiplicadorAnterior;
              });
              _salvarPosicao();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progresso = _multiplicador / _maxMultiplicador;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tabuada do $_fator (Questão $_multiplicador de $_maxMultiplicador)',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progresso,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 24),
          Text(
            'Quanto é $_fator x $_multiplicador?',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            readOnly: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Sua resposta',
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 1; i <= 9; i++)
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _adicionarDigito(i),
                      child: Text(
                        '$i',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                SizedBox(
                  width: 70,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _adicionarDigito(0),
                    child: const Text('0', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}