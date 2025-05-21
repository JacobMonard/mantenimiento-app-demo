// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/mantenimiento_form_screen.dart'; // Importa la pantalla del formulario

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Se recomienda añadir 'const' y 'Key? key' para optimización

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reporte de Mantenimiento E-PWP',
      debugShowCheckedModeBanner: false, // Quita el banner de debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MantenimientoFormScreen(), // Ahora muestra tu formulario completo
    );
  }
}