// lib/screens/presupuesto.dart
import 'package:flutter/material.dart';

class MaterialPresupuesto {
  String nombre;
  double precioCompra;
  double cantidadPaquete;
  double cantidadUsada;

  MaterialPresupuesto({
    required this.nombre,
    required this.precioCompra,
    required this.cantidadPaquete,
    required this.cantidadUsada,
  });

  double get costeUtilizado {
    if (cantidadPaquete == 0) return 0.0;
    return (precioCompra / cantidadPaquete) * cantidadUsada;
  }
}

class CalculadoraPresupuestoScreen extends StatefulWidget {
  const CalculadoraPresupuestoScreen({super.key});

  @override
  State<CalculadoraPresupuestoScreen> createState() =>
      _CalculadoraPresupuestoScreenState();
}

class _CalculadoraPresupuestoScreenState
    extends State<CalculadoraPresupuestoScreen> {
  final List<MaterialPresupuesto> _materiales = [
    MaterialPresupuesto(
      nombre: 'trapillo marron claro',
      precioCompra: 11.44,
      cantidadPaquete: 334.0,
      cantidadUsada: 10.0,
    ),
  ];

  final _horasController = TextEditingController(text: '1.45');
  final _precioHoraController = TextEditingController(text: '5.00');
  final _margenController = TextEditingController(text: '20');

  double get _totalMateriales {
    return _materiales.fold(0.0, (sum, item) => sum + item.costeUtilizado);
  }

  double get _horasDedicadas => double.tryParse(_horasController.text) ?? 0.0;
  double get _precioHora => double.tryParse(_precioHoraController.text) ?? 0.0;
  double get _totalManoObra => _horasDedicadas * _precioHora;

  double get _costeBase => _totalMateriales + _totalManoObra;

  double get _margenPorcentaje =>
      double.tryParse(_margenController.text) ?? 0.0;
  double get _importeBeneficio => _costeBase * (_margenPorcentaje / 100);

  double get _precioFinalRecomendado => _costeBase + _importeBeneficio;

  @override
  void dispose() {
    _horasController.dispose();
    _precioHoraController.dispose();
    _margenController.dispose();
    super.dispose();
  }

  void _mostrarDialogoMaterial({MaterialPresupuesto? material, int? index}) {
    final nombreCtrl = TextEditingController(text: material?.nombre ?? '');
    final precioCompraCtrl = TextEditingController(
      text: material?.precioCompra.toString() ?? '',
    );
    final cantidadPaqueteCtrl = TextEditingController(
      text: material?.cantidadPaquete.toString() ?? '',
    );
    final cantidadUsadaCtrl = TextEditingController(
      text: material?.cantidadUsada.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFAF7F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            material == null ? 'Anadir Material' : 'Editar Material',
            style: const TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFieldDialog(nombreCtrl, 'Material / Componente'),
                const SizedBox(height: 12),
                _buildTextFieldDialog(
                  precioCompraCtrl,
                  'Precio Compra (€)',
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                _buildTextFieldDialog(
                  cantidadPaqueteCtrl,
                  'Cantidad Paquete / Ovillo (gr/ud)',
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                _buildTextFieldDialog(
                  cantidadUsadaCtrl,
                  'Cantidad Usada (gr/ud)',
                  isNumber: true,
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
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                if (nombreCtrl.text.isNotEmpty) {
                  setState(() {
                    final mat = MaterialPresupuesto(
                      nombre: nombreCtrl.text,
                      precioCompra:
                          double.tryParse(precioCompraCtrl.text) ?? 0.0,
                      cantidadPaquete:
                          double.tryParse(cantidadPaqueteCtrl.text) ?? 1.0,
                      cantidadUsada:
                          double.tryParse(cantidadUsadaCtrl.text) ?? 0.0,
                    );

                    if (index != null) {
                      _materiales[index] = mat;
                    } else {
                      _materiales.add(mat);
                    }
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
  }

  Widget _buildTextFieldDialog(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        filled: true,
        fillColor: const Color(0xFFF0E5D8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'PRESUPUESTO',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildDecorativeDivider(),
              const SizedBox(height: 20),

              // SECCION 1: DESGLOSE DE MATERIALES
              _buildTituloSeccion('1. DESGLOSE DE MATERIALES'),
              const SizedBox(height: 10),
              ..._materiales.asMap().entries.map((entry) {
                final idx = entry.key;
                final mat = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6F0),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mat.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Comp: ${mat.precioCompra.toStringAsFixed(2)}€ | Paq: ${mat.cantidadPaquete} | Usado: ${mat.cantidadUsada}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${mat.costeUtilizado.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.black54,
                        ),
                        onPressed: () =>
                            _mostrarDialogoMaterial(material: mat, index: idx),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.black38,
                        ),
                        onPressed: () {
                          setState(() {
                            _materiales.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.black87),
                  onPressed: () => _mostrarDialogoMaterial(),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text(
                    'Anadir Material',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _buildTarjetaResumenSuave(
                'Subtotal Materiales',
                '${_totalMateriales.toStringAsFixed(2)} €',
              ),

              const SizedBox(height: 24),

              // SECCION 2: MANO DE OBRA
              _buildTituloSeccion('2. MANO DE OBRA'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildInputCampoSuave(
                      controller: _horasController,
                      label: 'Horas dedicadas (ej: 1.45 = 1h 27m)',
                      icon: Icons.access_time_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildInputCampoSuave(
                      controller: _precioHoraController,
                      label: 'Precio por hora (€/h)',
                      icon: Icons.euro_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildTarjetaResumenSuave(
                'Subtotal Mano de Obra',
                '${_totalManoObra.toStringAsFixed(2)} €',
              ),

              const SizedBox(height: 24),

              // SECCION 3: MARGEN Y RESULTADO FINAL
              _buildTituloSeccion('3. CALCULOS FINALES'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildFilaTextoSuave(
                      'Coste Base (Mat. + Mano Obra)',
                      '${_costeBase.toStringAsFixed(2)} €',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Colors.black12),
                    ),
                    _buildInputCampoSuave(
                      controller: _margenController,
                      label: 'Margen de Beneficio (%)',
                      icon: Icons.percent_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildFilaTextoSuave(
                      'Importe Beneficio Marca',
                      '${_importeBeneficio.toStringAsFixed(2)} €',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // TARJETA DE PRECIO FINAL DESTACADA PERO TRANQUILA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'PRECIO FINAL RECOMENDADO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_precioFinalRecomendado.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontFamily: 'serif',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInputCampoSuave({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.black54),
        prefixIcon: Icon(icon, size: 18, color: Colors.black54),
        filled: true,
        fillColor: const Color(0xFFF0E5D8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildTarjetaResumenSuave(String label, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E5D8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaTextoSuave(
    String label,
    String valor, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFFB85B35) : Colors.black87,
          ),
        ),
      ],
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
