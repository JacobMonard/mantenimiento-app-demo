// lib/screens/mantenimiento_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formateo de fechas
import 'package:flutter/services.dart' show rootBundle; // Importar para leer assets
// import 'package:http/http.dart' as http; // Se usará si hay backend real
// import 'dart:convert'; // Se usará si hay backend real

import '../models/mantenimiento_registro.dart'; // Importa tu modelo de datos

class MantenimientoFormScreen extends StatefulWidget {
  const MantenimientoFormScreen({super.key}); // Usar super.key para lint

  @override
  State<MantenimientoFormScreen> createState() => _MantenimientoFormScreenState();
}

class _MantenimientoFormScreenState extends State<MantenimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descripcionUbicacionController = TextEditingController();

  // Variables de estado para los campos del formulario
  // 2. Datos Generales
  String _plantaSeleccionada = '';
  String _fecha = '';
  String _mecanicoSeleccionado = '';
  String _ayudanteSeleccionado = 'Ninguno'; // Default
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
  String _existeAveria = 'No'; // Nuevo campo: ¿Existe alguna avería?

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
  String _materialesRepuestos = '';
  String _horaInicio = '';
  String _horaFin = '';
  String _tiempoEstimado = '';
  final Map<String, bool> _permisosRequeridosCheckboxes = {
    'LoToTo': false,
    'Espacio confinado': false,
    'Trabajo en caliente': false,
    'Alturas': false,
    'Ninguno': false,
  };
  String _descripcionActividades = '';

  // 7. Evidencia (simuladas por ahora)
  List<String> _fotos = [];
  String? _video;

  // 8. Evaluación Técnica
  String _condicionFinalEquipo = '';
  String _requiereSeguimiento = 'No';
  String _detalleSeguimiento = '';
  String _riesgosObservados = '';

  // 9. Recomendaciones
  String _accionesSugeridasCortoPlazo = '';
  String _sugerenciasMejoraRedisenio = '';


  // Listas de opciones estáticas (para Spinners/Dropdowns)
  final List<String> _plantas = [
    'Energía & Planta de Fuerza', 'Pulpapel', 'Molino 1', 'Molino 3',
    'Molino 4', 'Molino 6', 'FEC', 'Recuperación',
  ];
  final List<String> _mecanicos = [
    'Robinson Montoya', 'Carlos Salcedo', 'Samir Ramirez',
    'William Garzon', 'Daniel Franco', 'Camilo Ayala',
  ];
  final List<String> _ayudantes = [
    'Ninguno', 'Robinson Montoya', 'Carlos Salcedo', 'Samir Ramirez',
    'William Garzon', 'Daniel Franco', 'Camilo Ayala',
  ];
  final List<String> _areas = [
    'Caldera 5', 'Caldera 4', 'Caldera 3', 'TGAS', 'TG3',
    'Sistema de carbón', 'Aire comprimido', 'Transporte de ceniza', 'Agua',
  ];
  List<String> _ubicacionesTecnicasOpciones = []; // Se llenará asíncronamente
  Map<String, String> _ubicacionDescripcionMap = {}; // Se llenará asíncronamente

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
    _loadUbicacionDescripcion(); // Cargar el mapa desde el asset

    // Inicializar los valores seleccionados para DropdownButtonFormField
    // Asegurar que la primera opción sea seleccionada si la lista no está vacía
    _plantaSeleccionada = _plantas.isNotEmpty ? _plantas.first : '';
    _mecanicoSeleccionado = _mecanicos.isNotEmpty ? _mecanicos.first : '';
    _ayudanteSeleccionado = _ayudantes.isNotEmpty ? _ayudantes.first : 'Ninguno';
    _areaSeleccionada = _areas.isNotEmpty ? _areas.first : '';
    _condicionEncontrada = _condicionesEncontradas.isNotEmpty ? _condicionesEncontradas.first : '';
    _condicionFinalEquipo = _condicionesFinalesEquipo.isNotEmpty ? _condicionesFinalesEquipo.first : '';
  }

  // Función para cargar el mapa de ubicaciones y descripciones desde assets/descripcion.txt
  Future<void> _loadUbicacionDescripcion() async {
    try {
      final String fileContent = await rootBundle.loadString('assets/descripcion.txt');
      final List<String> lines = fileContent.split('\n');
      Map<String, String> tempMap = {};
      
      // Saltar la primera línea que es el encabezado "Ubicación Tecnica\tDescripción"
      for (int i = 1; i < lines.length; i++) {
        final String line = lines[i].trim();
        if (line.isNotEmpty) {
          final List<String> parts = line.split('\t');
          if (parts.length >= 2) { // Asegurarse de que haya al menos 2 partes
            tempMap[parts[0].trim()] = parts.sublist(1).join('\t').trim(); // Une el resto por si la descripción tiene tabulaciones
          } else {
            // Manejar líneas que no tienen el formato esperado (ej. solo ubicación sin descripción)
            tempMap[parts[0].trim()] = ''; // Asignar descripción vacía
          }
        }
      }
      
      setState(() {
        _ubicacionDescripcionMap = tempMap;
        _ubicacionesTecnicasOpciones = _ubicacionDescripcionMap.keys.toList();

        // Seleccionar la primera ubicación y actualizar la descripción al cargar
        // Solo si la lista de opciones no está vacía después de la carga
        if (_ubicacionesTecnicasOpciones.isNotEmpty) {
          _ubicacionTecnicaSeleccionada = _ubicacionesTecnicasOpciones.first;
          _descripcionUbicacion = _ubicacionDescripcionMap[_ubicacionTecnicaSeleccionada] ?? '';
          _descripcionUbicacionController.text = _descripcionUbicacion;
        }
      });
    } catch (e) {
      // Manejo de errores si el archivo no se encuentra o no se puede leer
      print('Error al cargar la descripción de ubicaciones: $e');
      if (mounted) { // Verificar si el widget está montado antes de mostrar SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos de Ubicación Técnica: $e')),
        );
      }
    }
  }

  // --- Funciones de Asistencia ---
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Recopilar datos de checkboxes
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

      final List<String> selectedPermisosRequeridos = _permisosRequeridosCheckboxes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      // Crear el objeto MantenimientoRegistro
      final registro = MantenimientoRegistro(
        tituloReporte: 'Reporte de Mantenimiento E-PWP',
        planta: _plantaSeleccionada,
        fecha: _fecha,
        mecanico: _mecanicoSeleccionado,
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
        materialesRepuestos: _materialesRepuestos,
        horaInicio: _horaInicio,
        horaFin: _horaFin,
        tiempoEstimado: _tiempoEstimado,
        permisosRequeridos: selectedPermisosRequeridos,
        descripcionActividades: _descripcionActividades,
        fotos: _fotos,
        video: _video,
        condicionFinalEquipo: _condicionFinalEquipo,
        requiereSeguimiento: _requiereSeguimiento,
        detalleSeguimiento: _detalleSeguimiento,
        riesgosObservados: _riesgosObservados,
        accionesSugeridasCortoPlazo: _accionesSugeridasCortoPlazo,
        sugerenciasMejoraRedisenio: _sugerenciasMejoraRedisenio,
      );

      // Imprimir todos los datos recogidos (para depuración)
      print('Datos del Reporte: ${registro.toJson()}');

      // --- Simulación de envío al servidor (si tienes uno) ---
      // Esta parte es solo para demostración. En producción, necesitarías un backend.
      /*
      http.post(
        Uri.parse('http://127.0.0.1:5000/guardar_reporte'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(registro.toJson()),
      ).then((response) {
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print(responseData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['mensaje'] ?? 'Reporte guardado exitosamente.')),
          );
        } else {
          print('Error al guardar reporte: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el reporte. Código: ${response.statusCode}')),
          );
        }
      }).catchError((error) {
        print('Error de conexión: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el reporte. Verifique la conexión al servidor.')),
        );
      });
      */

      // Mostrar un mensaje de éxito si la validación pasa (y no hay backend)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formulario validado y datos recogidos (revisar consola)!')),
        );
      }
    }
  }

  // Función simulada para seleccionar imágenes (implementación real requiere paquetes)
  void _pickImages() {
    setState(() {
      _fotos = ['path/to/imagen1.jpg', 'path/to/imagen2.png'];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imágenes seleccionadas (simulado)!')),
        );
      }
    });
  }
  
  // Función simulada para seleccionar video (implementación real requiere paquetes)
  void _pickVideo() {
    setState(() {
      _video = 'path/to/video.mp4';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video seleccionado (simulado)!')),
        );
      }
    });
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
                // --- 1. Encabezado del Formulario (Título fijo) ---
                TextFormField(
                  initialValue: 'Reporte de Mantenimiento E-PWP',
                  enabled: false, // El título no se edita
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none, // Sin borde para que parezca un título
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const Text(
                  'Descripción: Documentar intervenciones técnicas realizadas en planta. Por favor, complete todos los campos requeridos y adjunte los registros fotográficos.',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),

                // --- 2. Datos Generales ---
                const Text('Datos Generales',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                
                // Campo Fecha (automático)
                TextFormField(
                  controller: _dateController,
                  readOnly: true, // No editable por el usuario
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                
                // Campo Planta
                DropdownButtonFormField<String>(
                  value: _plantaSeleccionada.isEmpty ? null : _plantaSeleccionada, // Asegura que el valor inicial sea null si está vacío
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

                // Campo Mecánico
                DropdownButtonFormField<String>(
                  value: _mecanicoSeleccionado.isEmpty ? null : _mecanicoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Mecánico'),
                  items: _mecanicos.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _mecanicoSeleccionado = newValue!;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Seleccione un mecánico'
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
                DropdownButtonFormField<String>(
                  value: _ubicacionTecnicaSeleccionada.isEmpty ? null : _ubicacionTecnicaSeleccionada,
                  decoration: const InputDecoration(labelText: 'Ubicación Técnica'),
                  // Asegurarse de que _ubicacionesTecnicasOpciones esté cargada antes de construir los items
                  items: _ubicacionesTecnicasOpciones.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _ubicacionTecnicaSeleccionada = newValue!;
                      _descripcionUbicacion = _ubicacionDescripcionMap[newValue] ?? '';
                      _descripcionUbicacionController.text = _descripcionUbicacion; // Actualizar el controlador
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Seleccione una ubicación'
                      : null,
                ),
                
                // Campo Descripción (se actualiza automáticamente)
                TextFormField(
                  controller: _descripcionUbicacionController,
                  decoration: const InputDecoration(labelText: 'Descripción (automática)'),
                  enabled: false, // No editable por el usuario
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
                  spacing: 10.0, // Espacio horizontal entre checkboxes
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

                // --- Materiales/Repuestos utilizados ---
                const Text('Materiales/Repuestos utilizados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Detalle los materiales/repuestos utilizados:',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  onSaved: (newValue) => _materialesRepuestos = newValue!,
                ),
                const SizedBox(height: 20),

                // --- Horas de Intervención ---
                const Text('Horas de Intervención',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Hora de inicio (HH:MM)'),
                        onSaved: (newValue) => _horaInicio = newValue!,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ingrese hora de inicio'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Hora de fin (HH:MM)'),
                        onSaved: (newValue) => _horaFin = newValue!,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ingrese hora de fin'
                            : null,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tiempo estimado de intervención (HH:MM)'),
                  onSaved: (newValue) => _tiempoEstimado = newValue!,
                  // Validación opcional si debe ser un formato específico HH:MM
                ),
                const SizedBox(height: 20),
                
                // --- Permisos Requeridos ---
                const Text('Permisos Requeridos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Wrap(
                  spacing: 10.0,
                  children: _permisosRequeridosCheckboxes.keys.map((String key) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          value: _permisosRequeridosCheckboxes[key],
                          onChanged: (bool? newValue) {
                            setState(() {
                              _permisosRequeridosCheckboxes[key] = newValue!;
                            });
                          },
                        ),
                        Text(key),
                      ],
                    );
                  }).toList(),
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

                // --- Evidencia ---
                const Text('Evidencia',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('Adjuntar Fotos (Antes/Durante/Después)'),
                ),
                if (_fotos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Imágenes adjuntas:'),
                        ..._fotos.map((path) => Text(path)),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.video_collection),
                  label: const Text('Cargar Video Corto (Opcional)'),
                ),
                 if (_video != null && _video!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Video adjunto: $_video'),
                  ),
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
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Riesgos observados (si aplica):',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (newValue) => _riesgosObservados = newValue!,
                ),
                const SizedBox(height: 20),

                // --- Recomendaciones ---
                const Text('Recomendaciones',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Acciones sugeridas a corto plazo:',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (newValue) => _accionesSugeridasCortoPlazo = newValue!,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Sugerencias para mejora o rediseño:',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (newValue) => _sugerenciasMejoraRedisenio = newValue!,
                ),
                const SizedBox(height: 20),

                // --- Botón de Guardar ---
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      child: Text('Guardar Reporte', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Espacio al final del formulario
              ],
            ),
          ),
        ),
      ),
    );
  }
}