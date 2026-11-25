import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galeria Wiki',
      home: TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final List<String> imagensDisponiveis = [
    'https://picsum.photos/id/10/600/600',
    'https://picsum.photos/id/15/600/600',
    'https://picsum.photos/id/20/600/600',
    'https://picsum.photos/id/28/600/600',
    'https://picsum.photos/id/42/600/600',
    'https://picsum.photos/id/48/600/600',
    'https://picsum.photos/id/64/600/600',
  ];

  final List<String> imagensAprovadas = [];

  Future<void> avaliarImagem(String url) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => JanelaAvaliacao(urlImagem: url),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      setState(() {
        if (!imagensAprovadas.contains(url)) {
          imagensAprovadas.add(url);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Galeria Wiki'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.photo_library),
                text: 'Galeria Wiki',
              ),
              Tab(
                icon: Icon(Icons.check_circle),
                text: 'Fotos Aprovadas',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: imagensDisponiveis.length,
              itemBuilder: (context, index) {
                final url = imagensDisponiveis[index];
                return GestureDetector(
                  onTap: () => avaliarImagem(url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            imagensAprovadas.isEmpty
                ? const Center(
                    child: Text('Nenhuma foto aprovada até o momento.'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: imagensAprovadas.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imagensAprovadas[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class JanelaAvaliacao extends StatelessWidget {
  final String urlImagem;

  const JanelaAvaliacao({super.key, required this.urlImagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Foto'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  urlImagem,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('APROVAR'),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('REPROVAR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
