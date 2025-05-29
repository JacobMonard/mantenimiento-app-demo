// lib/utils/pdf_generator.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle; // Importar para cargar assets
import 'package:mantenimiento_app/models/mantenimiento_registro.dart'; // Importa tu modelo MantenimientoRegistro

class PdfGenerator {
  static Future<Uint8List> generateMantenimientoPdf(MantenimientoRegistro registro) async {
    // Cargar la imagen del encabezado
    final ByteData bytes = await rootBundle.load('assets/images/encabezado_taric.png');
    final Uint8List headerImageBytes = bytes.buffer.asUint8List();
    final pw.MemoryImage headerImage = pw.MemoryImage(headerImageBytes);

    // Definir el color específico #2F5496
    final PdfColor customBlue = PdfColor.fromHex('2F5496');

    // Inicializar el objeto pdf
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage( // Usamos MultiPage para paginación automática
        pageFormat: PdfPageFormat.letter, // Formato Carta
        margin: const pw.EdgeInsets.all(36), // Márgenes estándar
        header: (pw.Context context) { // Encabezado que se repite en cada página
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: double.infinity,
                height: 70, // Alto para la imagen del encabezado
                child: pw.Center(
                  child: pw.Image(headerImage, fit: pw.BoxFit.contain),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'Reporte de Mantenimiento', // Título principal del reporte
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: customBlue,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
            ],
          );
        },
        footer: (pw.Context context) { // Pie de página que se repite en cada página
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Reporte de Mantenimiento', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          );
        },
        build: (pw.Context context) => [ // build ahora devuelve una lista de widgets
          // --- NUEVO TEXTO DESCRIPTIVO ---
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: pw.Text(
              "Este reporte informativo resume las acciones realizadas durante la intervención del equipo, proporcionando una visión general de los hallazgos encontrados, las tareas ejecutadas y las recomendaciones para el sistema intervenido. La información contenida en este documento es resultado del trabajo colaborativo entre los equipos de mantenimiento y operación, generando una herramienta de consulta para todos.",
              textAlign: pw.TextAlign.justify, // <-- Alineación justificada
              style: pw.TextStyle(
                fontSize: 10, // <-- Letra más pequeña
                color: customBlue, // <-- Mismo color
              ),
            ),
          ),
          pw.SizedBox(height: 15), // Espacio después del texto descriptivo
          // --- FIN NUEVO TEXTO DESCRIPTIVO ---
          
          // --- Datos Generales ---
          pw.Text('Datos Generales', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          _buildInfoRow('Fecha:', registro.fecha),
          _buildInfoRow('Realizado por:', registro.realizadoPor),
          if (registro.ayudante != null && registro.ayudante != 'Ninguno' && registro.ayudante!.isNotEmpty)
            _buildInfoRow('Ayudante:', registro.ayudante!),
          _buildInfoRow('Orden:', registro.orden),
          pw.SizedBox(height: 10),

          // --- Información del Equipo ---
          pw.Text('Información del Equipo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          _buildInfoRow('Planta:', registro.planta),
          _buildInfoRow('Área:', registro.area),
          _buildInfoRow('Ubicación Técnica:', registro.ubicacionTecnica),
          _buildInfoRow('Descripción Ubicación:', registro.descripcionUbicacion),
          pw.SizedBox(height: 10),

          // --- Detalles del Mantenimiento ---
          pw.Text('Detalles del Mantenimiento', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          _buildInfoRow('Tipo de Mantenimiento:', registro.tipoMantenimiento.join(', ')),
          _buildInfoRow('Condición Encontrada:', registro.condicionEncontrada),
          _buildInfoRow('Estado del Equipo:', registro.estadoEquipo.join(', ')),
          _buildInfoRow('¿Existe Avería?:', registro.existeAveria),
          pw.SizedBox(height: 10),

          // --- Descripción del Problema o Motivo de la Intervención ---
          pw.Text('Descripción del Problema o Motivo de la Intervención', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(registro.descripcionProblema, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 10),

          // --- Acciones Realizadas ---
          pw.Text('Acciones Realizadas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          _buildInfoRow('Acciones:', registro.accionesRealizadas.join(', ')),
          if (registro.otroAccionTexto != null && registro.otroAccionTexto!.isNotEmpty)
            _buildInfoRow('Otra Acción:', registro.otroAccionTexto!),
          _buildInfoRow('Materiales/Repuestos:', registro.materialesRepuestos),
          _buildInfoRow('Hora Inicio:', registro.horaInicio),
          _buildInfoRow('Hora Fin:', registro.horaFin),
          if (registro.tiempoEstimado != null && registro.tiempoEstimado!.isNotEmpty)
            _buildInfoRow('Tiempo Estimado:', registro.tiempoEstimado!),
          _buildInfoRow('Permisos Requeridos:', registro.permisosRequeridos.join(', ')),
          _buildInfoRow('Descripción Actividades:', registro.descripcionActividades),
          pw.SizedBox(height: 10),

          // --- Evidencia Fotográfica ---
          pw.Text('Evidencia Fotográfica', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          ...registro.fotosBytes.map((bytes) {
            try {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Container(
                  width: 250,
                  height: 180,
                  child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
                ),
              );
            } catch (e) {
              print('Error al cargar imagen en PDF: $e');
              return pw.Text('Error al cargar imagen', style: const pw.TextStyle(fontSize: 10, color: PdfColors.red));
            }
          }).toList(),
          pw.SizedBox(height: 10),

          // --- Evidencia de Video (Ahora condicional) ---
          if (registro.videoBytes != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Evidencia de Video', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Video adjunto (no reproducible directamente en PDF).', style: const pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
                pw.SizedBox(height: 10),
              ],
            ),

          // --- Evaluación Técnica ---
          pw.Text('Evaluación Técnica', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          _buildInfoRow('Condición Final del Equipo:', registro.condicionFinalEquipo),
          _buildInfoRow('¿Requiere Seguimiento?:', registro.requiereSeguimiento),
          if (registro.detalleSeguimiento != null && registro.detalleSeguimiento!.isNotEmpty)
            _buildInfoRow('Detalle Seguimiento:', registro.detalleSeguimiento!),
          if (registro.riesgosObservados != null && registro.riesgosObservados!.isNotEmpty)
            _buildInfoRow('Riesgos Observados:', registro.riesgosObservados!),
          pw.SizedBox(height: 10),

          // --- Recomendaciones ---
          pw.Text('Recomendaciones', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          if (registro.accionesSugeridasCortoPlazo != null && registro.accionesSugeridasCortoPlazo!.isNotEmpty)
            _buildInfoRow('Acciones Sugeridas (Corto Plazo):', registro.accionesSugeridasCortoPlazo!),
          if (registro.sugerenciasMejoraRedisenio != null && registro.sugerenciasMejoraRedisenio!.isNotEmpty)
            _buildInfoRow('Sugerencias Mejora/Rediseño:', registro.sugerenciasMejoraRedisenio!),
        ],
      ),
    );

    return pdf.save();
  }

  // Helper para construir filas de información clave
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 5),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}