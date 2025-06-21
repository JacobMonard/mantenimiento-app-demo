// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';       // Importa el paquete pdf
import 'package:pdf/widgets.dart' as pw; // Importa el paquete widgets de pdf

// Asegúrate de que esta importación sea correcta para tu MantenimientoFormScreen
import 'package:mantenimiento_app/screens/mantenimiento_form_screen.dart';


// Variable global para almacenar las fuentes del PDF, así se cargan una sola vez.
// Usamos Future.value(null) si no queremos cargar ninguna fuente especial y confiar en la predeterminada.
// O pw.Font.helvetica() si queremos asegurar una fuente estándar específica.
late final Future<void> _initPdfFonts;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado

  // Cargar una fuente estándar del paquete PDF (como Helvetica)
  // Esto es para evitar problemas con la descarga de Google Fonts.
  _initPdfFonts = Future.value(pw.Font.helvetica()).then((_) => null); // Envuelve la fuente en un Future.value
  // Si simplemente quieres que use la fuente predeterminada del paquete PDF sin especificarla:
  // _initPdfFonts = Future.value(null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Mantenimiento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Puedes personalizar tu tema aquí
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Puedes añadir aquí la fuente predeterminada de tu app si usas google_fonts para la UI
        // Por ejemplo:
        // textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      ),
      home: FutureBuilder(
        // Espera a que las fuentes del PDF se carguen antes de mostrar la UI
        future: _initPdfFonts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Si las fuentes están cargadas, muestra la pantalla principal
            return const MantenimientoFormScreen();
          } else if (snapshot.hasError) {
            // Si hay un error al cargar las fuentes
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Text('Error al cargar recursos de fuentes: ${snapshot.error}'),
              ),
            );
          } else {
            // Mientras las fuentes se cargan, muestra un indicador de carga
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}