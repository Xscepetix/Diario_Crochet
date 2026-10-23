// lib/screens/materiales.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemMaterial {
  String id;
  String nombre;
  String tipo; // Ej: Hilo, Aguja, Relleno, Accesorio
  String color;
  int cantidad;
  String notas;
  String? imagePath;

  ItemMaterial({
    required this.id,
    required this.nombre,
    this.tipo = 'Hilo',
    this.color = '',
    this.cantidad = 1,
    this.notas = '',
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'tipo': tipo,
    'color': color,
    'cantidad': cantidad,
    'notas': notas,
    'imagePath': imagePath,
  };

  factory ItemMaterial.fromJson(Map<String, dynamic> json) => ItemMaterial(
    id: json['id'],
    nombre: json['nombre'],
    tipo: json['tipo'] ?? 'Hilo',
    color: json['color'] ?? '',
    cantidad: json['cantidad'] ?? 1,
    notas: json['notas'] ?? '',
    imagePath: json['imagePath'],
  );
}

class MaterialesScreen extends StatefulWidget {
  const MaterialesScreen({super.key});

  @override
  State<MaterialesScreen> createState() => _MaterialesScreenState();
}

class _MaterialesScreenState extends State<MaterialesScreen> {
  List<ItemMaterial> _materiales = [];
  String _busqueda = '';
  String _filtroTipo = 'Todos';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _tiposDisponibles = [
    'Todos',
    'Hilo',
    'Lana',
    'Aguja',
    'Relleno',
    'Accesorios',
  ];

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarMateriales() async {
    final prefs = await SharedPreferences.getInstance();
    final String? matString = prefs.getString('inventario_materiales');
    if (matString != null) {
      final List<dynamic> decoded = jsonDecode(matString);
      setState(() {
        _materiales = decoded
            .map((item) => ItemMaterial.fromJson(item))
            .toList();
      });
    }
  }

