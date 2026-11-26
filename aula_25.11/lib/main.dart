import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const AtividadesApp());
}

class AtividadesApp extends StatelessWidget {
  const AtividadesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diário de Atividades',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AtividadesPage(),
    );
  }
}

class AtividadesPage extends StatefulWidget {
  const AtividadesPage({super.key});

  @override
  State<AtividadesPage> createState() => _AtividadesPageState();
}

class _AtividadesPageState extends State<AtividadesPage> {
  final String _baseUrl = Platform.isAndroid
      ? "http://10.0.2.2/atividades_app"
      : "http://localhost/atividades_app";

  final TextEditingController _atividadeController = TextEditingController();

  DateTime? _dataSelecionada = DateTime.now();
  int _mesFiltro = DateTime.now().month;
  int _anoFiltro = DateTime.now().year;

  List<dynamic> _atividades = [];
  bool _carregando = false;
  bool _salvando = false;

  final _meses = [
    {'valor': 1, 'nome': 'Janeiro'},
    {'valor': 2, 'nome': 'Fevereiro'},
    {'valor': 3, 'nome': 'Março'},
    {'valor': 4, 'nome': 'Abril'},
    {'valor': 5, 'nome': 'Maio'},
    {'valor': 6, 'nome': 'Junho'},
    {'valor': 7, 'nome': 'Julho'},
    {'valor': 8, 'nome': 'Agosto'},
    {'valor': 9, 'nome': 'Setembro'},
    {'valor': 10, 'nome': 'Outubro'},
    {'valor': 11, 'nome': 'Novembro'},
    {'valor': 12, 'nome': 'Dezembro'},
  ];

  final List<int> _anos = [2024, 2025, 2026];

  @override
  void initState() {
    super.initState();
    _buscarAtividades();
  }

  @override
  void dispose() {
    _atividadeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _dataSelecionada = pickedDate;
      });
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _buscarAtividades() async {
    setState(() => _carregando = true);

    try {
      final url = Uri.parse(
        '$_baseUrl/listar_atividades.php?mes=$_mesFiltro&ano=$_anoFiltro',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _atividades = jsonDecode(utf8.decode(response.bodyBytes));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar atividades: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _salvarAtividade() async {
    final atividadeTexto = _atividadeController.text.trim();

    if (_dataSelecionada == null || atividadeTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma data e digite a descrição da atividade.'),
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final url = Uri.parse('$_baseUrl/salvar_atividade.php');
      final response = await http.post(url, body: {
        'dia': _dataSelecionada!.day.toString(),
        'mes': _dataSelecionada!.month.toString(),
        'ano': _dataSelecionada!.year.toString(),
        'atividade': atividadeTexto,
      });

      if (response.statusCode == 200) {
        final dados = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(dados['mensagem'] ?? 'Concluído')),
          );
        }

        if (dados['sucesso'] == true) {
          _atividadeController.clear();
          FocusScope.of(context).unfocus();

          setState(() {
            _mesFiltro = _dataSelecionada!.month;
            _anoFiltro = _dataSelecionada!.year;
          });
          await _buscarAtividades();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão com o XAMPP: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividades Desenvolvidas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bloco de Cadastro com showDatePicker
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _selecionarData,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _dataSelecionada != null
                        ? _formatarData(_dataSelecionada!)
                        : 'Selecionar Data',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _atividadeController,
                    decoration: const InputDecoration(
                      labelText: 'Atividade desenvolvida',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _salvando ? null : _salvarAtividade,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Salvar Atividade'),
            ),

            const Divider(height: 28),

            // Filtro de Mês e Ano para consulta
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: _mesFiltro,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar Mês',
                      border: OutlineInputBorder(),
                    ),
                    items: _meses.map((mes) {
                      return DropdownMenuItem<int>(
                        value: mes['valor'] as int,
                        child: Text(mes['nome'].toString()),
                      );
                    }).toList(),
                    onChanged: (novoMes) {
                      if (novoMes != null) {
                        setState(() => _mesFiltro = novoMes);
                        _buscarAtividades();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    value: _anoFiltro,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                      border: OutlineInputBorder(),
                    ),
                    items: _anos.map((ano) {
                      return DropdownMenuItem<int>(
                        value: ano,
                        child: Text(ano.toString()),
                      );
                    }).toList(),
                    onChanged: (novoAno) {
                      if (novoAno != null) {
                        setState(() => _anoFiltro = novoAno);
                        _buscarAtividades();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista das atividades do mês filtrado
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _atividades.isEmpty
                      ? const Center(
                          child: Text('Nenhuma atividade registrada neste mês.'),
                        )
                      : ListView.builder(
                          itemCount: _atividades.length,
                          itemBuilder: (context, index) {
                            final item = _atividades[index];
                            final diaFormatado =
                                item['dia'].toString().padLeft(2, '0');
                            final mesFormatado =
                                item['mes'].toString().padLeft(2, '0');

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(diaFormatado),
                                ),
                                title: Text(item['atividade']),
                                subtitle: Text(
                                  'Data: $diaFormatado/$mesFormatado/${item['ano']}',
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}