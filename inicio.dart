// lib/inicio.dart
import 'package:flutter/material.dart';

import 'armario.dart';
import 'contador.dart';
import 'materiales.dart';
import 'presupuesto.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC099), // Color de fondo melocoton
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titulo principal
              const Text(
                'DIARIO DE\nCROCHET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Divisor decorativo superior
              _buildDecorativeDivider(),
              const SizedBox(height: 32),

              // Botones del menu
              _buildMenuButton('ARMARIO', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Armario()),
                );
              }),
              const SizedBox(height: 16),
              _buildMenuButton('CONTADOR VUELTAS', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContadorScreen(),
                  ),
                );
              }),
              const SizedBox(height: 16),
              _buildMenuButton('LISTA MATERIALES', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MaterialesFaltantesScreen(),
                  ),
                );
              }),
              const SizedBox(height: 16),
              _buildMenuButton('PRESUPUESTO', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalculadoraPresupuestoScreen(),
                  ),
                );
              }),

              const SizedBox(height: 32),
              // Divisor decorativo inferior
              _buildDecorativeDivider(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para los botones en forma de pildora
  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEFEFEF), // Gris claro del boton
          foregroundColor: Colors.black,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para las lineas divisorias con adorno central
  Widget _buildDecorativeDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.local_florist, color: Colors.black, size: 22),
        ),
        const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
      ],
    );
  }
}
