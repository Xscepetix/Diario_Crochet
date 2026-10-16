import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Lista {
  String titulo;
  String imagen; // Puede ser ruta local de archivo o URL
  String estado;
  String descripcion;
  String presupuesto;
  Color colorEstado;

  Lista({
    required this.titulo,
    required this.imagen,
    required this.estado,
    this.descripcion = '',
    this.presupuesto = '',
    required this.colorEstado,
  });
}

class Armario extends StatefulWidget {
  const Armario({super.key});

  @override
  State<Armario> createState() => _ArmarioState();
}

class _ArmarioState extends State<Armario> {
  final List<Lista> _proyectos = [
    Lista(
      titulo: 'Rosa',
      imagen: '',
      estado: 'En proceso',
      descripcion: 'Amigurumi de rosa tejido con hilo de algodón rojo y verde.',
      presupuesto: '15.00 €',
      colorEstado: Colors.orange,
    ),
  ];

  final ImagePicker _picker = ImagePicker();

  // Función para seleccionar imagen desde la galería
  Future<String?> _seleccionarFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  // AÑADIR NUEVO PROYECTO
  void _mostrarFormularioNuevoProyecto() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final presController = TextEditingController();
    String estadoSeleccionado = 'En proceso';
    Color colorSeleccionado = Colors.orange;
    String rutaImagen = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Añadir nuevo proyecto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Previsualización y botón de seleccionar foto
                    GestureDetector(
                      onTap: () async {
                        final path = await _seleccionarFoto();
                        if (path != null) {
                          setDialogState(() {
                            rutaImagen = path;
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
                        child: rutaImagen.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(rutaImagen),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
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
                                    'Añadir foto desde galería',
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
                        labelText: 'Descripción / Proceso',
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
                        if (value == 'Terminado')
                          colorSeleccionado = Colors.green;
                        if (value == 'En proceso')
                          colorSeleccionado = Colors.orange;
                        if (value == 'Sin empezar')
                          colorSeleccionado = Colors.redAccent;
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
                            imagen: rutaImagen,
                            estado: estadoSeleccionado,
                            descripcion: descController.text,
                            presupuesto: presController.text,
                            colorEstado: colorSeleccionado,
                          ),
                        );
                      });
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
        } else {
          setState(() {}); // Actualizar cambios al volver
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
                child: _buildImagenWidget(proyecto.imagen),
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

// Helper para cargar imagen local o de red
Widget _buildImagenWidget(
  String rutaImagen, {
  double width = double.infinity,
  double height = double.infinity,
}) {
  if (rutaImagen.isEmpty) {
    return Container(
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
    return Image.network(
      rutaImagen,
      fit: BoxFit.cover,
      width: width,
      height: height,
    );
  } else {
    return Image.file(
      File(rutaImagen),
      fit: BoxFit.cover,
      width: width,
      height: height,
    );
  }
}

// =========================================================
// PANTALLA DE DETALLE Y EDICIÓN CON CAMBIO DE FOTO
// =========================================================
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
  late String _rutaImagen;
  bool _editando = false;

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
    _rutaImagen = widget.proyecto.imagen;
  }

  Future<void> _cambiarFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _rutaImagen = image.path;
      });
    }
  }

  void _guardarCambios() {
    setState(() {
      widget.proyecto.titulo = _tituloController.text;
      widget.proyecto.descripcion = _descController.text;
      widget.proyecto.presupuesto = _presupuestoController.text;
      widget.proyecto.estado = _estadoSeleccionado;
      widget.proyecto.colorEstado = _colorSeleccionado;
      widget.proyecto.imagen = _rutaImagen;
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
                  content: const Text('Esta acción no se puede deshacer.'),
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
            // Imagen principal con botón para cambiar si está en modo edición
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: _buildImagenWidget(_rutaImagen),
                    ),
                  ),
                  if (_editando)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        onPressed: _cambiarFoto,
                        child: const Icon(Icons.photo_camera),
                      ),
                    ),
                ],
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
          'Descripción / Proceso:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          widget.proyecto.descripcion.isNotEmpty
              ? widget.proyecto.descripcion
              : 'Sin descripción detallada.',
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
          decoration: const InputDecoration(labelText: 'Título'),
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
          decoration: const InputDecoration(labelText: 'Descripción / Proceso'),
          maxLines: 4,
        ),
      ],
    );
  }
}
