import 'package:flutter/material.dart';
import 'package:pi_3_modulo/data/models/Produto.dart';

class ProductCard extends StatefulWidget {
  final Produto produto;

  const ProductCard({
    super.key,
    required this.produto,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantidade = 1;

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
              style: TextStyle(
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
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
      
            const SizedBox(height: 4),
      
            // PREÇO
              Text(
               'R\$ ${widget.produto.preco.toStringAsFixed(2)}',
              style: TextStyle(
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
                onPressed: () {},
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
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Ver carrinho
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Carrinho"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(
    IconData icon,
    VoidCallback onTap,
  ) {
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