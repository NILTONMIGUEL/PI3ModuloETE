import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pi_3_modulo/custons_edit/button_menu_neon.dart';
import 'package:pi_3_modulo/custons_edit/card_product.dart';
import 'package:pi_3_modulo/custons_edit/neonBorderPainter.dart';
import 'package:pi_3_modulo/custons_edit/video_loop.dart';
import 'package:pi_3_modulo/data/models/Produto.dart';


class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final ScrollController _scrollController = ScrollController();
  final dio = Dio();

  final List<Produto> produtos = [];

  bool carregando = false;
  int pagina = 1;
  int categoriaSelecionada = 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    carregarProdutos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !carregando) {
        carregarProdutos();
      }
    });
  }

Future<void> carregarProdutos() async {
  if (carregando) return;

  carregando = true;

  try {
    final response = await dio.get(
      'http://localhost:8000/api/comidas',
      queryParameters: {
        'page': pagina,
        'categoria': categoriaSelecionada,
      },
    );

    final List dados = response.data['produtos'];//['data'];

    final novosProdutos =
        dados.map((e) => Produto.fromJson(e)).toList();

    setState(() {
      produtos.clear();
      produtos.addAll(novosProdutos);
      // pagina++;
    });
  } catch (e) {
    debugPrint(e.toString());
  }

  carregando = false;
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
                  BlendMode.darken
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
                  // Vídeo
                  Container(
                    width: double.infinity,
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const VideoLoop(
                      videoPath: 'assets/videos/hamburguer.mp4',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Categorias
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      CategoriaButton(
                        titulo: "COMIDAS",
                        selecionado: categoriaSelecionada == 1,
                        onTap: () {
                          setState(() {
                            pagina= 1;
                            produtos.clear();

                            categoriaSelecionada = 1;
                          });
                          carregarProdutos();
                        },
                      ),
                      CategoriaButton(
                        titulo: "BEBIDAS",
                        selecionado: categoriaSelecionada == 2,
                        onTap: () {
                          setState(() {
                            pagina = 1;
                            produtos.clear();
                            categoriaSelecionada = 2;
                            
                          });
                          carregarProdutos();
                        },
                      ),
                      CategoriaButton(
                        titulo: "SOBREMESAS",
                        selecionado: categoriaSelecionada == 3,
                        onTap: () {
                          setState(() {
                            pagina = 1; 
                            produtos.clear();
                            categoriaSelecionada = 3;
                          });

                          carregarProdutos();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Lista de produtos com scroll infinito
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                produtos.length,
                                (index) => ProductCard(
                                  produto:produtos[index],
                                ),
                              ),
                            ),
                      
                            const SizedBox(height: 25),
                      
                            if (carregando)
                              const CircularProgressIndicator(),
                      
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}