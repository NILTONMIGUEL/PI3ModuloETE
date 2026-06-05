import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  initState(){
    super.initState();
     Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/comidas');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(
        children:[
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
          Center(
            child: Lottie.asset('assets/lottie/Food_Loading_Animation.json',width: 100, height: 100,fit: BoxFit.cover,repeat: true)
          ),
        ]
      )
    );
  }
}