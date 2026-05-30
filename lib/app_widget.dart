import 'package:flutter/material.dart';
import 'package:pi_3_modulo/pages/page_home.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "consumindo a api",
      initialRoute: '/',
      routes: {'/': (context) => PageHome()},
    );
  }
}
