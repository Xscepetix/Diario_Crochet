// lib/screens/armario.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProyectoArmario {
  String id;
  String titulo;
  List<String> imagenes; // Lista con varias fotos
  String categoria;
  String estado;
  String descripcion;
  String patron;
  String materiales;
  String tiempo;
  double presupuesto;

  ProyectoArmario({
    required this.id,
    required this.titulo,
    List<String>? imagenes,
    this.categoria = 'Flores',
    this.estado = 'En proceso',
    this.descripcion = '',
    this.patron = '',
    this.materiales = '',
    this.tiempo = '',
    this.presupuesto = 0.0,
  }) : imagenes = imagenes ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'imagenes': imagenes,
    'categoria': categoria,
    'estado': estado,
    'descripcion': descripcion,
    'patron': patron,
    'materiales': materiales,
    'tiempo': tiempo,
    'presupuesto': presupuesto,
  };

  factory ProyectoArmario.fromJson(Map<String, dynamic> json) =>
      ProyectoArmario(
        id: json['id'],
        titulo: json['titulo'],
        imagenes: json['imagenes'] != null
            ? List<String>.from(json['imagenes'])
            : (json['imagePath'] != null
                  ? [json['imagePath']]
                  : []), // Compatibilidad con versiones anteriores
        categoria: json['categoria'] ?? 'Flores',
        estado: json['estado'] ?? 'En proceso',
        descripcion: json['descripcion'] ?? '',
        patron: json['patron'] ?? '',
        materiales: json['materiales'] ?? '',
        tiempo: json['tiempo'] ?? '',
        presupuesto: (json['presupuesto'] ?? 0.0).toDouble(),
      );
}

class Armario extends StatefulWidget {
  const Armario({super.key});

  @override
  State<Armario> createState() => _ArmarioState();
}

class _ArmarioState extends State<Armario> {
  List<ProyectoArmario> _proyectos = [];
  String _categoriaSeleccionada = 'Todas';

  final List<String> _categoriasDisponibles = [
    'Todas',
    'Flores',
    'Amigurumis',
    'Decoracion',
    'Ropa',
    'Otros',
  ];

  final List<String> _estadosDisponibles = [
    'En proceso',
    'Terminado',
    'Pausado',
  ];

  @override
  void initState() {
    super.initState();
    _cargarProyectos();
  }

