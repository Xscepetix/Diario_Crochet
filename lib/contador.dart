// lib/screens/contador.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProyectoContador {
  String id;
  String titulo;
  int vueltas;
  int objetivo;

  ProyectoContador({
    required this.id,
    required this.titulo,
    this.vueltas = 0,
    this.objetivo = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'vueltas': vueltas,
    'objetivo': objetivo,
  };

  factory ProyectoContador.fromJson(Map<String, dynamic> json) =>
      ProyectoContador(
        id: json['id'],
        titulo: json['titulo'],
        vueltas: json['vueltas'] ?? 0,
        objetivo: json['objetivo'] ?? 0,
      );
}

class ContadorScreen extends StatefulWidget {
  const ContadorScreen({super.key});

  @override
  State<ContadorScreen> createState() => _ContadorScreenState();
}

class _ContadorScreenState extends State<ContadorScreen> {
  List<ProyectoContador> _contadores = [];

  @override
  void initState() {
    super.initState();
    _cargarContadores();
  }

  Future<void> _cargarContadores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contadoresString = prefs.getString('contadores_crochet');
    if (contadoresString != null) {
      final List<dynamic> decoded = jsonDecode(contadoresString);
      setState(() {
        _contadores = decoded
            .map((item) => ProyectoContador.fromJson(item))
            .toList();
      });
    }
  }

  Future<void> _guardarContadores() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _contadores.map((c) => c.toJson()).toList(),
    );
    await prefs.setString('contadores_crochet', encoded);
  }

  void _mostrarDialogoContador({ProyectoContador? contadorEditar}) {
    final tituloCtrl = TextEditingController(
      text: contadorEditar?.titulo ?? '',
    );
    final vueltasCtrl = TextEditingController(
      text: contadorEditar != null ? contadorEditar.vueltas.toString() : '0',
    );
    final objetivoCtrl = TextEditingController(
      text: contadorEditar != null && contadorEditar.objetivo > 0
          ? contadorEditar.objetivo.toString()
          : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFAF7F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                contadorEditar == null ? 'Nuevo Contador' : 'Editar Contador',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre del proyecto / pieza',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: vueltasCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Vueltas actuales',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: objetivoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Objetivo de vueltas (opcional)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B498),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (tituloCtrl.text.isNotEmpty) {
                      final int v = int.tryParse(vueltasCtrl.text) ?? 0;
                      final int o = int.tryParse(objetivoCtrl.text) ?? 0;

                      setState(() {
                        if (contadorEditar == null) {
                          _contadores.add(
                            ProyectoContador(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              titulo: tituloCtrl.text,
                              vueltas: v,
                              objetivo: o,
                            ),
                          );
                        } else {
                          contadorEditar.titulo = tituloCtrl.text;
                          contadorEditar.vueltas = v;
                          contadorEditar.objetivo = o;
                        }
                      });
                      _guardarContadores();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC099),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              'CONTADOR DE VUELTAS',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            _buildDecorativeDivider(),
            const SizedBox(height: 14),

            // LISTA DE CONTADORES DENSOS / COMPACTOS
            Expanded(
              child: _contadores.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay contadores creados',
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _contadores.length,
                      itemBuilder: (context, index) {
                        final item = _contadores[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF7F2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CABECERA (TÍTULO Y EDICIÓN)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.titulo,
                                      style: const TextStyle(
                                        fontFamily: 'serif',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.black54,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _mostrarDialogoContador(
                                              contadorEditar: item,
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.black38,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _contadores.removeWhere(
                                              (c) => c.id == item.id,
                                            );
                                          });
                                          _guardarContadores();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // DISPLAY CENTRAL MÁS PEQUEÑO
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E9DD),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFD4C3B3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    item.vueltas.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C221E),
                                    ),
                                  ),
                                ),
                              ),
                              if (item.objetivo > 0) ...[
                                const SizedBox(height: 4),
                                Center(
                                  child: Text(
                                    'Objetivo: ${item.objetivo} vueltas',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 10),

                              // BOTONES DE ACCIÓN SOLO CON ICONOS (-) REFRESH (+)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // RESTAR (-)
                                  Material(
                                    color: Colors.white,
                                    shape: const CircleBorder(
                                      side: BorderSide(
                                        color: Color(0xFFEFE8DF),
                                      ),
                                    ),
                                    child: IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.remove,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (item.vueltas > 0) {
                                            item.vueltas--;
                                          }
                                        });
                                        _guardarContadores();
                                      },
                                    ),
                                  ),

                                  // REINICIAR
                                  IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.black38,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        item.vueltas = 0;
                                      });
                                      _guardarContadores();
                                    },
                                  ),

                                  // SUMAR (+)
                                  Material(
                                    color: const Color(0xFFB85B35),
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          item.vueltas++;
                                        });
                                        _guardarContadores();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFAF7F2),
        foregroundColor: Colors.black,
        elevation: 3,
        onPressed: () => _mostrarDialogoContador(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDecorativeDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.local_florist, color: Colors.black, size: 20),
          ),
          const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
        ],
      ),
    );
  }
}
