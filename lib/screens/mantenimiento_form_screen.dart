// lib/screens/mantenimiento_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formateo de fechas
import 'package:flutter/services.dart' show rootBundle; // Importar para leer assets
import 'package:image_picker/image_picker.dart'; // Importación para seleccionar imágenes/videos
import 'dart:typed_data'; // <-- CAMBIO: Importar para Uint8List
import 'dart:io'; // <-- CAMBIO: Importar para File. Útil para mostrar imágenes en móvil/desktop.
import 'package:flutter/foundation.dart' show kIsWeb; // <-- CAMBIO: Para saber si estamos en web

// ¡Nuevas importaciones para PDF y compartir!
import 'package:printing/printing.dart'; // <-- NUEVO: Para previsualizar/imprimir PDF
import 'package:pdf/pdf.dart'; // <-- NUEVO: Para PdfPageFormat
import '../utils/pdf_generator.dart'; // <-- NUEVO: Importa tu generador de PDF
import 'package:path_provider/path_provider.dart'; // <-- NUEVO: Para guardar archivos en el dispositivo
import 'package:share_plus/share_plus.dart'; // <-- NUEVO: Para compartir archivos

import '../models/mantenimiento_registro.dart'; // Importa tu modelo de datos

class MantenimientoFormScreen extends StatefulWidget {
  const MantenimientoFormScreen({super.key});

  @override
  State<MantenimientoFormScreen> createState() => _MantenimientoFormScreenState();
}

