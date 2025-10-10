import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'market_model.dart';

class DBHelper {
  static Database? _db;
  // ignore: constant_identifier_names
  static const String ID = 'id';
  // ignore: constant_identifier_names
  static const String OWNER = 'owner';
  // ignore: constant_identifier_names
  static const String DESCRIPTION = 'description';
  // ignore: constant_identifier_names
  static const String HOURS = 'hours';
  // ignore: constant_identifier_names
  static const String AVATAR = 'avatar';
  // ignore: constant_identifier_names
  static const String TABLE = 'Market';
  // ignore: constant_identifier_names
  static const String DB_NAME = 'market1.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $OWNER TEXT, $DESCRIPTION TEXT, $HOURS TEXT, $AVATAR TEXT)"
    );
  }

  Future<Market> save(Market market) async {
    var dbClient = await db;
    market.id = await dbClient.insert(TABLE, market.toMap());
    return market;
  }

  Future<List<Market>> getMarkets() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(TABLE, columns: [ID, OWNER, DESCRIPTION, HOURS, AVATAR]);
    List<Market> markets = [];
    if (maps.isNotEmpty) {
      for (Map<String, dynamic> map in maps) {
        markets.add(Market.fromMap(map));
      }
    }
    return markets;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> update(Market market) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, market.toMap(), where: '$ID = ?', whereArgs: [market.id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}