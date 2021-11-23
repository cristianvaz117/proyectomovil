import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'package:proyectomovil/models/vacunacion.dart';
//import 'package:proyectomovil/db/operation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: MyApp(),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'vacunacion.db'),
  );
}

class Vacunacion {
  final String nombre;
  final String correo;
  final String direccion;
  final String fecha_entrev;

  Vacunacion(
      {required this.nombre,
      required this.correo,
      required this.direccion,
      required this.fecha_entrev});

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'correo': correo,
      'direccion': direccion,
      'fecha_entrev': fecha_entrev
    };
  }
}

class Operation {
  static Future<Database> _openDB() async {
    return openDatabase(join(await getDatabasesPath(), 'vacunacion.db'),
        onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE person(nombre TEXT PRIMARY KEY, correo TEXT, direccion TEXT, fecha_entrev TEXT)',
      );
    }, version: 1);
  }

  static Future<void> insert(Vacunacion vacunacion) async {
    Database database = await _openDB();
    await database.insert("person", vacunacion.toMap());
  }

  static Future<List<Vacunacion>> vacunacion() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> vacunamap = await database.query("person");

    for (var n in vacunamap) {
      print("_____" + n['nombre']);
    }

    return List.generate(
        vacunamap.length,
        (i) => Vacunacion(
            nombre: vacunamap[i]['nombre'],
            correo: vacunamap[i]['correo'],
            direccion: vacunamap[i]['direccion'],
            fecha_entrev: vacunamap[i]['fecha_entrev']));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Censo Vacunas'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 4 / 3,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SecondRoute()));
            },
            child: Text('Registrar datos'),
          ),
          ElevatedButton(
            child: Text('Personas vacunadas'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ThirdRoute()));
            },
          ),
        ],
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de paciente"),
      ),
      body: Center(
        child: _save(),
      ),
    );
  }
}

class _save extends StatelessWidget {
  final _Key = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final direccionController = TextEditingController();
  final fechaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Form(
        key: _Key,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: nombreController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Llenar los datos solicitados.";
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: "Nombre Persona", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: correoController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Llenar los datos solicitados.";
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: "Correo", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: direccionController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Llenar los datos solicitados.";
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: "Direccion", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: fechaController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Llenar los datos solicitados.";
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: "Fecha de Entrevista",
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              child: Text("Registrar"),
              onPressed: () {
                if (_Key.currentState!.validate()) {
                  print("Registrado: " + nombreController.text);
                  Operation.insert(Vacunacion(
                      nombre: nombreController.text,
                      correo: correoController.text,
                      direccion: direccionController.text,
                      fecha_entrev: fechaController.text));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdRoute extends StatelessWidget {
  const ThirdRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de personas vacunadas"),
      ),
      body: Container(
        child: _Mylist(),
      ),
    );
  }
}

class _Mylist extends StatefulWidget {
  @override
  State<_Mylist> createState() => _MylistState();
}

class _MylistState extends State<_Mylist> {
  List<Vacunacion> vacuna = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: vacuna.length,
      itemBuilder: (_, i) => _createItem(i),
    );
  }

  _loadData() async {
    List<Vacunacion> auxiliar = await Operation.vacunacion();
    setState(() {
      vacuna = auxiliar;
    });
  }

  _createItem(i) {
    return ListTile(
      title: Text(vacuna[i].nombre),
    );
  }
}
