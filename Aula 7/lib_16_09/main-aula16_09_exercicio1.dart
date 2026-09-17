import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WikiPaisesApp());
}

class WikiPaisesApp extends StatelessWidget {
  const WikiPaisesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeria de Países',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TelaGaleria(),
    );
  }
}

class PaisImagem {
  final String titulo;
  final String url;
  final String descricao;

  PaisImagem({
    required this.titulo,
    required this.url,
    required this.descricao,
  });
}

class TelaGaleria extends StatefulWidget {
  const TelaGaleria({super.key});

  @override
  State<TelaGaleria> createState() => _TelaGaleriaState();
}

class _TelaGaleriaState extends State<TelaGaleria> {

  static const List<String> _paises = [
    'Brazil',
    'Japan',
    'France',
    'Italy',
    'Egypt',
    'Australia',
    'Canada',
    'India',
    'Mexico',
    'Norway',
    'Portugal',
    'Greece',
    'Thailand',
    'Morocco',
    'Peru',
    'Iceland',
    'Kenya',
    'Vietnam',
    'Argentina',
    'Turkey',
  ];

  final Random _random = Random();

  List<PaisImagem> _imagens = [];
  int _indiceAtual = 0;
  bool _carregando = true;
  String? _erro;

  final Set<int> _favoritas = {};

  @override
  void initState() {
    super.initState();
    _buscarImagens();
  }

  Future<void> _buscarImagens() async {
    setState(() {
      _carregando = true;
      _erro = null;
      _imagens = [];
      _favoritas.clear();
      _indiceAtual = 0;
    });

    try {
      final embaralhados = List<String>.from(_paises)..shuffle(_random);
      final selecionados = embaralhados.take(5).toList();

      final listaImagens = <PaisImagem>[];

      for (final pais in selecionados) {
        final imagem = await _buscarImagemDoPais(pais);
        if (imagem != null) {
          listaImagens.add(imagem);
        }
      }

      if (listaImagens.isEmpty) {
        throw Exception('Não foi possível carregar nenhuma imagem');
      }

      setState(() {
        _imagens = listaImagens;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }


  Future<PaisImagem?> _buscarImagemDoPais(String pais) async {
    try {
      final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php'
        '?action=query'
        '&format=json'
        '&titles=$pais'
        '&prop=pageimages|extracts'
        '&piprop=thumbnail|original|name'
        '&pithumbsize=200'
        '&exintro=1'
        '&explaintext=1'
        '&exsentences=2'
        '&origin=*',
      );

      final resposta = await http.get(url);

      if (resposta.statusCode != 200) {
        return null;
      }

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final paginas = dados['query']?['pages'] as Map<String, dynamic>?;
      if (paginas == null || paginas.isEmpty) return null;

      final pagina = paginas.values.first as Map<String, dynamic>;

     
      final thumbnail = pagina['thumbnail'] as Map<String, dynamic>?;
      final original = pagina['original'] as Map<String, dynamic>?;
      final urlImagem =
          (thumbnail?['source'] as String?) ?? (original?['source'] as String?);

      if (urlImagem == null) return null;

  
      String descricao = 'País: $pais';
      final extract = pagina['extract'] as String?;
      if (extract != null && extract.isNotEmpty) {
        descricao = extract.trim();
      }

      final titulo = (pagina['title'] as String?) ?? pais;

      return PaisImagem(
        titulo: titulo,
        url: urlImagem,
        descricao: descricao,
      );
    } catch (_) {
      return null;
    }
  }

  void _toggleFavorito() {
    setState(() {
      if (_favoritas.contains(_indiceAtual)) {
        _favoritas.remove(_indiceAtual);
      } else {
        _favoritas.add(_indiceAtual);
      }
    });
  }

  void _proximaImagem() {
    if (_imagens.isEmpty) return;
    setState(() {
      _indiceAtual = (_indiceAtual + 1) % _imagens.length;
    });
  }

  void _imagemAnterior() {
    if (_imagens.isEmpty) return;
    setState(() {
      _indiceAtual = (_indiceAtual - 1 + _imagens.length) % _imagens.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 Galeria de Países'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Buscar novos países',
            onPressed: _carregando ? null : _buscarImagens,
          ),
        ],
      ),
      body: _buildCorpo(),
    );
  }

  Widget _buildCorpo() {

    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando países da Wikipedia...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Algo deu errado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _buscarImagens,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_imagens.isEmpty) {
      return const Center(child: Text('Nenhuma imagem encontrada.'));
    }

    final pais = _imagens[_indiceAtual];
    final isFavorita = _favoritas.contains(_indiceAtual);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
     
          Text(
            'País ${_indiceAtual + 1} de ${_imagens.length}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

     
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
               
                Image.network(
                  pais.url,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    final total = progress.expectedTotalBytes;
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: total != null
                              ? progress.cumulativeBytesLoaded / total
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),

              
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pais.titulo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pais.descricao,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _toggleFavorito,
            icon: Icon(
              isFavorita ? Icons.favorite : Icons.favorite_border,
              color: isFavorita ? Colors.red : null,
            ),
            label: Text(
              isFavorita ? 'País favoritado!' : 'Marcar como gostei',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isFavorita ? Colors.pink.shade50 : null,
              foregroundColor: isFavorita ? Colors.pink.shade700 : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                onPressed: _imagemAnterior,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'País anterior',
              ),
              IconButton.filledTonal(
                onPressed: _proximaImagem,
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'Próximo país',
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '${_favoritas.length} país(es) marcado(s) como favorito(s)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
