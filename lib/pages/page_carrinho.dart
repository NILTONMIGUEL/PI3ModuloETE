import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pi_3_modulo/custons_edit/neonBorderPainter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  int Cliente = 1;
  
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

  Future<void> carregarCarrinhoInicial() async {
    if (!mounted) return;
    setState(() => carregando = true);
    await atualizarDadosDoServidor();
    if (mounted) {
      setState(() => carregando = false);
    }
  }

  Future<void> atualizarDadosDoServidor() async {
    try {
      final String url = '$obterBaseUrl/api/carrinho';
      final response = await dio.get(url);

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

  Future<void> alterarQuantidade(int produtoId, int novaQuantidade) async {
    if (novaQuantidade < 1) {
      excluirItem(produtoId);
      return;
    }

    final int index = itensCarrinho.indexWhere((item) => item['produto']['id'] == produtoId);
    if (index == -1) return;

    final double precoUnidade = double.tryParse(itensCarrinho[index]['produto']['preco'].toString()) ?? 0.0;

    setState(() {
      itensCarrinho[index]['whitespace'] = novaQuantidade;
      itensCarrinho[index]['quantidade'] = novaQuantidade;
      itensCarrinho[index]['subtotal'] = novaQuantidade * precoUnidade;
      totalCarrinho = itensCarrinho.fold(0.0, (total, item) => total + (double.tryParse(item['subtotal'].toString()) ?? 0.0));
    });

    try {
      await dio.post('$obterBaseUrl/api/carrinho/atualizar', data: {
        'cliente': 1,
        'produto_id': produtoId,
        'quantidade': novaQuantidade,
      });
    } catch (e) {
      debugPrint('Erro ao salvar nova quantidade no servidor: $e');
    }
  }

  Future<void> excluirItem(int produtoId) async {
    setState(() {
      itensCarrinho.removeWhere((item) => item['produto']['id'] == produtoId);
      totalCarrinho = itensCarrinho.fold(0.0, (total, item) => total + (double.tryParse(item['subtotal'].toString()) ?? 0.0));
    });

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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: NeonBorderPainter(_controller.value),
                child: const SizedBox.expand(),
              );
            },
          ),
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
          key: ValueKey(totalCarrinho),
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
                onPressed: () async {
                  setState(() => carregando = true);

                  final String rotaFinal = '$obterBaseUrl/api/carrinho/comprar';
                  
                  try {
                    final response = await dio.post(
                      rotaFinal,
                      data: {
                        'cliente': Cliente,
                      },
                    );

                    if ((response.statusCode == 201 || response.statusCode == 200) && mounted) {
                      final int idGerado = response.data['compra_id'] ?? 0;
                      final int clienteAtual = Cliente;

                      // Abre a interface do PDF nativa
                      await gerarPdfCompraLocal(idGerado, clienteAtual);
                      
                      setState(() {
                        itensCarrinho = [];
                        totalCarrinho = 0.0;
                        carregando = false;
                        Cliente++;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compra finalizada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() => carregando = false);
                    }

                    if (e is DioException && e.response != null) {
                      String erroFinal = 'Erro desconhecido no servidor';
                      
                      if (e.response?.data is Map) {
                        erroFinal = e.response?.data['erro_real'] ?? 'Erro no servidor';
                      } else {
                        erroFinal = (e.response?.data?.toString() ?? '').substring(0, 100).replaceAll(RegExp(r'<[^>]*>'), '');
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro: $erroFinal'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 8),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Não foi possível conectar ao servidor.')),
                      );
                    }
                  }
                },
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

  Future<void> gerarPdfCompraLocal(int idCompra, int idCliente) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start, // 1. CORRIGIDO: Nome correto da propriedade no pacote PDF
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: const pw.BoxDecoration(color: PdfColors.orange),
                  child: pw.Center(
                    child: pw.Text(
                      'COMPROVANTE DE COMPRA',
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Compra ID: #$idCompra', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Cliente ID: #$idCliente'),
                pw.Text('Status: Pago / Finalizado'),
                pw.Text('Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Produto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qtd', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    // 2. CORRIGIDO: Mapeamento tipado explicitamente como TableRow para o pw.Table aceitar
                    ...itensCarrinho.map<pw.TableRow>((item) {
                      final produto = item['produto'];
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6), 
                            child: pw.Text(produto != null ? (produto['nome'] ?? 'Sem nome') : 'Sem nome')
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6), 
                            child: pw.Text(item['whitespace']?.toString() ?? item['quantidade']?.toString() ?? '1')
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6), 
                            child: pw.Text('R\$ ${double.parse(item['subtotal'].toString()).toStringAsFixed(2)}')
                          ),
                        ],
                      );
                    }).toList(), // Garante a conversão para lista limpa
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'TOTAL COMPRA: R\$ ${totalCarrinho.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.orange),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}