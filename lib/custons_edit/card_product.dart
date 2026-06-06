import 'package:flutter/material.dart';
import 'package:pi_3_modulo/data/models/Produto.dart';
import 'package:dio/dio.dart';
import 'package:pi_3_modulo/pages/page_carrinho.dart';

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
  int userID = 1;

  Future<void> adicionarAoCarrinho() async {
  final dio = Dio();
  
  // Substitua pelo IP da sua máquina onde o Laravel está rodando
  final String url = 'http://localhost:8000/api/carrinho/adicionar';

  try {
    // O Dio já converte o Map para JSON automaticamente no corpo (data)
    final response = await dio.post(
      url,
      data: {
        'cliente' : userID,
        'produto_id': widget.produto.id, // ID do seu model Produto
        'quantidade': quantidade,        // Estado interno do contador
                         // Preencha se tiver autenticação
      },
      options: Options(
        headers: {
          'Accept': 'application/json', // Informa ao Laravel que queremos resposta em JSON
        },
      ),
    );

    // O Dio considera respostas de sucesso no range de 200-299
    if (response.statusCode == 200 || response.statusCode == 201) {
      // No Dio, o response.data já vem decodificado como um Map
      final mensagem = response.data['mensagem'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.green,
        ),
      );
    }
  // } on DioException catch (e) {
  //   // O Dio tem um tratamento de erro específico muito bom
  //   String erroMensagem = 'Erro ao adicionar produto';
    
  //   if (e.response != null && e.response?.data != null) {
  //     // Captura a mensagem de erro enviada pelo Laravel (se houver)
  //     erroMensagem = e.response?.data['mensagem'] ?? erroMensagem;
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(erroMensagem),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // } 
  // Garanta que a linha abaixo tenha o "catch (e)" preenchido corretamente:
}on DioException catch (e) {
  // print('--- ERRO DETALHADO DA API (LARAVEL) ---');
  // print('Status Code: ${e.response?.statusCode}');
  // print('Dados retornados: ${e.response?.data}');
  // print('---------------------------------------');

  String erroMensagem = 'Erro ao adicionar produto';
  
  if (e.response != null && e.response?.data != null) {
    erroMensagem = e.response?.data['mensagem'] ?? e.response?.data.toString() ?? erroMensagem;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(erroMensagem),
      backgroundColor: Colors.red,
    ),
  );
}
  catch (e) {
    // Captura qualquer outro erro inesperado
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
            // SizedBox(
            //   width: double.infinity,
            //   height: 28,
            //   child: ElevatedButton(
            //     onPressed: () {},
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.white,
            //       foregroundColor: Colors.orange,
            //       padding: EdgeInsets.zero,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     child: const Text(
            //       "Adicionar",
            //       style: TextStyle(
            //         fontSize: 10,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            //SizedBox(
//   width: double.infinity,
//   height: 28,
//   child: ElevatedButton(
//     // A mágica acontece aqui chamando a função assíncrona
//     onPressed: adicionarAoCarrinho, 
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.orange,
//       padding: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//     ),
//     child: const Text(
//       "Adicionar",
//       style: TextStyle(
//         fontSize: 10,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   ),
// ),
SizedBox(
  width: double.infinity,
  height: 28,
  child: ElevatedButton(
    onPressed: adicionarAoCarrinho, // Vincula a função aqui
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PageCarrinho(), // Nome da sua tela de destino
                      ),
                    );
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