  Future<void> _guardarMateriales() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _materiales.map((m) => m.toJson()).toList(),
    );
    await prefs.setString('inventario_materiales', encoded);
  }

  // LISTA FILTRADA POR BÚSQUEDA Y POR CATEGORÍA
  List<ItemMaterial> get _materialesFiltrados {
    return _materiales.where((item) {
      final coincideTipo = _filtroTipo == 'Todos' || item.tipo == _filtroTipo;

      final query = _busqueda.toLowerCase();
      final coincideBusqueda =
          _busqueda.isEmpty ||
          item.nombre.toLowerCase().contains(query) ||
          item.color.toLowerCase().contains(query) ||
          item.notas.toLowerCase().contains(query);

      return coincideTipo && coincideBusqueda;
    }).toList();
  }

  void _mostrarDialogoMaterial({ItemMaterial? material}) {
    final nombreCtrl = TextEditingController(text: material?.nombre ?? '');
    final colorCtrl = TextEditingController(text: material?.color ?? '');
    final cantCtrl = TextEditingController(
      text: material != null ? material.cantidad.toString() : '1',
    );
    final notasCtrl = TextEditingController(text: material?.notas ?? '');
    String tempTipo = material?.tipo ?? 'Hilo';
    String? tempImagePath = material?.imagePath;

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
                material == null ? 'Nuevo Material' : 'Editar Material',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SELECTOR DE FOTO DEL MATERIAL
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setDialogState(() {
                            tempImagePath = pickedFile.path;
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E5D8),
                          borderRadius: BorderRadius.circular(16),
                          image: tempImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(tempImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: tempImagePath == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.black54,
                                    size: 30,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Añadir foto del material',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setDialogState(() {
                                          tempImagePath = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nombreCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre / Marca',
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
                      value: tempTipo,
                      decoration: InputDecoration(
                        labelText: 'Tipo de material',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _tiposDisponibles
                          .where((t) => t != 'Todos')
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            tempTipo = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: colorCtrl,
                      decoration: InputDecoration(
                        labelText: 'Color / Codigo de lote',
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
                      controller: cantCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cantidad / Ovillos',
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
                      controller: notasCtrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Notas adicionales',
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
                    if (nombreCtrl.text.isNotEmpty) {
                      final c = int.tryParse(cantCtrl.text) ?? 1;
                      setState(() {
                        if (material == null) {
                          _materiales.add(
                            ItemMaterial(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              nombre: nombreCtrl.text,
                              tipo: tempTipo,
                              color: colorCtrl.text,
                              cantidad: c,
                              notas: notasCtrl.text,
                              imagePath: tempImagePath,
                            ),
                          );
                        } else {
                          material.nombre = nombreCtrl.text;
                          material.tipo = tempTipo;
                          material.color = colorCtrl.text;
                          material.cantidad = c;
                          material.notas = notasCtrl.text;
                          material.imagePath = tempImagePath;
                        }
                      });
                      _guardarMateriales();
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
    final listaAmostrar = _materialesFiltrados;

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
              'MATERIALES',
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

            // BARRA DE BÚSQUEDA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _busqueda = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar hilo, aguja o color...',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFB85B35),
                  ),
                  suffixIcon: _busqueda.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.black38,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _busqueda = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFFAF7F2),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // FILTROS RÁPIDOS POR CATEGORÍA
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tiposDisponibles.length,
                itemBuilder: (context, index) {
                  final t = _tiposDisponibles[index];
                  final esSel = t == _filtroTipo;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        t,
                        style: TextStyle(
                          color: esSel ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: esSel
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: esSel,
                      selectedColor: const Color(0xFFB85B35),
                      backgroundColor: const Color(0xFFFAF7F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide.none,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _filtroTipo = t;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // LISTA DE MATERIALES CON FOTO Y CONTADOR DIRECTO COMPACTADO
            Expanded(
              child: listaAmostrar.isEmpty
                  ? Center(
                      child: Text(
                        _busqueda.isNotEmpty
                            ? 'No se encontraron materiales'
                            : 'Tu inventario de materiales está vacío',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: listaAmostrar.length,
                      itemBuilder: (context, index) {
                        final item = listaAmostrar[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFEFE8DF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // IMAGEN O ICONO DEL MATERIAL
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  color: const Color(0xFFF0E5D8),
                                  child:
                                      item.imagePath != null &&
                                          item.imagePath!.isNotEmpty
                                      ? Image.file(
                                          File(item.imagePath!),
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          _obtenerIconoMaterial(item.tipo),
                                          color: const Color(0xFFB85B35),
                                          size: 20,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (item.color.isNotEmpty) ...[
                                          Text(
                                            'Color: ${item.color}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const Text(
                                            ' • ',
                                            style: TextStyle(
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                        Text(
                                          item.tipo,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFFB85B35),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // CONTADOR DIRECTO (- cantidad +)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (item.cantidad > 0) {
                                          item.cantidad--;
                                        }
                                      });
                                      _guardarMateriales();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF7F2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFEFE8DF),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        size: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Text(
                                      '${item.cantidad}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF2C221E),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        item.cantidad++;
                                      });
                                      _guardarMateriales();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFB85B35),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 6),

                              // BOTONES EDITAR Y BORRAR (MÁS JUNTOS Y HACIA LA DERECHA)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(2),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.black45,
                                      size: 17,
                                    ),
                                    onPressed: () =>
                                        _mostrarDialogoMaterial(material: item),
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(2),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.black38,
                                      size: 17,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _materiales.removeWhere(
                                          (m) => m.id == item.id,
                                        );
                                      });
                                      _guardarMateriales();
                                    },
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
        onPressed: () => _mostrarDialogoMaterial(),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _obtenerIconoMaterial(String tipo) {
    switch (tipo) {
      case 'Aguja':
        return Icons.edit;
      case 'Lana':
      case 'Hilo':
        return Icons.texture;
      case 'Relleno':
        return Icons.cloud_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
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
