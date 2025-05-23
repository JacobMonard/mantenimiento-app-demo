// lib/models/mantenimiento_registro.dart

class MantenimientoRegistro {
  // 2. Datos Generales
  final String? tituloReporte; // Es fijo, pero lo incluimos para el modelo
  final String planta;
  final String fecha;
  final String realizadoPor;
  final String? ayudante; // Opcional
  final String orden;

  // 3. Información del Equipo
  final String area;
  final String ubicacionTecnica;
  final String descripcionUbicacion; // Descripción automática

  // 4. Detalles del Mantenimiento
  final List<String> tipoMantenimiento; // Lista de tipos seleccionados
  final String condicionEncontrada;
  final List<String> estadoEquipo; // Lista de estados seleccionados
  final String existeAveria; // Sí / No

  // 5. Descripción del Problema o Motivo de la Intervención
  final String descripcionProblema;

  // 6. Acciones Realizadas
  final List<String> accionesRealizadas; // Lista de acciones seleccionadas
  final String? otroAccionTexto; // Si se selecciona "Otro"
  final String materialesRepuestos;
  final String horaInicio;
  final String horaFin;
  final String? tiempoEstimado; // Puede calcularse
  final List<String> permisosRequeridos; // Lista de permisos seleccionados
  final String descripcionActividades;

  // 7. Evidencia
  final List<String> fotos; // Rutas de las fotos
  final String? video; // Ruta del video

  // 8. Evaluación Técnica
  final String condicionFinalEquipo;
  final String requiereSeguimiento; // Sí / No
  final String? detalleSeguimiento; // Texto condicional
  final String? riesgosObservados;

  // 9. Recomendaciones
  final String? accionesSugeridasCortoPlazo;
  final String? sugerenciasMejoraRedisenio;

  // 10. Envío (información para el reporte final, no de entrada del usuario)
  // final String confirmacionEnvio;
  // final List<String> listaCorreosPredeterminados;


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
    required this.materialesRepuestos,
    required this.horaInicio,
    required this.horaFin,
    this.tiempoEstimado,
    required this.permisosRequeridos,
    required this.descripcionActividades,
    required this.fotos,
    this.video,
    required this.condicionFinalEquipo,
    required this.requiereSeguimiento,
    this.detalleSeguimiento,
    this.riesgosObservados,
    this.accionesSugeridasCortoPlazo,
    this.sugerenciasMejoraRedisenio,
  });

  // Método opcional para convertir el objeto a un mapa (útil para guardar o enviar)
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
      'materialesRepuestos': materialesRepuestos,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'tiempoEstimado': tiempoEstimado,
      'permisosRequeridos': permisosRequeridos,
      'descripcionActividades': descripcionActividades,
      'fotos': fotos,
      'video': video,
      'condicionFinalEquipo': condicionFinalEquipo,
      'requiereSeguimiento': requiereSeguimiento,
      'detalleSeguimiento': detalleSeguimiento,
      'riesgosObservados': riesgosObservados,
      'accionesSugeridasCortoPlazo': accionesSugeridasCortoPlazo,
      'sugerenciasMejoraRedisenio': sugerenciasMejoraRedisenio,
    };
  }
}