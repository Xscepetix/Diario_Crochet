// lib/screens/materiales_faltantes.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialFaltanteItem {
  String nombre;
  int cantidad;
  String? imagenPath;

  MaterialFaltanteItem({
    required this.nombre,
    required this.cantidad,
    this.imagenPath,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'cantidad': cantidad,
    'imagenPath': imagenPath,
  };

  factory MaterialFaltanteItem.fromJson(Map<String, dynamic> json) =>
      MaterialFaltanteItem(
        nombre: json['nombre'],
        cantidad: json['cantidad'] ?? 1,
        imagenPath: json['imagenPath'],
      );
}

class MaterialesFaltantesScreen extends StatefulWidget {
  const MaterialesFaltantesScreen({super.key});

  @override
  State<MaterialesFaltantesScreen> createState() =>
      _MaterialesFaltantesScreenState();
}

class _MaterialesFaltantesScreenState extends State<MaterialesFaltantesScreen> {
  List<MaterialFaltanteItem> _materiales = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? datosString = prefs.getString('materiales_faltantes_lista');

    if (datosString != null && datosString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(datosString);
      setState(() {
        _materiales = jsonList
            .map((item) => MaterialFaltanteItem.fromJson(item))
            .toList();
        _cargando = false;
      });
    } else {
      setState(() {
        _materiales = [
          MaterialFaltanteItem(nombre: 'Lana negra 3mm', cantidad: 2),
          MaterialFaltanteItem(nombre: 'Marcadores', cantidad: 1),
          MaterialFaltanteItem(nombre: 'Lana azul cielo 3mm', cantidad: 1),
        ];
        _cargando = false;
      });
      _guardarDatos();
    }
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonList = jsonEncode(
      _materiales.map((m) => m.toJson()).toList(),
    );
    await prefs.setString('materiales_faltantes_lista', jsonList);
  }

  void _mostrarDialogo({MaterialFaltanteItem? item, int? index}) {
    final controller = TextEditingController(text: item?.nombre ?? '');
    int cantidadActual = item?.cantidad ?? 1;
    String? imagenSeleccionada = item?.imagenPath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(item == null ? 'Nuevo material' : 'Editar material'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Selector de Imagen Circular
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setDialogState(() {
                            imagenSeleccionada = pickedFile.path;
                          });
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.black12,
                            backgroundImage: imagenSeleccionada != null
                                ? FileImage(File(imagenSeleccionada!))
                                      as ImageProvider
                                : null,
                            child: imagenSeleccionada == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 28,
                                    color: Colors.black54,
                                  )
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del material',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cantidad (ud):'),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (cantidadActual > 1) {
                                  setDialogState(() => cantidadActual--);
                                }
                              },
                            ),
                            Text(
                              '$cantidadActual',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setDialogState(() => cantidadActual++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC099),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        if (index != null) {
                          _materiales[index].nombre = controller.text;
                          _materiales[index].cantidad = cantidadActual;
                          _materiales[index].imagenPath = imagenSeleccionada;
                        } else {
                          _materiales.add(
                            MaterialFaltanteItem(
                              nombre: controller.text,
                              cantidad: cantidadActual,
                              imagenPath: imagenSeleccionada,
                            ),
                          );
                        }
                      });
                      _guardarDatos();
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

  void _cambiarCantidad(int index, int delta) {
    setState(() {
      _materiales[index].cantidad += delta;
      if (_materiales[index].cantidad < 0) {
        _materiales[index].cantidad = 0;
      }
    });
    _guardarDatos();
  }

  void _eliminar(int index) {
    setState(() {
      _materiales.removeAt(index);
    });
    _guardarDatos();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFC099),
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

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
              'MATERIALES FALTANTES',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            _buildDecorativeDivider(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _materiales.length,
                itemBuilder: (context, index) {
                  final item = _materiales[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(40), // Estilo estadio
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Imagen miniatura a la izquierda (como en tu plantilla)
                        GestureDetector(
                          onTap: () =>
                              _mostrarDialogo(item: item, index: index),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.black12,
                            backgroundImage: item.imagenPath != null
                                ? FileImage(File(item.imagenPath!))
                                      as ImageProvider
                                : null,
                            child: item.imagenPath == null
                                ? const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 20,
                                    color: Colors.black54,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nombre del material
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _mostrarDialogo(item: item, index: index),
                            child: Text(
                              item.nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Cantidad y botones - / +
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.cantidad} ud.',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Boton menos
                            InkWell(
                              onTap: () => _cambiarCantidad(index, -1),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFC099),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Boton mas
                            InkWell(
                              onTap: () => _cambiarCantidad(index, 1),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFC099),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            // Menu de opciones
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 18,
                                color: Colors.black54,
                              ),
                              onSelected: (val) {
                                if (val == 'editar') {
                                  _mostrarDialogo(item: item, index: index);
                                } else if (val == 'eliminar') {
                                  _eliminar(index);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Text('Editar'),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Text('Eliminar'),
                                ),
                              ],
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _mostrarDialogo(),
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
