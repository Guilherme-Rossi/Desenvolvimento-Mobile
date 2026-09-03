class Pergunta {
  const Pergunta(this.texto, this.respostas);

  final String texto;
  final List<String> respostas;

  List<String> embaralha() {
    final novaLista = List.of(respostas);
    novaLista.shuffle();
    return novaLista;
  }
}