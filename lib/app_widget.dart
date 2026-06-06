import 'package:flutter/material.dart';
import 'package:pi_3_modulo/pages/page_carrinho.dart';
import 'package:pi_3_modulo/pages/page_home.dart';
import 'package:pi_3_modulo/pages/splash_screen.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "consumindo a api",
      initialRoute: '/',
      routes: {'/comidas': (context) => PageHome(),
      '/':(context) => SplashScreen(),
      '/carrinho' :(context) => PageCarrinho()},
    );
  }
}
