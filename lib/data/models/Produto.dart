class Produto {
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final String imagem;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imagem,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: double.parse(json['preco'].toString()),
      imagem: json['imagem'],
    );
  }
}