import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pi_3_modulo/custons_edit/neonBorderPainter.dart';

class PageCarrinho extends StatefulWidget {
  const PageCarrinho({super.key});

  @override
  State<PageCarrinho> createState() => _PageCarrinhoState();
}

class _PageCarrinhoState extends State<PageCarrinho>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  final dio = Dio();

  // Estados da página
  List<dynamic> itensCarrinho = [];
  double totalCarrinho = 0.0;
  bool carregando = true;

  // FUNÇÃO INTELIGENTE: Descobre o IP correto do servidor baseado no dispositivo de teste
  String get obterBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/carrinho'; // Se testar no navegador do PC
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000'; // Se testar no emulador Android
      }
    } catch (_) {}
    return 'http://localhost:8000'; // Padrão para Windows/iOS
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    carregarCarrinho();
  }

  // Função que conecta com a API do Laravel
  Future<void> carregarCarrinho() async {
    if (!mounted) return;
    setState(() => carregando = true);
    
    print('--- INICIANDO BUSCA NO LARAVEL ---');
    
    try {
      // Monta o link dinamicamente (ex: http://localhost:8000/api/carrinho ou http://10.0.2.2:8000/api/carrinho)
      final String urlCompleta = '$obterBaseUrl/api/carrinho';
      print('Buscando dados em: $urlCompleta');

      final response = await dio.get(urlCompleta);
      
      print('Status recebido: ${response.statusCode}');
      print('Dados brutos da API: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          itensCarrinho = List.from(response.data['itens'] ?? []);
          totalCarrinho = double.tryParse(response.data['total_carrinho'].toString()) ?? 0.0;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Itens carregados: ${itensCarrinho.length}')),
        );
      }
    } catch (e) {
      print('ERRO CRÍTICO NO GET: $e');
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.77),
                BlendMode.darken,
              ),
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  'assets/imagens/background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // EFEITO NEON BORDER
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: NeonBorderPainter(_controller.value),
                child: const SizedBox.expand(),
              );
            },
          ),
          
          // CONTEÚDO PRINCIPAL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // TÍTULO DA TELA
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Meu Carrinho",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // LISTA DOS ITENS EM COLUNAS ORDENADAS
                  Expanded(
                    child: carregando
                        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                        : itensCarrinho.isEmpty
                            ? const Center(
                                child: Text(
                                  "Seu carrinho está vazio!",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: itensCarrinho.length,
                                itemBuilder: (context, index) {
                                  final item = itensCarrinho[index];
                                  final produto = item['produto'];

                                  return _buildItemCarrinhoCard(produto, item);
                                },
                              ),
                  ),

                  // RODAPÉ COM PREÇO TOTAL E BOTÕES
                  if (!carregando && itensCarrinho.isNotEmpty) _buildFooterCarrinho(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // // WIDGET DO CARD DE ITEM TOTALMENTE CORRIGIDO E AUTOMATIZADO
  // Widget _buildItemCarrinhoCard(dynamic produto, dynamic item) {
  //   String nomeArquivoAutomatico = '';
  //   if (produto != null && produto['imagem'] != null) {
  //     nomeArquivoAutomatico = produto['imagem'].toString();
  //   }

  //   String urlImagemFinal = '';

  //   if (nomeArquivoAutomatico.isNotEmpty && !nomeArquivoAutomatico.startsWith('http')) {
  //     // Limpeza de resíduos de caminhos do banco de dados
  //     if (nomeArquivoAutomatico.startsWith('/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(1);
  //     if (nomeArquivoAutomatico.startsWith('api/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(4);
  //     if (nomeArquivoAutomatico.startsWith('public/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(7);
  //     if (nomeArquivoAutomatico.startsWith('storage/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(8);
  //     if (nomeArquivoAutomatico.startsWith('produtos/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(9);

  //     // Junta o IP dinâmico correto com a pasta pública do Laravel onde está sua foto
  //     urlImagemFinal = '$obterBaseUrl/storage/produtos/$nomeArquivoAutomatico';
  //   } else if (nomeArquivoAutomatico.startsWith('http')) {
  //     urlImagemFinal = nomeArquivoAutomatico;
  //   }

  //   print('Link gerado para a imagem: $urlImagemFinal');

  //   final double subtotal = double.tryParse(item['subtotal'].toString()) ?? 0.0;

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: const Color(0xffFF7A00).withOpacity(0.9),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xffDDF7FF), width: 1),
  //     ),
  //     child: Row(
  //       children: [
  //         // IMAGEM DO PRODUTO REGENERADA
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(8),
  //           child: urlImagemFinal.isNotEmpty
  //               ? Image.network(
  //                   urlImagemFinal,
  //                   width: 70,
  //                   height: 70,
  //                   fit: BoxFit.cover,
  //                   errorBuilder: (context, error, stackTrace) => Container(
  //                     width: 70,
  //                     height: 70,
  //                     color: Colors.black26,
  //                     child: const Icon(Icons.fastfood, color: Colors.white),
  //                   ),
  //                 )
  //               : Container(
  //                   width: 70,
  //                   height: 70,
  //                   color: Colors.black26,
  //                   child: const Icon(Icons.fastfood, color: Colors.white),
  //                 ),
  //         ),
  //         const SizedBox(width: 12),

  //         // INFORMAÇÕES DO PRODUTO (NOME E QUANTIDADE)
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 produto != null ? (produto['nome'] ?? 'Sem nome') : 'Sem nome',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 15,
  //                 ),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 "Qtd: ${item['quantidade']}",
  //                 style: const TextStyle(color: Colors.white, fontSize: 13),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // PREÇO CALCULADO (SUBTOTAL)
  //         Text(
  //           "R\$ ${subtotal.toStringAsFixed(2)}",
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold,
  //             fontSize: 16,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // WIDGET DO CARD DE ITEM COM DIRECIONAMENTO DIRETO PARA A PASTA PÚBLICA
  Widget _buildItemCarrinhoCard(dynamic produto, dynamic item) {
    String nomeArquivoAutomatico = '';
    if (produto != null && produto['imagem'] != null) {
      nomeArquivoAutomatico = produto['imagem'].toString();
    }

    String urlImagemFinal = '';

    if (nomeArquivoAutomatico.isNotEmpty && !nomeArquivoAutomatico.startsWith('http')) {
      // Limpeza profunda de qualquer prefixo residual que o banco de dados possa conter
      if (nomeArquivoAutomatico.startsWith('/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(1);
      if (nomeArquivoAutomatico.startsWith('api/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(4);
      if (nomeArquivoAutomatico.startsWith('public/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(7);
      if (nomeArquivoAutomatico.startsWith('storage/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(8);
      if (nomeArquivoAutomatico.startsWith('produtos/')) nomeArquivoAutomatico = nomeArquivoAutomatico.substring(9);

      // SOLUÇÃO: Força o caminho direto pela pasta física mapeada pelo servidor local
      urlImagemFinal = '$obterBaseUrl/storage/produtos/$nomeArquivoAutomatico';
    } else if (nomeArquivoAutomatico.startsWith('http')) {
      urlImagemFinal = nomeArquivoAutomatico;
    }

    print('Link gerado para a imagem: $urlImagemFinal');

    final double subtotal = double.tryParse(item['subtotal'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffFF7A00).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffDDF7FF), width: 1),
      ),
      child: Row(
        children: [
          // IMAGEM DO PRODUTO REGENERADA
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: urlImagemFinal.isNotEmpty
                ? Image.network(
                    urlImagemFinal,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    // Se o emulador ainda bloquear o download, tentamos a URL alternativa em tempo de execução
                    errorBuilder: (context, error, stackTrace) {
                      // Segunda tentativa de link contornando o atalho do storage
                      final urlAlternativa = urlImagemFinal.replaceAll('/storage/', '/public/');
                      
                      return Image.network(
                        urlAlternativa,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        // Caso ambas falhem (arquivo com nome alterado no disco), exibe o ícone de fallback
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.black26,
                          child: const Icon(Icons.fastfood, color: Colors.white),
                        ),
                      );
                    },
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.black26,
                    child: const Icon(Icons.fastfood, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 12),

          // INFORMAÇÕES DO PRODUTO (NOME E QUANTIDADE)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto != null ? (produto['nome'] ?? 'Sem nome') : 'Sem nome',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Qtd: ${item['quantidade']}",
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),

          // PREÇO CALCULADO (SUBTOTAL)
          Text(
            "R\$ ${subtotal.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET DO RODAPÉ COM EXIBIÇÃO DO TOTAL E OS BOTÕES
  Widget _buildFooterCarrinho() {
    return Column(
      children: [
        const Divider(color: Colors.white30, height: 25),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total:",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "R\$ ${totalCarrinho.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para finalizar a compra no futuro
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Comprar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}