class _MantenimientoFormScreenState extends State<MantenimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descripcionUbicacionController = TextEditingController();
  final TextEditingController _tiempoEstimadoController = TextEditingController();
  final List<String> _horas = List.generate(24, (i) => i.toString().padLeft(2, '0'));
  final List<String> _minutos = ['00', '30'];

  // Instancia del modelo para guardar los datos
  late MantenimientoRegistro _mantenimientoRegistro;

  // Variables de estado para los campos del formulario
  // 2. Datos Generales
  String _plantaSeleccionada = '';
  String _fecha = '';
  String _realizadoPorSeleccionado = '';
  String _ayudanteSeleccionado = 'Ninguno';
  String _orden = '';

  // 3. Información del Equipo
  String _areaSeleccionada = '';
  String _ubicacionTecnicaSeleccionada = '';
  String _descripcionUbicacion = '';

  // 4. Detalles del Mantenimiento
  final Map<String, bool> _tipoMantenimientoCheckboxes = {
    'Correctivo': false,
    'Preventivo': false,
    'Proactivo': false,
    'Predictivo': false,
  };
  String _condicionEncontrada = '';
  final Map<String, bool> _estadoEquipoCheckboxes = {
    'Bueno': false,
    'Aceptable': false,
    'Regular': false,
  };
  String _existeAveria = 'No';

  // 5. Descripción del Problema o Motivo de la Intervención
  String _descripcionProblema = '';

  // 6. Acciones Realizadas
  final Map<String, bool> _accionesRealizadasCheckboxes = {
    'Limpieza': false,
    'Lubricación': false,
    'Reemplazo de componentes por daño': false,
    'Reemplazo de componentes desgastados': false,
    'Ajuste específico': false,
    'Reparación': false,
    'Otro': false,
  };
  String _otroAccionTexto = '';
  String _horaInicio = '';
  String _horaFin = '';
  String _tiempoEstimado = '';
  String _descripcionActividades = '';

  // 7. Evidencia (rutas de los archivos seleccionados)
  // CAMBIO: Ahora son acumulativas
  List<Uint8List> _fotosBytes = [];

  // NUEVO: Variables para mostrar las rutas/URLs en la UI
  List<String> _fotosDisplayPaths = [];

  // 8. Evaluación Técnica
  String _condicionFinalEquipo = '';
  String _requiereSeguimiento = 'No';
  String _detalleSeguimiento = '';

  // 9. Recomendaciones
  String _accionesSugeridas = '';

  // Listas de opciones estáticas (para Spinners/Dropdowns)
  final List<String> _plantas = [
    'Energía & Planta de Fuerza', 'Pulpapel', 'Molino 1', 'Molino 3',
    'Molino 4', 'Molino 6', 'FEC', 'Recuperación',
  ];
  final List<String> _realizadoPor = [
    'Robinson Montoya', 'Carlos Salcedo', 'Samir Ramirez',
    'William Garzon', 'Daniel Franco', 'Camilo Ayala',
    'Francisco Dagua', 'Alvaro Molina', 'Erick V. Leon', 'Juan C. Reina',
  ];
  final List<String> _ayudantes = [
    'Ninguno', 'Robinson Montoya', 'Carlos Salcedo', 'Samir Ramirez',
    'William Garzon', 'Daniel Franco', 'Camilo Ayala',
    'Francisco Dagua', 'Alvaro Molina', 'Erick V. Leon', 'Juan C. Reina',
  ];
  final List<String> _areas = [
    'Caldera 5', 'Caldera 4', 'Caldera 3', 'TGAS', 'TG3',
    'Sistema de carbón', 'Aire comprimido', 'Transporte de ceniza', 'Agua',
  ];
  List<String> _ubicacionesTecnicasOpciones = [];
  Map<String, String> _ubicacionDescripcionMap = {};

  final List<String> _condicionesEncontradas = [
    'Operativo', 'Detenido por falla', 'Intermitente', 'Operando con falla',
  ];
  final List<String> _condicionesFinalesEquipo = [
    'Operativo', 'En pruebas', 'Fuera de servicio',
  ];

  @override
  void initState() {
    super.initState();
    _fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dateController.text = _fecha;
    _loadUbicacionDescripcion();

    // Inicializar _mantenimientoRegistro con valores por defecto al inicio
    _mantenimientoRegistro = MantenimientoRegistro(
      tituloReporte: 'Reporte de Mantenimiento E-PWP',
      planta: _plantas.isNotEmpty ? _plantas.first : '',
      fecha: _fecha,
      realizadoPor: _realizadoPor.isNotEmpty ? _realizadoPor.first : '',
      ayudante: _ayudantes.isNotEmpty ? _ayudantes.first : 'Ninguno',
      orden: '',
      area: _areas.isNotEmpty ? _areas.first : '',
      ubicacionTecnica: '', // Se llena después de cargar el txt
      descripcionUbicacion: '', // Se llena con el controlador
      tipoMantenimiento: [],
      condicionEncontrada: _condicionesEncontradas.isNotEmpty ? _condicionesEncontradas.first : '',
      estadoEquipo: [],
      existeAveria: 'No',
      descripcionProblema: '',
      accionesRealizadas: [],
      horaInicio: '',
      horaFin: '',
      tiempoEstimado: '',
      descripcionActividades: '',
      fotosBytes: [], // Inicializa la lista de bytes vacía
      condicionFinalEquipo: _condicionesFinalesEquipo.isNotEmpty ? _condicionesFinalesEquipo.first : '',
      requiereSeguimiento: 'No',
      detalleSeguimiento: '',
      accionesSugeridas: '',
    );

    // Actualizar los valores iniciales de los dropdowns si _mantenimientoRegistro ya tiene datos
    _plantaSeleccionada = _mantenimientoRegistro.planta;
    _realizadoPorSeleccionado = _mantenimientoRegistro.realizadoPor;
    _ayudanteSeleccionado = _mantenimientoRegistro.ayudante ?? 'Ninguno';
    _areaSeleccionada = _mantenimientoRegistro.area;
    _condicionEncontrada = _mantenimientoRegistro.condicionEncontrada;
    _condicionFinalEquipo = _mantenimientoRegistro.condicionFinalEquipo;
  }

  // Función para cargar el mapa de ubicaciones y descripciones desde assets/descripcion.txt
  Future<void> _loadUbicacionDescripcion() async {
    try {
      final String fileContent = await rootBundle.loadString('assets/descripcion.txt');
      final List<String> lines = fileContent.split('\n');
      Map<String, String> tempMap = {};

      for (int i = 1; i < lines.length; i++) {
        final String line = lines[i].trim();
        if (line.isNotEmpty) {
          final List<String> parts = line.split('\t');
          if (parts.length >= 2) {
            tempMap[parts[0].trim()] = parts.sublist(1).join('\t').trim();
          } else {
            tempMap[parts[0].trim()] = '';
          }
        }
      }

      setState(() {
        _ubicacionDescripcionMap = tempMap;
        _ubicacionesTecnicasOpciones = _ubicacionDescripcionMap.keys.toList();

        if (_ubicacionesTecnicasOpciones.isNotEmpty) {
          _ubicacionTecnicaSeleccionada = _ubicacionesTecnicasOpciones.first;
          _descripcionUbicacion = _ubicacionDescripcionMap[_ubicacionTecnicaSeleccionada] ?? '';
          _descripcionUbicacionController.text = _descripcionUbicacion;
        }
      });
    } catch (e) {
      print('Error al cargar la descripción de ubicaciones: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos de Ubicación Técnica: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _fecha = DateFormat('yyyy-MM-dd').format(picked);
        _dateController.text = _fecha;
      });
    }
  }

  void _calcularTiempoEstimado() {
    if (_horaInicio.isNotEmpty && _horaFin.isNotEmpty) {
      try {
        final List<String> inicioParts = _horaInicio.split(':');
        final List<String> finParts = _horaFin.split(':');

        final int inicioHora = int.parse(inicioParts[0]);
        final int inicioMinuto = int.parse(inicioParts[1]);
        final int finHora = int.parse(finParts[0]);
        final int finMinuto = int.parse(finParts[1]);

        final DateTime dummyDate = DateTime(2000, 1, 1);
        final DateTime startTime = DateTime(dummyDate.year, dummyDate.month, dummyDate.day, inicioHora, inicioMinuto);
        DateTime endTime = DateTime(dummyDate.year, dummyDate.month, dummyDate.day, finHora, finMinuto);

        if (endTime.isBefore(startTime)) {
          endTime = endTime.add(const Duration(days: 1));
        }

        final Duration duration = endTime.difference(startTime);
        final int hours = duration.inHours;
        final int minutes = duration.inMinutes.remainder(60);

        setState(() {
          _tiempoEstimado = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
          _tiempoEstimadoController.text = _tiempoEstimado;
        });
      } catch (e) {
        setState(() {
          _tiempoEstimado = '';
          _tiempoEstimadoController.text = 'Error en el cálculo';
        });
        print('Error al calcular tiempo: $e');
      }
    } else {
      setState(() {
        _tiempoEstimado = '';
        _tiempoEstimadoController.text = '';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final List<String> selectedTipoMantenimiento = _tipoMantenimientoCheckboxes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final List<String> selectedEstadoEquipo = _estadoEquipoCheckboxes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final List<String> selectedAccionesRealizadas = _accionesRealizadasCheckboxes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // CAMBIO: Actualizar la instancia del modelo con los datos recolectados
      _mantenimientoRegistro = _mantenimientoRegistro.copyWith(
        planta: _plantaSeleccionada,
        fecha: _fecha,
        realizadoPor: _realizadoPorSeleccionado,
        ayudante: _ayudanteSeleccionado,
        orden: _orden,
        area: _areaSeleccionada,
        ubicacionTecnica: _ubicacionTecnicaSeleccionada,
        descripcionUbicacion: _descripcionUbicacion,
        tipoMantenimiento: selectedTipoMantenimiento,
        condicionEncontrada: _condicionEncontrada,
        estadoEquipo: selectedEstadoEquipo,
        existeAveria: _existeAveria,
        descripcionProblema: _descripcionProblema,
        accionesRealizadas: selectedAccionesRealizadas,
        otroAccionTexto: _otroAccionTexto,
        horaInicio: _horaInicio,
        horaFin: _horaFin,
        tiempoEstimado: _tiempoEstimado,
        descripcionActividades: _descripcionActividades,
        fotosBytes: _fotosBytes, // ¡Aquí pasamos los bytes que ahora son acumulativos!
        condicionFinalEquipo: _condicionFinalEquipo,
        requiereSeguimiento: _requiereSeguimiento,
        detalleSeguimiento: _detalleSeguimiento,
        accionesSugeridas: _accionesSugeridas,
      );

      print('Datos del Reporte: ${_mantenimientoRegistro.toJson()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formulario validado y datos recogidos (revisar consola)!')),
        );
      }
    }
  }

  // CAMBIO MAYOR: Lógica para seleccionar MÚLTIPLES imágenes (ahora las AÑADE)
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        List<Uint8List> newFotosBytes = [];
        List<String> newFotosDisplayPaths = [];

        for (XFile image in images) {
          Uint8List bytes = await image.readAsBytes();
          newFotosBytes.add(bytes);

          if (kIsWeb) {
            newFotosDisplayPaths.add(image.path);
          } else {
            newFotosDisplayPaths.add(image.name);
          }
        }

        setState(() {
          // *** ESTA ES LA LÍNEA CLAVE QUE CAMBIA ***
          // Añade las nuevas fotos a las existentes en lugar de reemplazarlas
          _fotosBytes.addAll(newFotosBytes);
          _fotosDisplayPaths.addAll(newFotosDisplayPaths);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imágenes agregadas: ${newFotosBytes.length}. Total: ${_fotosBytes.length}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se seleccionaron nuevas imágenes.')),
          );
        }
      }
    } catch (e) {
      print('Error al seleccionar imágenes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al acceder a las imágenes: $e')),
        );
      }
    }
  }

  // NUEVO: Helper para mostrar las imágenes en la UI con opción de eliminar
  Widget _buildAttachedImages() {
    if (_fotosBytes.isEmpty) {
      return const Text('No hay fotos adjuntas.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Imágenes adjuntas:', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _fotosBytes.asMap().entries.map((entry) {
            final int index = entry.key;
            final Uint8List bytes = entry.value;
            final String displayPath = _fotosDisplayPaths.length > index ? _fotosDisplayPaths[index].split('/').last : 'Imagen ${index + 1}';

            return Stack(
              children: [
                Column(
                  children: [
                    Image.memory(bytes, width: 100, height: 100, fit: BoxFit.cover),
                    Text(displayPath, style: const TextStyle(fontSize: 10)),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _fotosBytes.removeAt(index);
                        _fotosDisplayPaths.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Imagen $displayPath eliminada.')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Mantenimiento E-PWP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- Imagen de Encabezado ---
                Image.asset(
                  'assets/images/encabezado_taric.png', // <-- ¡RUTA AJUSTADA!
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),

                const Text(
                  'Descripción: Documentar intervenciones técnicas realizadas en planta. Por favor, complete todos los campos requeridos y adjunte los registros fotográficos.',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),

                // ... (El resto de tus campos de formulario, NO CAMBIAN en esta sección)
                // --- 2. Datos Generales ---
                const Text('Datos Generales',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),

                // Campo Fecha (automático)
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),

                // Campo Planta
                DropdownButtonFormField<String>(
                  value: _plantaSeleccionada.isEmpty ? null : _plantaSeleccionada,
                  decoration: const InputDecoration(labelText: 'Planta'),
                  items: _plantas.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _plantaSeleccionada = newValue!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Seleccione una planta'
                      : null,
                ),

                // Campo Realizado por
                DropdownButtonFormField<String>(
                  value: _realizadoPorSeleccionado.isEmpty ? null : _realizadoPorSeleccionado,
                  decoration: const InputDecoration(labelText: 'Realizado por'),
                  items: _realizadoPor.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _realizadoPorSeleccionado = newValue!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Seleccione el personal responsable'
                      : null,
                ),

                // Campo Ayudante (Opcional)
                DropdownButtonFormField<String>(
                  value: _ayudanteSeleccionado.isEmpty ? null : _ayudanteSeleccionado,
                  decoration: const InputDecoration(labelText: 'Ayudante (Opcional)'),
                  items: _ayudantes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _ayudanteSeleccionado = newValue!;
                    });
                  },
                ),
                // Campo Orden
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Orden'),
                  onSaved: (newValue) => _orden = newValue!,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese la orden'
                      : null,
                ),
                const SizedBox(height: 20),

                // --- Información del Equipo ---
                const Text('Información del Equipo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),

                // Campo Área
                DropdownButtonFormField<String>(
                  value: _areaSeleccionada.isEmpty ? null : _areaSeleccionada,
                  decoration: const InputDecoration(labelText: 'Área'),
                  items: _areas.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _areaSeleccionada = newValue!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Seleccione un área'
                      : null,
                ),

                // Campo Ubicación Técnica
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _ubicacionesTecnicasOpciones.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _ubicacionTecnicaSeleccionada = selection;
                      _descripcionUbicacion = _ubicacionDescripcionMap[selection] ?? '';
                      _descripcionUbicacionController.text = _descripcionUbicacion;
                    });
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación Técnica',
                        hintText: 'Digite para buscar...',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleccione una ubicación';
                        }
                        if (!_ubicacionDescripcionMap.containsKey(value)) {
                          return 'Ubicación no válida';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (!_ubicacionDescripcionMap.containsKey(value)) {
                          setState(() {
                            _descripcionUbicacion = '';
                            _descripcionUbicacionController.text = '';
                          });
                        }
                      },
                      onSaved: (newValue) {
                        _ubicacionTecnicaSeleccionada = newValue!;
                      },
                    );
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: SizedBox(
                          height: 200.0,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: ListTile(
                                  title: Text(option),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Campo Descripción (se actualiza automáticamente)
                TextFormField(
                  controller: _descripcionUbicacionController,
                  decoration: const InputDecoration(labelText: 'Descripción (automática)'),
                  enabled: false,
                  onSaved: (newValue) => _descripcionUbicacion = newValue!,
                ),
                const SizedBox(height: 20),

                // --- Detalles del Mantenimiento ---
                const Text('Detalles del Mantenimiento',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),

                // Tipo de Mantenimiento (Checkboxes)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Tipo de Mantenimiento:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  spacing: 10.0,
                  children: _tipoMantenimientoCheckboxes.keys.map((String key) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          value: _tipoMantenimientoCheckboxes[key],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _tipoMantenimientoCheckboxes[key] = newValue!;
                            });
                          },
                        ),
                        Text(key),
                      ],
                    );
                  }).toList(),
                ),

                // Condición encontrada (Dropdown)
                DropdownButtonFormField<String>(
                  value: _condicionEncontrada.isEmpty ? null : _condicionEncontrada,
                  decoration: const InputDecoration(labelText: 'Condición encontrada'),
                  items: _condicionesEncontradas.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _condicionEncontrada = newValue!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Seleccione una condición'
                      : null,
                ),

                // Estado del Equipo (Checkboxes)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Estado del Equipo:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  spacing: 10.0,
                  children: _estadoEquipoCheckboxes.keys.map((String key) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          value: _estadoEquipoCheckboxes[key],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _estadoEquipoCheckboxes[key] = newValue!;
                            });
                          },
                        ),
                        Text(key),
                      ],
                    );
                  }).toList(),
                ),

                // ¿Existe alguna avería? (Sí/No)
                DropdownButtonFormField<String>(
                  value: _existeAveria.isEmpty ? null : _existeAveria,
                  decoration: const InputDecoration(labelText: '¿Existe alguna avería?'),
                  items: const <String>['No', 'Sí']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _existeAveria = newValue!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Seleccione una opción'
                      : null,
                ),
                const SizedBox(height: 20),

                // --- Descripción del Problema o Motivo de la Intervención ---
                const Text('Descripción del Problema o Motivo de la Intervención',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descripción del problema o motivo de la intervención:',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onSaved: (newValue) => _descripcionProblema = newValue!,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese una descripción'
                      : null,
                ),
                const SizedBox(height: 20),

                // --- Acciones Realizadas ---
                const Text('Acciones Realizadas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Wrap(
                  spacing: 10.0,
                  children: _accionesRealizadasCheckboxes.keys.map((String key) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          value: _accionesRealizadasCheckboxes[key],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _accionesRealizadasCheckboxes[key] = newValue!;
                            });
                          },
                        ),
                        Text(key),
                      ],
                    );
                  }).toList(),
                ),
                // Campo "Otro" para acciones
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Especificar otra acción (si aplica)'),
                  onSaved: (newValue) => _otroAccionTexto = newValue!,
                ),
                const SizedBox(height: 20),

                // --- Duración de la Intervención ---
                const Text('Duración de la Intervención',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>( // CAMBIO: Ahora es un Dropdown
                        value: _horaInicio.isEmpty ? null : _horaInicio,
                        decoration: const InputDecoration(
                          labelText: 'Hora de inicio',
                          hintText: 'Seleccione la hora', // Texto guía para el usuario
                        ),
                        // Genera todas las combinaciones de horas y minutos (ej. "00:00", "00:30", "01:00", etc.)
                        items: _horas.expand((h) => _minutos.map((m) => '$h:$m'))
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _horaInicio = newValue!;
                            _calcularTiempoEstimado(); // Recalcula el tiempo al cambiar
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Seleccione hora de inicio'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>( // CAMBIO: Ahora es un Dropdown
                        value: _horaFin.isEmpty ? null : _horaFin,
                        decoration: const InputDecoration(
                          labelText: 'Hora de fin',
                          hintText: 'Seleccione la hora', // Texto guía para el usuario
                        ),
                        // Genera todas las combinaciones de horas y minutos
                        items: _horas.expand((h) => _minutos.map((m) => '$h:$m'))
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _horaFin = newValue!;
                            _calcularTiempoEstimado(); // Recalcula el tiempo al cambiar
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Seleccione hora de fin'
                            : null,
                      ),
                    ),
                  ],
                ),
                TextFormField( // Este campo se mantiene igual, es de solo lectura
                  controller: _tiempoEstimadoController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Tiempo estimado de intervención (HH:MM)'),
                  onSaved: (newValue) => _tiempoEstimado = newValue!, // Se guarda el valor calculado
                ),
                const SizedBox(height: 20),

                // --- Descripción Breve de Actividades Realizadas ---
                const Text('Descripción Breve de las Actividades Realizadas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Detalle las actividades realizadas:',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  onSaved: (newValue) => _descripcionActividades = newValue!,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese una descripción de actividades'
                      : null,
                ),
                const SizedBox(height: 20),

                // --- Adjuntos ---
                const Text('Adjuntos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),

                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('Adjuntar Fotos (Antes/Durante/Después)'),
                ),
                const SizedBox(height: 10),
                _buildAttachedImages(), // <-- Muestra las fotos adjuntas
                const SizedBox(height: 20),

                // --- Evaluación Técnica ---
                const Text('Evaluación Técnica',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                DropdownButtonFormField<String>(
                  value: _condicionFinalEquipo.isEmpty ? null : _condicionFinalEquipo,
                  decoration: const InputDecoration(labelText: 'Condición final del equipo'),
                  items: _condicionesFinalesEquipo.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _condicionFinalEquipo = newValue!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Seleccione la condición final'
                      : null,
                ),

                DropdownButtonFormField<String>(
                  value: _requiereSeguimiento.isEmpty ? null : _requiereSeguimiento,
                  decoration: const InputDecoration(labelText: '¿Requiere seguimiento?'),
                  items: const <String>['No', 'Sí']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _requiereSeguimiento = newValue!;
                    });
                  },
                ),
                if (_requiereSeguimiento == 'Sí')
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Detallar seguimiento:',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (newValue) => _detalleSeguimiento = newValue!,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese el detalle del seguimiento'
                        : null,
                  ),

                // --- Recomendaciones ---
                const Text('Recomendaciones',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Acciones sugeridas:',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (newValue) => _accionesSugeridas = newValue!,
                ),
                const SizedBox(height: 20),

                // --- Botones de Acción ---
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          child: Text('Guardar Reporte', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 20), // Espacio entre botones

                      // <-- NUEVO: Botón para Generar Reporte PDF
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // Asegurarse de que el modelo _mantenimientoRegistro tenga todos los datos
                            // (Ya se actualiza en _submitForm, pero si este botón se presiona antes,
                            // o si quieres que sea independiente del "Guardar", se puede llamar _submitForm aquí)

                            // Re-crear el objeto MantenimientoRegistro con los datos actuales del estado
                            // Esto es redundante si _submitForm ya se ha llamado, pero seguro.
                            final currentRegistro = MantenimientoRegistro(
                              tituloReporte: 'Reporte de Mantenimiento E-PWP',
                              planta: _plantaSeleccionada,
                              fecha: _fecha,
                              realizadoPor: _realizadoPorSeleccionado,
                              ayudante: _ayudanteSeleccionado,
                              orden: _orden,
                              area: _areaSeleccionada,
                              ubicacionTecnica: _ubicacionTecnicaSeleccionada,
                              descripcionUbicacion: _descripcionUbicacion,
                              tipoMantenimiento: _tipoMantenimientoCheckboxes.entries.where((entry) => entry.value).map((entry) => entry.key).toList(),
                              condicionEncontrada: _condicionEncontrada,
                              estadoEquipo: _estadoEquipoCheckboxes.entries.where((entry) => entry.value).map((entry) => entry.key).toList(),
                              existeAveria: _existeAveria,
                              descripcionProblema: _descripcionProblema,
                              accionesRealizadas: _accionesRealizadasCheckboxes.entries.where((entry) => entry.value).map((entry) => entry.key).toList(),
                              otroAccionTexto: _otroAccionTexto,
                              horaInicio: _horaInicio,
                              horaFin: _horaFin,
                              tiempoEstimado: _tiempoEstimado,
                              descripcionActividades: _descripcionActividades,
                              fotosBytes: _fotosBytes, // ¡Aquí pasamos los bytes acumulados!
                              condicionFinalEquipo: _condicionFinalEquipo,
                              requiereSeguimiento: _requiereSeguimiento,
                              detalleSeguimiento: _detalleSeguimiento,
                              accionesSugeridas: _accionesSugeridas,
                            );


                            try {
                              final pdfBytes = await PdfGenerator.generateMantenimientoPdf(currentRegistro); // <-- Pasa el modelo completo

                              if (kIsWeb) {
                                // Para web, usa printing para abrir en una nueva pestaña o descargar
                                await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
                              } else {
                                // Para móvil/desktop, guarda el archivo y luego compártelo
                                final directory = await getApplicationDocumentsDirectory(); // O getTemporaryDirectory()
                                final file = File('${directory.path}/reporte_mantenimiento_${DateTime.now().millisecondsSinceEpoch}.pdf');
                                await file.writeAsBytes(pdfBytes);

                                // Compartir el archivo
                                await Share.shareXFiles([XFile(file.path)], subject: 'Reporte de Mantenimiento');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('PDF generado y listo para compartir!')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al generar PDF: $e')),
                              );
                              print('Error al generar PDF: $e');
                            }
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          child: Text('Generar Reporte PDF', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Asegúrate de que la extensión MantenimientoRegistroCopyWith esté en tu archivo `lib/models/mantenimiento_registro.dart`
// NO la pongas aquí, ya que ya estaba en el lugar correcto según tus comentarios.