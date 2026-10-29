
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controlador = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  int fator = 1;
  int multiplicador = 1;
  bool aguardando = false;

  void verificar() {
    if (aguardando) return;

    int? resposta = int.tryParse(controlador.text);

    if (resposta == null) {
      mostrarMensagem('Digite um número válido!');
      return;
    }

    if (resposta == fator * multiplicador) {
      setState(() {
        controlador.clear();

        if (multiplicador < 10) {
          multiplicador++;
        } else {
          proximoFator();
        }
      });
    } else {
      setState(() {
        aguardando = true;
      });

      final fatorErro = fator;
      bool continuarMesmoFator = false;

      final messenger = messengerKey.currentState!;

      messenger.hideCurrentSnackBar();

      final controle = messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Errou, clique aqui para continuar.',
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Continuar',
            onPressed: () {
              continuarMesmoFator = true;
              setState(() {
                fator = fatorErro;
                multiplicador = 1;
                controlador.clear();
                aguardando = false;
              });
            },
          ),
        ),
      );

      controle.closed.then((_) {
        if (!mounted || continuarMesmoFator) return;

        setState(() {
          proximoFator();
          controlador.clear();
          aguardando = false;
        });
      });
    }
  }

  void proximoFator() {
    fator++;

    if (fator > 10) {
      fator = 1;
    }

    multiplicador = 1;
  }

  void mostrarMensagem(String mensagem) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Jogo da Tabuada'),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tabuada do $fator',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  '$fator x $multiplicador = ?',
                  style: const TextStyle(fontSize: 30),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: controlador,
                  keyboardType: TextInputType.number,
                  enabled: !aguardando,
                  decoration: const InputDecoration(
                    hintText: 'Digite o resultado',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: aguardando ? null : verificar,
                  child: const Text('Verificar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
