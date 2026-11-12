import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  bool logado = prefs.getBool('isLoggedIn') ?? false;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Twitter Clone',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.blue, foregroundColor: Colors.white),
    ),
    home: logado ? const HomePage() : const LoginScreen(),
  ));
}

// ================= TELA DE LOGIN =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String _mensagem = "";
  bool _carregando = false;

  Future<void> _fazerLogin() async {
    setState(() {
      _carregando = true;
      _mensagem = "";
    });

    final url = Uri.parse('http://10.0.2.2/twitter_app/login.php');
    
    try {
      final response = await http.post(url, body: {
        'email': _emailController.text,
        'senha': _senhaController.text,
      });

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        if (dados['sucesso'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('email', _emailController.text);
          await prefs.setString('nome', dados['nome'] ?? 'Usuário'); 

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          setState(() => _mensagem = dados['mensagem']);
        }
      }
    } catch (e) {
      setState(() => _mensagem = "Erro de conexão com o servidor.");
    }

    setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _senhaController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: _carregando ? null : _fazerLogin,
              child: _carregando ? const Text('Entrando...') : const Text('Entrar'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroScreen())),
              child: const Text('Não tem conta? Cadastre-se aqui'),
            ),
            const SizedBox(height: 20),
            Text(_mensagem, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ================= TELA DE CADASTRO =================
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String _mensagem = "";
  bool _carregando = false;

  Future<void> _cadastrar() async {
    setState(() { _carregando = true; _mensagem = ""; });
    final url = Uri.parse('http://10.0.2.2/twitter_app/cadastro.php');
    try {
      final response = await http.post(url, body: {
        'nome': _nomeController.text, 'email': _emailController.text, 'senha': _senhaController.text,
      });
      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        setState(() => _mensagem = dados['mensagem']);
      }
    } catch (e) {
      setState(() => _mensagem = "Erro de conexão.");
    }
    setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _senhaController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder())),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: _carregando ? null : _cadastrar,
              child: _carregando ? const Text('Cadastrando...') : const Text('Cadastrar'),
            ),
            const SizedBox(height: 20),
            Text(_mensagem, textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ================= TELA PRINCIPAL (COM 3 ABAS) =================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indiceAba = 1; // Inicia na Timeline

  Future<void> _sair() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twitter Clone'),
        actions: [ IconButton(icon: const Icon(Icons.logout), onPressed: _sair) ],
      ),
      body: IndexedStack(
        index: _indiceAba,
        children: const [
          EnviarTab(),
          TimelineTab(),
          BuscaTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAba,
        onTap: (index) => setState(() => _indiceAba = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Postar'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Timeline'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        ],
      ),
    );
  }
}

// ABA 1: POSTAGEM (Foto agora é opcional)
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

  Future<void> _removerFoto() async {
    setState(() => _imagem = null);
  }

  Future<void> _enviarDados() async {
    // Validação: Exige pelo menos a foto OU o texto
    if (_imagem == null && _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escreva algo ou adicione uma foto!')));
      return;
    }
    
    setState(() => _enviando = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String autor = prefs.getString('nome') ?? 'Desconhecido';

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload_galeria.php'));
      request.fields['descricao'] = _descController.text;
      request.fields['autor'] = autor; // Envia o nome de quem postou
      
      // Só anexa a imagem se o utilizador tirou foto
      if (_imagem != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', _imagem!.path));
      }
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);

      if (response.statusCode == 200 && json.containsKey('sucesso')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json['sucesso'])));
          setState(() { _imagem = null; _descController.clear(); });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao postar: $e')));
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
          TextField(
            controller: _descController,
            decoration: const InputDecoration(hintText: 'O que está acontecendo?', border: OutlineInputBorder()),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          if (_imagem != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 200, width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_imagem!, fit: BoxFit.cover)),
                ),
                IconButton(icon: const Icon(Icons.cancel, color: Colors.red, size: 30), onPressed: _removerFoto),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _tirarFoto, 
                icon: const Icon(Icons.camera_alt, color: Colors.blue), 
                label: const Text('Foto (Opcional)')
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: _enviando ? null : _enviarDados,
                child: _enviando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Postar'),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ABA 2: TIMELINE (Feed com curtidas, comentários e amizade)
class TimelineTab extends StatefulWidget {
  const TimelineTab({super.key});
  @override
  State<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends State<TimelineTab> {
  final String _baseUrl = "http://10.0.2.2/maritaca";
  List<dynamic> _postagens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFeed();
  }

  Future<void> _carregarFeed() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/buscar_galeria.php'));
      if (response.statusCode == 200) {
        setState(() {
          _postagens = jsonDecode(utf8.decode(response.bodyBytes));
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  void _mostrarAviso(String acao) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$acao será implementado no PHP!')));
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    if (_postagens.isEmpty) return const Center(child: Text("Nenhuma postagem na timeline."));

    return RefreshIndicator(
      onRefresh: _carregarFeed,
      child: ListView.builder(
        itemCount: _postagens.length,
        itemBuilder: (context, index) {
          final post = _postagens[index];
          // Trata caso o backend antigo não retorne autor
          final autor = post['autor'] ?? 'Usuário'; 
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 10),
                      Text(autor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.blue),
                        tooltip: 'Solicitar Amizade',
                        onPressed: () => _mostrarAviso("Sistema de Amizade"),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(post['descricao'], style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 10),
                  if (post['caminho'] != null && post['caminho'].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network('$_baseUrl/${post['caminho']}', fit: BoxFit.cover, width: double.infinity, height: 200),
                    ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.favorite_border, color: Colors.grey),
                        label: const Text('Curtir', style: TextStyle(color: Colors.grey)),
                        onPressed: () => _mostrarAviso("Sistema de Curtidas"),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.comment, color: Colors.grey),
                        label: const Text('Comentar', style: TextStyle(color: Colors.grey)),
                        onPressed: () => _mostrarAviso("Sistema de Comentários"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ABA 3: BUSCA
class BuscaTab extends StatefulWidget {
  const BuscaTab({super.key});
  @override
  State<BuscaTab> createState() => _BuscaTabState();
}

class _BuscaTabState extends State<BuscaTab> {
  final TextEditingController _buscaController = TextEditingController();

  void _realizarBusca() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A busca no banco de dados será implementada na próxima etapa!'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              labelText: 'Buscar pessoas ou postagens',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _realizarBusca),
            ),
            onSubmitted: (_) => _realizarBusca(),
          ),
          const Spacer(),
          const Icon(Icons.search, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Procure por amigos ou conteúdo', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Spacer(),
        ],
      ),
    );
  }
}