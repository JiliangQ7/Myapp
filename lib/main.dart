import 'package:flutter/material.dart';
import 'MainPage.dart'; 
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> deleteOldDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'ejercicios.db');

  await deleteDatabase(path);

  final fileExists = await File(path).exists();
  if (fileExists) {
    print('nope');
  } else {
    print('Se borro la base de datos');
  }
}

Future<void> borrarBaseDeDatos() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app_database.db');
  await deleteDatabase(path);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App de Ejercicio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(), 
    );
  }
}
