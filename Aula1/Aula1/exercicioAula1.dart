//Feito por Guilherme Pessoa Rossi
void main (){
  String nome = "Camiseta ADS";
  int quantidade = 3;  
  double preco = 49.90;
  bool disponivel = true;
  const imposto = 5.0;
  
  double calculo = (quantidade * preco) * (1 + imposto/100);
  print("Produto: $nome");
  print("Disponível em Estoque: $disponivel");
  print("Quantidade: $quantidade");
  print("Preço Unitário: $preco");
  print("Valor total: R\$ $calculo"); 
}
