import 'package:flutter/material.dart';

import 'inicio.dart'; // Importa correctamente tu pantalla de la carpeta screens

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diario de Crochet',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const Inicio(), // Carga la clase Inicio que está en inicio.dart
    );
  }
}