  Future<void> _cargarProyectos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? proyectosString = prefs.getString('armario_proyectos');
    if (proyectosString != null) {
      final List<dynamic> decoded = jsonDecode(proyectosString);
      setState(() {
        _proyectos = decoded
            .map((item) => ProyectoArmario.fromJson(item))
            .toList();
      });
    }
  }

  Future<void> _guardarProyectos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _proyectos.map((p) => p.toJson()).toList(),
    );
    await prefs.setString('armario_proyectos', encoded);
  }

  List<ProyectoArmario> get _proyectosFiltrados {
    if (_categoriaSeleccionada == 'Todas') {
      return _proyectos;
    }
    return _proyectos
        .where((p) => p.categoria == _categoriaSeleccionada)
        .toList();
  }

  void _mostrarDialogoNuevoProyecto() {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final patronCtrl = TextEditingController();
    final matCtrl = TextEditingController();
    final tiempoCtrl = TextEditingController();
    final presCtrl = TextEditingController();

    List<String> tempImagenes = [];
    String tempCategoria = 'Flores';
    String tempEstado = 'En proceso';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void guardarNuevo() {
              if (tituloCtrl.text.isNotEmpty) {
                double presupuestoVal = double.tryParse(presCtrl.text) ?? 0.0;
                setState(() {
                  _proyectos.add(
                    ProyectoArmario(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      titulo: tituloCtrl.text,
                      imagenes: tempImagenes,
                      categoria: tempCategoria,
                      estado: tempEstado,
                      descripcion: descCtrl.text,
                      patron: patronCtrl.text,
                      materiales: matCtrl.text,
                      tiempo: tiempoCtrl.text,
                      presupuesto: presupuestoVal,
                    ),
                  );
                });
                _guardarProyectos();
                Navigator.pop(context);
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFFAF7F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Nuevo Proyecto',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // GALERIA DE FOTOS TEMPORAL EN DIALOGO
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tempImagenes.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0E5D8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Colors.black54,
                                  size: 30,
                                ),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (pickedFile != null) {
                                    setDialogState(() {
                                      tempImagenes.add(pickedFile.path);
                                    });
                                  }
                                },
                              ),
                            );
                          }
                          final fotoIndex = index - 1;
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(tempImagenes[fotoIndex]),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      tempImagenes.removeAt(fotoIndex);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tituloCtrl,
                      decoration: InputDecoration(
                        labelText: 'Titulo del proyecto',
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
                      controller: patronCtrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Patron / Diseno',
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
                      controller: matCtrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Materiales usados',
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
                      controller: tiempoCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tiempo invertido (ej: 8 horas)',
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
                      controller: descCtrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Notas / Descripcion',
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
                      controller: presCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Presupuesto (€)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tempCategoria,
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _categoriasDisponibles
                          .where((c) => c != 'Todas')
                          .map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          })
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            tempCategoria = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tempEstado,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _estadosDisponibles.map((est) {
                        return DropdownMenuItem(value: est, child: Text(est));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            tempEstado = val;
                          });
                        }
                      },
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
                  onPressed: guardarNuevo,
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _abrirDetalleProyecto(ProyectoArmario proyecto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleProyectoScreen(
          proyecto: proyecto,
          categoriasDisponibles: _categoriasDisponibles
              .where((c) => c != 'Todas')
              .toList(),
          estadosDisponibles: _estadosDisponibles,
          onGuardarCambios: () {
            _guardarProyectos();
            setState(() {});
          },
          onEliminar: () {
            setState(() {
              _proyectos.removeWhere((p) => p.id == proyecto.id);
            });
            _guardarProyectos();
          },
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final listaActual = _proyectosFiltrados;

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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            _buildDecorativeDivider(),
            const SizedBox(height: 14),

            // CATEGORIAS HORIZONTALES
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categoriasDisponibles.length,
                itemBuilder: (context, index) {
                  final cat = _categoriasDisponibles[index];
                  final esSeleccionada = cat == _categoriaSeleccionada;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: esSeleccionada ? Colors.white : Colors.black87,
                          fontWeight: esSeleccionada
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      selected: esSeleccionada,
                      selectedColor: const Color(0xFFB85B35),
                      backgroundColor: const Color(0xFFFAF7F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _categoriaSeleccionada = cat;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // LISTA DE PROYECTOS
            Expanded(
              child: listaActual.isEmpty
                  ? Center(
                      child: Text(
                        _categoriaSeleccionada == 'Todas'
                            ? 'No hay proyectos en el armario'
                            : 'No hay proyectos en "$_categoriaSeleccionada"',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: listaActual.length,
                      itemBuilder: (context, index) {
                        final item = listaActual[index];
                        return GestureDetector(
                          onTap: () => _abrirDetalleProyecto(item),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
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
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 65,
                                    height: 65,
                                    color: const Color(0xFFF0E5D8),
                                    child: item.imagenes.isNotEmpty
                                        ? Image.file(
                                            File(item.imagenes.first),
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.palette_outlined,
                                            color: Colors.black38,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.titulo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0E5D8),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              item.categoria,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: item.estado == 'Terminado'
                                                  ? Colors.green.shade100
                                                  : Colors.amber.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              item.estado,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    item.estado == 'Terminado'
                                                    ? Colors.green.shade800
                                                    : Colors.amber.shade900,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
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
        onPressed: () => _mostrarDialogoNuevoProyecto(),
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

// PANTALLA DE DETALLE CON GALERIA MULTIPLE Y EDICION EN MISMA PANTALLA
class DetalleProyectoScreen extends StatefulWidget {
  final ProyectoArmario proyecto;
  final List<String> categoriasDisponibles;
  final List<String> estadosDisponibles;
  final VoidCallback onGuardarCambios;
  final VoidCallback onEliminar;

  const DetalleProyectoScreen({
    super.key,
    required this.proyecto,
    required this.categoriasDisponibles,
    required this.estadosDisponibles,
    required this.onGuardarCambios,
    required this.onEliminar,
  });

  @override
  State<DetalleProyectoScreen> createState() => _DetalleProyectoScreenState();
}

class _DetalleProyectoScreenState extends State<DetalleProyectoScreen> {
  bool _editando = false;

  late TextEditingController _tituloCtrl;
  late TextEditingController _patronCtrl;
  late TextEditingController _matCtrl;
  late TextEditingController _tiempoCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _presCtrl;

  late String _tempCategoria;
  late String _tempEstado;
  late List<String> _tempImagenes;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    _tituloCtrl = TextEditingController(text: widget.proyecto.titulo);
    _patronCtrl = TextEditingController(text: widget.proyecto.patron);
    _matCtrl = TextEditingController(text: widget.proyecto.materiales);
    _tiempoCtrl = TextEditingController(text: widget.proyecto.tiempo);
    _descCtrl = TextEditingController(text: widget.proyecto.descripcion);
    _presCtrl = TextEditingController(
      text: widget.proyecto.presupuesto > 0
          ? widget.proyecto.presupuesto.toString()
          : '',
    );

    _tempCategoria = widget.proyecto.categoria;
    _tempEstado = widget.proyecto.estado;
    _tempImagenes = List.from(widget.proyecto.imagenes);
  }

  void _guardarFormulario() {
    setState(() {
      widget.proyecto.titulo = _tituloCtrl.text;
      widget.proyecto.patron = _patronCtrl.text;
      widget.proyecto.materiales = _matCtrl.text;
      widget.proyecto.tiempo = _tiempoCtrl.text;
      widget.proyecto.descripcion = _descCtrl.text;
      widget.proyecto.presupuesto = double.tryParse(_presCtrl.text) ?? 0.0;
      widget.proyecto.categoria = _tempCategoria;
      widget.proyecto.estado = _tempEstado;
      widget.proyecto.imagenes = List.from(_tempImagenes);

      _editando = false;
    });

    widget.onGuardarCambios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (!_editando) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black87),
              onPressed: () {
                setState(() {
                  _editando = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black54),
              onPressed: () {
                widget.onEliminar();
                Navigator.pop(context);
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () {
                setState(() {
                  _cargarDatos();
                  _editando = false;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _guardarFormulario,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GALERIA DE FOTOS EN DETALLE (CARRUSEL O GRILLA HORIZONTAL)
            SizedBox(
              height: 200,
              child: _tempImagenes.isEmpty
                  ? Center(
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E5D8),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.palette_outlined,
                          color: Colors.black38,
                          size: 60,
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tempImagenes.length + (_editando ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_editando && index == 0) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E5D8),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.black54,
                              ),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (pickedFile != null) {
                                  setState(() {
                                    _tempImagenes.add(pickedFile.path);
                                  });
                                }
                              },
                            ),
                          );
                        }

                        final fotoIndex = _editando ? index - 1 : index;
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: FileImage(File(_tempImagenes[fotoIndex])),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              if (_editando)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tempImagenes.removeAt(fotoIndex);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // TITULO
            if (!_editando)
              Text(
                widget.proyecto.titulo,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
            else
              TextField(
                controller: _tituloCtrl,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Titulo del proyecto',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ETIQUETAS O DROPDOWNS
            if (!_editando)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8B498),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.proyecto.categoria,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.proyecto.estado == 'Terminado'
                          ? Colors.green.shade100
                          : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.proyecto.estado,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: widget.proyecto.estado == 'Terminado'
                            ? Colors.green.shade800
                            : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _tempCategoria,
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: widget.categoriasDisponibles.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _tempCategoria = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _tempEstado,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: widget.estadosDisponibles.map((est) {
                        return DropdownMenuItem(value: est, child: Text(est));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _tempEstado = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // SECCIONES CON SOPORTE DE SALTO DE LINEA (ENTER)
            _buildCampoSeccion(
              icono: Icons.book_outlined,
              titulo: 'Patron / Diseno',
              controller: _patronCtrl,
              valorTexto: widget.proyecto.patron,
              placeholder: 'Sin patron especificado',
              maxLines: null,
            ),
            _buildCampoSeccion(
              icono: Icons.inventory_2_outlined,
              titulo: 'Materiales',
              controller: _matCtrl,
              valorTexto: widget.proyecto.materiales,
              placeholder: 'Sin materiales especificados',
              maxLines: null,
            ),
            _buildCampoSeccion(
              icono: Icons.timer_outlined,
              titulo: 'Tiempo invertido',
              controller: _tiempoCtrl,
              valorTexto: widget.proyecto.tiempo,
              placeholder: 'Sin tiempo especificado',
            ),
            _buildCampoSeccion(
              icono: Icons.euro_outlined,
              titulo: 'Presupuesto (€)',
              controller: _presCtrl,
              valorTexto: widget.proyecto.presupuesto > 0
                  ? '${widget.proyecto.presupuesto.toStringAsFixed(2)} €'
                  : '',
              placeholder: '0.00 €',
              isNumber: true,
            ),
            _buildCampoSeccion(
              icono: Icons.notes_outlined,
              titulo: 'Notas y Descripcion',
              controller: _descCtrl,
              valorTexto: widget.proyecto.descripcion,
              placeholder: 'Sin descripcion',
              maxLines: null,
            ),

            if (_editando) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B498),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Guardar Cambios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _guardarFormulario,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCampoSeccion({
    required IconData icono,
    required String titulo,
    required TextEditingController controller,
    required String valorTexto,
    required String placeholder,
    int? maxLines = 1,
    bool isNumber = false,
  }) {
    if (!_editando && valorTexto.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: const Color(0xFFB85B35), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 6),
                if (!_editando)
                  Text(
                    valorTexto.isNotEmpty ? valorTexto : placeholder,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  )
                else
                  TextField(
                    controller: controller,
                    maxLines: maxLines,
                    keyboardType: isNumber
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : (maxLines == null
                              ? TextInputType.multiline
                              : TextInputType.text),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAF7F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
