import 'package:flutter/material.dart';

import 'armario.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC099), // Color de fondo melocotón
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título principal
              const Text(
                'DIARIO DE\nCROCHET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'alice',
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

              // Botones del menú
              _buildMenuButton('ARMARIO', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Armario()),
                );
                // TODO: Acción para Armario
              }),
              const SizedBox(height: 16),
              _buildMenuButton('CONTADOR VUELTAS', () {
                // TODO: Acción para Contador de Vueltas
              }),
              const SizedBox(height: 16),
              _buildMenuButton('LISTA MATERIALES', () {
                // TODO: Acción para Lista de Materiales
              }),
              const SizedBox(height: 16),
              _buildMenuButton('CRONÓMETRO', () {
                // TODO: Acción para Cronómetro
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

  // Widget auxiliar para los botones en forma de píldora
  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEFEFEF), // Gris claro del botón
          foregroundColor: Colors.black,
          elevation: 0, // Plano, sin sombra
          shape: const StadiumBorder(), // Bordes redondeados de píldora
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

  // Widget auxiliar para las líneas divisorias con adorno central
  Widget _buildDecorativeDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.local_florist, color: Colors.black, size: 22),
        ),
        const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
      ],
    );
  }
}
