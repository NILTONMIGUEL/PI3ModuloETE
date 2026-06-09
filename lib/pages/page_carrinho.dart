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

  // FUNÇÃO INTELIGENTE: Altera o IP dinamicamente para o dispositivo de teste
  String get obterBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    return 'http://localhost:8000';
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    carregarCarrinhoInicial();
  }

  // Busca os dados da API apenas ao entrar na tela (com loading)
  Future<void> carregarCarrinhoInicial() async {
    if (!mounted) return;
    setState(() => carregando = true);
    await atualizarDadosDoServidor();
    if (mounted) {
      setState(() => carregando = false);
    }
  }

  // Função interna auxiliar que baixa os dados do banco
  Future<void> atualizarDadosDoServidor() async {
    try {
      final String urlCompleta = '$obterBaseUrl/api/carrinho';
      final response = await dio.get(urlCompleta);

      if (response.statusCode == 200 && response.data != null && mounted) {
        setState(() {
          itensCarrinho = List.from(response.data['itens'] ?? []);
          totalCarrinho = double.tryParse(response.data['total_carrinho'].toString()) ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar com servidor: $e');
    }
  }

  // CORREÇÃO AQUI: Altera o valor na tela NA HORA, sem dar loading na página inteira
  // Future<void> alterarQuantidade(int produtoId, int novaQuantidade) async {
  //   if (novaQuantidade < 1) {
  //     excluirItem(produtoId);
  //     return;
  //   }

  //   // 1. Descobre qual item o usuário clicou e calcula a diferença para a API
  //   final int index = itensCarrinho.indexWhere((item) => item['produto']['id'] == produtoId);
  //   if (index == -1) return;

  //   final int qtdAntiga = int.tryParse(itensCarrinho[index]['quantidade'].toString()) ?? 1;
  //   final int diferencaQtd = novaQuantidade - qtdAntiga;
  //   final double precoUnidade = double.tryParse(itensCarrinho[index]['produto']['preco'].toString()) ?? 0.0;

  //   // 2. ATUALIZAÇÃO LOCAL IMEDIATA (Sem refresh de tela completa)
  //   setState(() {
  //     itensCarrinho[index]['quantidade'] = novaQuantidade;
  //     itensCarrinho[index]['subtotal'] = novaQuantidade * precoUnidade;
      
  //     // Recalcula o total geral do carrinho somando os subtotais locais
  //     totalCarrinho = itensCarrinho.fold(0.0, (total, item) => total + (double.tryParse(item['subtotal'].toString()) ?? 0.0));
  //   });

  //   // 3. Atualiza o banco de dados em silêncio (background)
  //   try {
  //     await dio.post('$obterBaseUrl/api/carrinho/adicionar', data: {
  //       'cliente': 1,
  //       'produto_id': produtoId,
  //       'quantidade': diferencaQtd,
  //     });
  //     // Sincroniza discretamente para garantir que as dízimas/subtotais do Laravel batam
  //     atualizarDadosDoServidor();
  //   } catch (e) {
  //     debugPrint('Erro ao salvar nova quantidade no servidor: $e');
  //   }
  // }
  Future<void> alterarQuantidade(int produtoId, int novaQuantidade) async {
    if (novaQuantidade < 1) {
      excluirItem(produtoId);
      return;
    }

    final int index = itensCarrinho.indexWhere((item) => item['produto']['id'] == produtoId);
    if (index == -1) return;

    final double precoUnidade = double.tryParse(itensCarrinho[index]['produto']['preco'].toString()) ?? 0.0;

    // 1. Atualiza na tela na mesma hora
    setState(() {
      itensCarrinho[index]['quantidade'] = novaQuantidade;
      itensCarrinho[index]['subtotal'] = novaQuantidade * precoUnidade;
      totalCarrinho = itensCarrinho.fold(0.0, (total, item) => total + (double.tryParse(item['subtotal'].toString()) ?? 0.0));
    });

    // 2. Envia para a NOVA rota do Laravel salvar em definitivo
    try {
      await dio.post('$obterBaseUrl/api/carrinho/atualizar', data: {
        'cliente': 1,
        'produto_id': produtoId,
        'quantidade': novaQuantidade, // Passa o número final da tela direto!
      });
    } catch (e) {
      debugPrint('Erro ao salvar nova quantidade no servidor: $e');
    }
  }

  // CORREÇÃO AQUI: Remove o card na hora da árvore de componentes
  Future<void> excluirItem(int produtoId) async {
    // 1. Remove localmente para sumir da tela instantaneamente
    setState(() {
      itensCarrinho.removeWhere((item) => item['produto']['id'] == produtoId);
      totalCarrinho = itensCarrinho.fold(0.0, (total, item) => total + (double.tryParse(item['subtotal'].toString()) ?? 0.0));
    });

    // 2. Avisa o Laravel em segundo plano
    try {
      await dio.post('$obterBaseUrl/api/carrinho/remover', data: {
        'cliente': 1,
        'produto_id': produtoId,
      });
    } catch (e) {
      debugPrint('Erro ao excluir no servidor: $e');
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

                  // LISTA OU ESTADO VAZIO
                  Expanded(
                    child: carregando
                        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                        : itensCarrinho.isEmpty
                            ? _buildCarrinhoVazio()
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

                  if (!carregando && itensCarrinho.isNotEmpty) _buildFooterCarrinho(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrinhoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.white60),
          const SizedBox(height: 16),
          const Text(
            "Seu carrinho está vazio!",
            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.orange),
            label: const Text(
              "Voltar para a Loja",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCarrinhoCard(dynamic produto, dynamic item) {
    String urlImagemFinal = '';
    if (produto != null && produto['imagem'] != null) {
      urlImagemFinal = produto['imagem'].toString();
    }

    if (urlImagemFinal.contains('localhost')) {
      urlImagemFinal = urlImagemFinal.replaceAll('http://localhost:8000', obterBaseUrl);
    }

    final int produtoId = produto != null ? (produto['id'] ?? 0) : 0;
    final int qtdAtual = int.tryParse(item['quantidade'].toString()) ?? 1;
    final double subtotal = double.tryParse(item['subtotal'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffFF7A00).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffDDF7FF), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: urlImagemFinal.isNotEmpty
                ? Image.network(
                    urlImagemFinal,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.black26,
                      child: const Icon(Icons.fastfood, color: Colors.white),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.black26,
                    child: const Icon(Icons.fastfood, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  produto != null ? (produto['nome'] ?? 'Sem nome') : 'Sem nome',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildBotaoQtd(
                      icon: Icons.remove,
                      onTap: () => alterarQuantidade(produtoId, qtdAtual - 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "$qtdAtual",
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildBotaoQtd(
                      icon: Icons.add,
                      onTap: () => alterarQuantidade(produtoId, qtdAtual + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "R\$ ${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => excluirItem(produtoId),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_forever,
                    color: Color(0xffDDF7FF),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoQtd({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildFooterCarrinho() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(color: Colors.white30, height: 20),
        Row(
          key: ValueKey(totalCarrinho), // Força o rodapé a atualizar o texto do valor
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total:",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "R\$ ${totalCarrinho.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Comprar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}