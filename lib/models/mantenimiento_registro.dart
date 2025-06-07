// lib/models/mantenimiento_registro.dart
import 'dart:typed_data'; // ¡NUEVA IMPORTACIÓN!
import 'dart:convert'; // ¡NUEVA IMPORTACIÓN para Base64!

class MantenimientoRegistro {
  // 2. Datos Generales
  final String? tituloReporte;
  final String planta;
  final String fecha;
  final String realizadoPor;
  final String? ayudante;
  final String orden;

  // 3. Información del Equipo
  final String area;
  final String ubicacionTecnica;
  final String descripcionUbicacion;

  // 4. Detalles del Mantenimiento
  final List<String> tipoMantenimiento;
  final String condicionEncontrada;
  final List<String> estadoEquipo;
  final String existeAveria;

  // 5. Descripción del Problema o Motivo de la Intervención
  final String descripcionProblema;

  // 6. Acciones Realizadas
  final List<String> accionesRealizadas;
  final String? otroAccionTexto;
  final String horaInicio;
  final String horaFin;
  final String? tiempoEstimado;
    final String descripcionActividades;

  // 7. Evidencia
  final List<Uint8List> fotosBytes; // <-- CAMBIO: Ahora guarda los bytes de las fotos
  
  // 8. Evaluación Técnica
  final String condicionFinalEquipo;
  final String requiereSeguimiento;
  final String? detalleSeguimiento;
  final String? riesgosObservados;

  // 9. Recomendaciones
  final String? accionesSugeridas;
  

  MantenimientoRegistro({
    this.tituloReporte,
    required this.planta,
    required this.fecha,
    required this.realizadoPor,
    this.ayudante,
    required this.orden,
    required this.area,
    required this.ubicacionTecnica,
    required this.descripcionUbicacion,
    required this.tipoMantenimiento,
    required this.condicionEncontrada,
    required this.estadoEquipo,
    required this.existeAveria,
    required this.descripcionProblema,
    required this.accionesRealizadas,
    this.otroAccionTexto,
    required this.horaInicio,
    required this.horaFin,
    this.tiempoEstimado,
    required this.descripcionActividades,
    this.fotosBytes = const [], // <-- CAMBIO: Inicialización para el nuevo tipo
    required this.condicionFinalEquipo,
    required this.requiereSeguimiento,
    this.detalleSeguimiento,
    this.riesgosObservados,
    this.accionesSugeridas,
  });

  // Método para convertir el objeto a un mapa (útil para guardar o enviar)
  Map<String, dynamic> toJson() {
    return {
      'tituloReporte': tituloReporte,
      'planta': planta,
      'fecha': fecha,
      'realizadoPor': realizadoPor,
      'ayudante': ayudante,
      'orden': orden,
      'area': area,
      'ubicacionTecnica': ubicacionTecnica,
      'descripcionUbicacion': descripcionUbicacion,
      'tipoMantenimiento': tipoMantenimiento,
      'condicionEncontrada': condicionEncontrada,
      'estadoEquipo': estadoEquipo,
      'existeAveria': existeAveria,
      'descripcionProblema': descripcionProblema,
      'accionesRealizadas': accionesRealizadas,
      'otroAccionTexto': otroAccionTexto,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'tiempoEstimado': tiempoEstimado,
      'descripcionActividades': descripcionActividades,
      // <-- CAMBIOS CLAVE AQUÍ: Codificación a Base64 para JSON
      'fotosBytes': fotosBytes.map((bytes) => base64Encode(bytes)).toList(),
      // FIN CAMBIOS CLAVE
      'condicionFinalEquipo': condicionFinalEquipo,
      'requiereSeguimiento': requiereSeguimiento,
      'detalleSeguimiento': detalleSeguimiento,
      'accionesSugeridas': accionesSugeridas,
    };
  }

  // Opcional: Si tienes un constructor fromJson, también necesitará ser actualizado
  // factory MantenimientoRegistro.fromJson(Map<String, dynamic> json) {
  //   return MantenimientoRegistro(
  //     // ... otros campos
  //     fotosBytes: (json['fotosBytes'] as List<dynamic>?)
  //         ?.map((e) => base64Decode(e as String))
  //         .toList() ?? [],
  //     videoBytes: json['videoBytes'] != null
  //         ? base64Decode(json['videoBytes'] as String)
  //         : null,
  //     // ... el resto de campos
  //   );
  // }
}

// --- EXTENSIÓN MantenimientoRegistroCopyWith ---
// Esta extensión permite usar el método .copyWith() en objetos MantenimientoRegistro.
extension MantenimientoRegistroCopyWith on MantenimientoRegistro {
  MantenimientoRegistro copyWith({
    String? tituloReporte,
    String? planta,
    String? fecha,
    String? realizadoPor,
    String? ayudante,
    String? orden,
    String? area,
    String? ubicacionTecnica,
    String? descripcionUbicacion,
    List<String>? tipoMantenimiento,
    String? condicionEncontrada,
    List<String>? estadoEquipo,
    String? existeAveria,
    String? descripcionProblema,
    List<String>? accionesRealizadas,
    String? otroAccionTexto,
    String? horaInicio,
    String? horaFin,
    String? tiempoEstimado,
    String? descripcionActividades,
    List<Uint8List>? fotosBytes,
    String? condicionFinalEquipo,
    String? requiereSeguimiento,
    String? detalleSeguimiento,
    String? accionesSugeridas,
  }) {
    return MantenimientoRegistro(
      tituloReporte: tituloReporte ?? this.tituloReporte,
      planta: planta ?? this.planta,
      fecha: fecha ?? this.fecha,
      realizadoPor: realizadoPor ?? this.realizadoPor,
      ayudante: ayudante ?? this.ayudante,
      orden: orden ?? this.orden,
      area: area ?? this.area,
      ubicacionTecnica: ubicacionTecnica ?? this.ubicacionTecnica,
      descripcionUbicacion: descripcionUbicacion ?? this.descripcionUbicacion,
      tipoMantenimiento: tipoMantenimiento ?? this.tipoMantenimiento,
      condicionEncontrada: condicionEncontrada ?? this.condicionEncontrada,
      estadoEquipo: estadoEquipo ?? this.estadoEquipo,
      existeAveria: existeAveria ?? this.existeAveria,
      descripcionProblema: descripcionProblema ?? this.descripcionProblema,
      accionesRealizadas: accionesRealizadas ?? this.accionesRealizadas,
      otroAccionTexto: otroAccionTexto ?? this.otroAccionTexto,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      tiempoEstimado: tiempoEstimado ?? this.tiempoEstimado,
      descripcionActividades: descripcionActividades ?? this.descripcionActividades,
      fotosBytes: fotosBytes ?? this.fotosBytes,
      condicionFinalEquipo: condicionFinalEquipo ?? this.condicionFinalEquipo,
      requiereSeguimiento: requiereSeguimiento ?? this.requiereSeguimiento,
      detalleSeguimiento: detalleSeguimiento ?? this.detalleSeguimiento,
      riesgosObservados: riesgosObservados ?? this.riesgosObservados,
      accionesSugeridas: accionesSugeridas ?? this.accionesSugeridas,
    );
  }
}