import 'package:flutter/material.dart';

void main() => runApp(const MeuAppGaleria());

class FotoItem {
  final String link;
  bool favorita;

  FotoItem(this.link, {this.favorita = false});
}

class MeuAppGaleria extends StatelessWidget {
  const MeuAppGaleria({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: TelaPrincipal()),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int indice = 0;

  final List<FotoItem> fotos = [
    FotoItem('https://commons.wikimedia.org/wiki/Special:FilePath/Great_Wave_off_Kanagawa2.jpg?width=200'),
    FotoItem('https://commons.wikimedia.org/wiki/Special:FilePath/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg?width=200'),
    FotoItem('https://commons.wikimedia.org/wiki/Special:FilePath/Mona_Lisa.jpg?width=200'),
    FotoItem('https://commons.wikimedia.org/wiki/Special:FilePath/Felis_catus-cat_on_snow.jpg?width=200'),
    FotoItem('https://commons.wikimedia.org/wiki/Special:FilePath/Pieter_Bruegel_the_Elder_-_The_Tower_of_Babel_%28Vienna%29_-_Google_Art_Project_-_edited.jpg?width=200'),
  ];

  void _avancar() {
    setState(() {
      indice = (indice + 1) % fotos.length;
    });
  }

  void _alternarFavorito() {
    setState(() {
      fotos[indice].favorita = !fotos[indice].favorita;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fotoAtual = fotos[indice];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            fotoAtual.link,
            width: 220,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          IconButton(
            iconSize: 36,
            color: Colors.redAccent,
            icon: Icon(fotoAtual.favorita ? Icons.favorite : Icons.favorite_border),
            onPressed: _alternarFavorito,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _avancar,
            child: const Text('Avançar'),
          ),
        ],
      ),
    );
  }
}