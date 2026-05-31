import 'package:flutter/material.dart';
import 'package:pi_3_modulo/custons_edit/button_menu_neon.dart';
import 'package:pi_3_modulo/custons_edit/neonBorderPainter.dart';
import 'package:pi_3_modulo/custons_edit/video_loop.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    int categoriaSelecionada = 0;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                  Container(
                    width: double.infinity,
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const VideoLoop(videoPath: 'assets/videos/hamburguer.mp4'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: Container(
                      width:double.infinity,
                      height:60,
                      child: Row(
                        children: [
                          Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          children: [
                            CategoriaButton(
                              titulo: "COMIDAS",
                              selecionado: categoriaSelecionada == 0,
                              onTap: () {
                                setState(() {
                                  categoriaSelecionada = 0;
                                });
                              },
                            ),
                            CategoriaButton(
                              titulo: "BEBIDAS",
                              selecionado: categoriaSelecionada == 1,
                              onTap: () {
                                setState(() {
                                  categoriaSelecionada = 1;
                                });
                              },
                            ),
                            CategoriaButton(
                              titulo: "SOBREMESAS",
                              selecionado: categoriaSelecionada == 2,
                              onTap: () {
                                setState(() {
                                  categoriaSelecionada = 2;
                                });
                              },
                            ),
                          
                          ],
                        )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
