import 'package:flutter/material.dart';
import 'package:tabuada/pergunta.dart';
import 'package:tabuada/questoes.dart';

class Janela2 extends StatelessWidget {
  const Janela2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Pergunta teste1 = questoes[1];

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/imagens/palhaco_ouve.png',
                //color: const Color.fromARGB(40, 244, 67, 54),
              ),
            ),
          ),
          Text(teste1.texto),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(teste1.respostas[0]),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(teste1.respostas[1]),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(teste1.respostas[2]),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(teste1.respostas[3]),
          ),
        ],
      ),
    );
  }
}
