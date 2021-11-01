import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model.dart';

class DatabaseHelper {
  late Database _db;

  static final DatabaseHelper db = DatabaseHelper._();

  DatabaseHelper._();

  Future<Database> get database async {
    _db = await initDB();
    return _db;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'dbStock.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Stock('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'schemeCode INTEGER,'
          'schemeName TEXT'
          ')');
    });
  }

  insertStock(List<Stock> newStock) async {
    await deleteAllStock();
    final db = await database;
    Batch batch = db.batch();
    for (int i=0; i < newStock.length; i++) {
      batch.insert('Stock', newStock[i].toMap());
    }
    await batch.commit();
    final res = await db.rawQuery("SELECT * FROM Stock");
    return res;
  }

  Future<int> deleteAllStock() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM Stock');
    return res;
  }

  Future<List<Stock>> getAllStock() async {
    final db = await database;

    final res = await db.rawQuery("SELECT * FROM Stock");

    List<Stock> list =
        res.isNotEmpty ? res.map((c) => Stock.fromMap(c)).toList() : [];

    return list;
  }
}
