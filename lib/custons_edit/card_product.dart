import 'package:flutter/material.dart';
import 'package:pi_3_modulo/data/models/Produto.dart';
import 'package:dio/dio.dart';
import 'package:pi_3_modulo/pages/page_carrinho.dart';

class ProductCard extends StatefulWidget {
  final Produto produto;
  final int numeroFichaAtual; // Recebe o número da ficha atual da tela pai
  final ValueChanged<int> onFichaAtualizada; // Callback para avisar a tela pai que a ficha mudou

  const ProductCard({
    super.key,
    required this.produto,
    required this.numeroFichaAtual,
    required this.onFichaAtualizada,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantidade = 1;

  Future<void> adicionarAoCarrinho() async {
    final dio = Dio();
    final String url = 'http://localhost:8000/api/carrinho/adicionar';

    try {
      final response = await dio.post(
        url,
        data: {
          'cliente': widget.numeroFichaAtual, // Usa a ficha atual controlada pelo app
          'produto_id': widget.produto.id,
          'quantidade': quantidade,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final mensagem = response.data['mensagem'];

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      String erroMensagem = 'Erro ao adicionar produto';
      if (e.response != null && e.response?.data != null) {
        erroMensagem = e.response?.data['mensagem'] ?? e.response?.data.toString() ?? erroMensagem;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erroMensagem),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Container(
        width: 150,
        height: 260,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xffFF7A00),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xffDDF7FF),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(.3),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            // IMAGEM
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.produto.imagem,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    color: Colors.black26,
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),

            // NOME
            Text(
              widget.produto.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            // DESCRIÇÃO
            Text(
              widget.produto.descricao,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),

            // PREÇO
            Text(
              'R\$ ${widget.produto.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),

            // QUANTIDADE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quantityButton(
                  Icons.remove,
                  () {
                    if (quantidade > 1) {
                      setState(() => quantidade--);
                    }
                  },
                ),
                Text(
                  quantidade.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _quantityButton(
                  Icons.add,
                  () {
                    setState(() => quantidade++);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),

            // BOTÃO ADICIONAR
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: adicionarAoCarrinho,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Adicionar",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // BOTÃO IR PARA O CARRINHO
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: OutlinedButton.icon(
            //       onPressed: () async {
            //         // Abre a tela do carrinho e aguarda para ver se uma nova ficha vai retornar
            //         final int? novaFicha = await Navigator.push<int>(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => PageCarrinho(fichaId: widget.numeroFichaAtual),
            //           ),
            //         );

            //         // Se retornou um número incrementado do carrinho, atualiza o estado global/pai
            //         if (novaFicha != null && mounted) {
            //           widget.onFichaAtualizada(novaFicha);
            //         }
            //       },
            //       icon: const Icon(Icons.shopping_cart, size: 16),
            //       label: Text("Carrinho (${widget.numeroFichaAtual})"),
            //       style: OutlinedButton.styleFrom(
            //         foregroundColor: Colors.white,
            //         side: const BorderSide(color: Colors.white),
            //         padding: const EdgeInsets.symmetric(vertical: 2),
            //       ),
            //     ),
            //   ),
            // )
            // BOTÃO IR PARA O CARRINHO (CORRIGIDO)
Padding(
  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
  child: SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () async {
        // Abre a tela do carrinho e aguarda para ver se uma nova ficha vai retornar
        final int? novaFicha = await Navigator.push<int>(
          context,
          MaterialPageRoute(
            // CORREÇÃO AQUI: Trocado 'fichaId' por 'fichaInicial'
            builder: (context) => PageCarrinho(fichaInicial: widget.numeroFichaAtual),
          ),
        );

        // Se retornou um número incrementado do carrinho, atualiza o estado global/pai
        if (novaFicha != null && mounted) {
          widget.onFichaAtualizada(novaFicha);
        }
      },
      icon: const Icon(Icons.shopping_cart, size: 16),
      label: Text("Carrinho"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 2),
      ),
    ),
  ),
)
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }
}