import 'package:flutter/material.dart';
import 'package:pi_3_modulo/custons_edit/buttonborder_menu_neonPainter.dart';


class CategoriaButton extends StatefulWidget {
  final String titulo;
  final bool selecionado;
  final VoidCallback onTap;

  const CategoriaButton({
    super.key,
    required this.titulo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  State<CategoriaButton> createState() => _CategoriaButtonState();
}

class _CategoriaButtonState extends State<CategoriaButton>
    with SingleTickerProviderStateMixin {
  bool hover = false;
   late AnimationController _borderController;

  @override
  void initState() {
    super.initState();

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => hover = true),
        onTapUp: (_) => setState(() => hover = false),
        onTapCancel: () => setState(() => hover = false),
        onTap: widget.onTap,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(
            begin: 0,
            end: widget.selecionado
                ? 1
                : hover
                    ? 1
                    : 0,
          ),
          builder: (context, progress, child) {
            return SizedBox(
  width: 100,
  height: 50,
  child: Stack(
    children: [
      AnimatedBuilder(
        animation: _borderController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(100, 50),
            painter: ButtonNeonBorderPainter(
              _borderController.value,
            ),
          );
        },
      ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ),
          ),

                Container(
                  width: 100,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    widget.titulo,
                    style: TextStyle(
                      color: widget.selecionado || hover
                          ? Colors.white
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                
              ],
            ),
            );
          },
        ),
      ),
    );
  }
}