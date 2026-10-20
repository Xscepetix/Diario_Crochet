// lib/screens/armario.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Lista {
  String titulo;
  List<String> imagenes;
  String estado;
  String descripcion;
  String presupuesto;
  Color colorEstado;

  Lista({
    required this.titulo,
    required this.imagenes,
    required this.estado,
    this.descripcion = '',
    this.presupuesto = '',
    required this.colorEstado,
  });

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'imagenes': imagenes,
    'estado': estado,
    'descripcion': descripcion,
    'presupuesto': presupuesto,
    'colorEstado': colorEstado.value,
  };

  factory Lista.fromJson(Map<String, dynamic> json) => Lista(
    titulo: json['titulo'],
    imagenes: List<String>.from(json['imagenes'] ?? []),
    estado: json['estado'],
    descripcion: json['descripcion'] ?? '',
    presupuesto: json['presupuesto'] ?? '',
    colorEstado: Color(json['colorEstado']),
  );
}

class Armario extends StatefulWidget {
  const Armario({super.key});

  @override
  State<Armario> createState() => _ArmarioState();
}

class _ArmarioState extends State<Armario> {
  List<Lista> _proyectos = [];
  bool _cargando = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarProyectos();
  }

  Future<void> _cargarProyectos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? datosString = prefs.getString('proyectos_armario');

    if (datosString != null && datosString.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(datosString);
      setState(() {
        _proyectos = jsonList.map((item) => Lista.fromJson(item)).toList();
        _cargando = false;
      });
    } else {
      setState(() {
        _proyectos = [
          Lista(
            titulo: 'Rosa',
            imagenes: [],
            estado: 'En proceso',
            descripcion:
                'Amigurumi de rosa tejido con hilo de algodon rojo y verde.',
            presupuesto: '15.00 €',
            colorEstado: Colors.orange,
          ),
        ];
        _cargando = false;
      });
      _guardarProyectos();
    }
  }

  Future<void> _guardarProyectos() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonList = jsonEncode(
      _proyectos.map((p) => p.toJson()).toList(),
    );
    await prefs.setString('proyectos_armario', jsonList);
  }

  Future<List<String>> _seleccionarFotos() async {
    final List<XFile> images = await _picker.pickMultiImage();
    return images.map((img) => img.path).toList();
  }

  void _mostrarFormularioNuevoProyecto() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final presController = TextEditingController();
    String estadoSeleccionado = 'En proceso';
    Color colorSeleccionado = Colors.orange;
    List<String> rutasImagenes = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Anadir nuevo proyecto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final paths = await _seleccionarFotos();
                        if (paths.isNotEmpty) {
                          setDialogState(() {
                            rutasImagenes.addAll(paths);
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: rutasImagenes.isNotEmpty
                            ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: rutasImagenes.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 100,
                                        child: _buildImagenWidget(
                                          rutasImagenes[index],
                                          permitirZoom: false,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 36,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Anadir fotos de galeria',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del proyecto',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion / Proceso',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: presController,
                      decoration: const InputDecoration(
                        labelText: 'Presupuesto (€)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: estadoSeleccionado,
                      items: const [
                        DropdownMenuItem(
                          value: 'Terminado',
                          child: Text('Terminado'),
                        ),
                        DropdownMenuItem(
                          value: 'En proceso',
                          child: Text('En proceso'),
                        ),
                        DropdownMenuItem(
                          value: 'Sin empezar',
                          child: Text('Sin empezar'),
                        ),
                      ],
                      onChanged: (value) {
                        estadoSeleccionado = value!;
                        if (value == 'Terminado') {
                          colorSeleccionado = Colors.green;
                        }
                        if (value == 'En proceso') {
                          colorSeleccionado = Colors.orange;
                        }
                        if (value == 'Sin empezar') {
                          colorSeleccionado = Colors.redAccent;
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Estado'),
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
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        _proyectos.add(
                          Lista(
                            titulo: titleController.text,
                            imagenes: rutasImagenes,
                            estado: estadoSeleccionado,
                            descripcion: descController.text,
                            presupuesto: presController.text,
                            colorEstado: colorSeleccionado,
                          ),
                        );
                      });
                      _guardarProyectos();
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
              'ARMARIO',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            _buildDecorativeDivider(),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: _proyectos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final proyecto = _proyectos[index];
                    return _buildProjectCard(proyecto, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: _mostrarFormularioNuevoProyecto,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectCard(Lista proyecto, int index) {
    final imagenPortada = proyecto.imagenes.isNotEmpty
        ? proyecto.imagenes.first
        : '';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final resultado = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleProyectoScreen(proyecto: proyecto),
          ),
        );

        if (resultado == 'eliminar') {
          setState(() {
            _proyectos.removeAt(index);
          });
          _guardarProyectos();
        } else {
          setState(() {});
          _guardarProyectos();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              proyecto.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImagenWidget(imagenPortada, permitirZoom: false),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: proyecto.colorEstado,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  proyecto.estado,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
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

Widget _buildImagenWidget(
  String rutaImagen, {
  double width = double.infinity,
  double height = double.infinity,
  bool permitirZoom = false,
}) {
  Widget imagenWidget;

  if (rutaImagen.isEmpty) {
    imagenWidget = Container(
      color: Colors.grey[300],
      width: width,
      height: height,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 40,
      ),
    );
  } else if (rutaImagen.startsWith('http')) {
    imagenWidget = Image.network(
      rutaImagen,
      fit: BoxFit.cover,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  } else {
    try {
      final file = File(rutaImagen);
      imagenWidget = Image.file(
        file,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } catch (e) {
      imagenWidget = Container(
        color: Colors.grey[300],
        width: width,
        height: height,
        child: const Icon(Icons.error, color: Colors.grey),
      );
    }
  }

  if (permitirZoom && rutaImagen.isNotEmpty) {
    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.8,
      maxScale: 4.0,
      child: imagenWidget,
    );
  }

  return imagenWidget;
}

class DetalleProyectoScreen extends StatefulWidget {
  final Lista proyecto;

  const DetalleProyectoScreen({super.key, required this.proyecto});

  @override
  State<DetalleProyectoScreen> createState() => _DetalleProyectoScreenState();
}

class _DetalleProyectoScreenState extends State<DetalleProyectoScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _descController;
  late TextEditingController _presupuestoController;
  late String _estadoSeleccionado;
  late Color _colorSeleccionado;
  late List<String> _rutasImagenes;
  bool _editando = false;
  int _paginaActual = 0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.proyecto.titulo);
    _descController = TextEditingController(text: widget.proyecto.descripcion);
    _presupuestoController = TextEditingController(
      text: widget.proyecto.presupuesto,
    );
    _estadoSeleccionado = widget.proyecto.estado;
    _colorSeleccionado = widget.proyecto.colorEstado;
    _rutasImagenes = List.from(widget.proyecto.imagenes);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    _presupuestoController.dispose();
    super.dispose();
  }

  Future<void> _anadirMasFotos() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _rutasImagenes.addAll(images.map((img) => img.path));
      });
    }
  }

  void _eliminarFotoActual(int index) {
    setState(() {
      _rutasImagenes.removeAt(index);
      if (_paginaActual >= _rutasImagenes.length && _paginaActual > 0) {
        _paginaActual--;
      }
    });
  }

  void _guardarCambios() {
    setState(() {
      widget.proyecto.titulo = _tituloController.text;
      widget.proyecto.descripcion = _descController.text;
      widget.proyecto.presupuesto = _presupuestoController.text;
      widget.proyecto.estado = _estadoSeleccionado;
      widget.proyecto.colorEstado = _colorSeleccionado;
      widget.proyecto.imagenes = _rutasImagenes;
      _editando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC099),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _editando ? 'Editar Proyecto' : 'Detalle del Proyecto',
          style: const TextStyle(color: Colors.black, fontFamily: 'serif'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _editando ? Icons.check : Icons.edit,
              color: Colors.black,
            ),
            onPressed: () {
              if (_editando) {
                _guardarCambios();
              } else {
                setState(() {
                  _editando = true;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Eliminar proyecto?'),
                  content: const Text('Esta accion no se puede deshacer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, 'eliminar');
                      },
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: _rutasImagenes.isNotEmpty
                    ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            itemCount: _rutasImagenes.length,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() {
                                _paginaActual = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 250,
                                      child: _buildImagenWidget(
                                        _rutasImagenes[index],
                                        permitirZoom: true,
                                      ),
                                    ),
                                  ),
                                  if (_editando)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white70,
                                        ),
                                        onPressed: () =>
                                            _eliminarFotoActual(index),
                                        tooltip: 'Eliminar esta foto',
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          if (_rutasImagenes.length > 1)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _rutasImagenes.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: _paginaActual == index ? 12 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _paginaActual == index
                                          ? Colors.black
                                          : Colors.black45,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            if (_editando)
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _anadirMasFotos,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Anadir mas fotos'),
                ),
              ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _editando ? _buildModoEdicion() : _buildModoVista(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModoVista() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.proyecto.titulo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.proyecto.colorEstado,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Estado: ${widget.proyecto.estado}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Presupuesto:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          widget.proyecto.presupuesto.isNotEmpty
              ? widget.proyecto.presupuesto
              : 'No especificado',
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 16),
        const Text(
          'Descripcion / Proceso:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          widget.proyecto.descripcion.isNotEmpty
              ? widget.proyecto.descripcion
              : 'Sin descripcion detallada.',
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildModoEdicion() {
    return Column(
      children: [
        TextField(
          controller: _tituloController,
          decoration: const InputDecoration(labelText: 'Titulo'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _estadoSeleccionado,
          items: const [
            DropdownMenuItem(value: 'Terminado', child: Text('Terminado')),
            DropdownMenuItem(value: 'En proceso', child: Text('En proceso')),
            DropdownMenuItem(value: 'Sin empezar', child: Text('Sin empezar')),
          ],
          onChanged: (value) {
            _estadoSeleccionado = value!;
            if (value == 'Terminado') _colorSeleccionado = Colors.green;
            if (value == 'En proceso') _colorSeleccionado = Colors.orange;
            if (value == 'Sin empezar') _colorSeleccionado = Colors.redAccent;
          },
          decoration: const InputDecoration(labelText: 'Estado'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _presupuestoController,
          decoration: const InputDecoration(labelText: 'Presupuesto'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descController,
          decoration: const InputDecoration(labelText: 'Descripcion / Proceso'),
          maxLines: 4,
        ),
      ],
    );
  }
}
