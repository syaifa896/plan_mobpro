import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseSvc {
  static Database? _db;
  static final DatabaseSvc instance = DatabaseSvc._constructor();

  final String _tabelUser = 'users';
  final String _kolomIDUser = 'id_user';
  final String _kolomUser = 'username';
  final String _kolomPass = 'password';
  final String _kolomLog = 'status_log';

  final String _tabelTugas = 'tugas';
  final String _kolomIDTugas = 'id_tugas';
  final String _kolomJudul = 'judul_tugas';
  final String _kolomDesc = 'desc_tugas';
  final String _kolomPrio = 'prio_tugas';
  final String _kolomTglDeadline = 'deadline_tugas';
  final String _kolomStatus = 'status_tugas';

  DatabaseSvc._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDB();
    return _db!;
  }

  Future<Database> getDB() async {
    final dbDirPath = await getDatabasesPath();
    final dbPath = join(dbDirPath, "plan_db.db");
    final database = await openDatabase(
      dbPath,
      version: 5,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_tabelUser (
            $_kolomIDUser INTEGER PRIMARY KEY AUTOINCREMENT,
            $_kolomUser TEXT NOT NULL,
            $_kolomPass TEXT NOT NULL,
            $_kolomLog TEXT DEFAULT 'OFF'
          )
          ''');
        db.execute('''
          CREATE TABLE $_tabelTugas (
            $_kolomIDTugas INTEGER PRIMARY KEY AUTOINCREMENT,
            $_kolomJudul TEXT NOT NULL,
            $_kolomDesc TEXT NOT NULL,
            $_kolomUser TEXT NOT NULL,
            $_kolomPrio TEXT NOT NULL,
            $_kolomTglDeadline TEXT NOT NULL,
            $_kolomStatus TEXT DEFAULT 'WIP',
            FOREIGN KEY ($_kolomUser) REFERENCES $_tabelUser($_kolomUser)
          )
        ''');
      },
      onUpgrade: (db, oldVer, newVer) {
        if (oldVer < 5) {
          db.execute('''
      CREATE TABLE tugas_new (
        id_tugas INTEGER PRIMARY KEY AUTOINCREMENT,
        judul_tugas TEXT NOT NULL,
        desc_tugas TEXT NOT NULL,
        username TEXT NOT NULL,
        prio_tugas TEXT NOT NULL,
        deadline_tugas TEXT NOT NULL,
        status_tugas TEXT DEFAULT 'WIP',
        FOREIGN KEY (username) REFERENCES users(username)
      )
    ''');

          // Salin data dari tabel lama ke tabel baru
          db.execute('''
      INSERT INTO tugas_new (id_tugas, judul_tugas, desc_tugas, username, prio_tugas, deadline_tugas, status_tugas)
      SELECT id_tugas, judul_tugas, desc_tugas, username, prio_tugas, deadline_tugas, status_tugas
      FROM tugas
    ''');

          // Hapus tabel lama
          db.execute('DROP TABLE tugas');

          // Ganti nama tabel baru menjadi tabel lama
          db.execute('ALTER TABLE tugas_new RENAME TO tugas');
        }
      },
    );
    return database;
  }

  //CRUD User

  Future<void> tambahUser(String username, String pass) async {
    final db = await database;
    await db.insert(
      _tabelUser,
      {_kolomUser: username, _kolomPass: pass, _kolomLog: 'OFF'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> readUsers() async {
    final db = await database;
    return await db.query(_tabelUser);
  }

  Future<Map<String, dynamic>?> getUserLogin() async {
    final db = await database;
    final result = await db.query(
      _tabelUser,
      where: '$_kolomLog = ?',
      whereArgs: ['ON'],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(int id, String username, String pass) async {
    final db = await database;
    return await db.update(
      _tabelUser,
      {_kolomUser: username, _kolomPass: pass},
      where: '$_kolomIDUser = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      _tabelUser,
      where: '$_kolomIDUser = ?',
      whereArgs: [id],
    );
  }

  Future<bool> userExists(String username) async {
    final db = await database;
    final result = await db.query(
      _tabelUser,
      where: '$_kolomUser = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<bool> authenticateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      _tabelUser,
      where: '$_kolomUser = ? AND $_kolomPass = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<int> userLogin(String username) async {
    final db = await database;
    return await db.update(
      _tabelUser,
      {_kolomLog: 'ON'},
      where: '$_kolomUser = ?',
      whereArgs: [username],
    );
  }

  Future<int> userLogout(String username) async {
    final db = await database;
    return await db.update(
      _tabelUser,
      {_kolomLog: 'OFF'},
      where: '$_kolomUser = ?',
      whereArgs: [username],
    );
  }

  // CRUD Tugas

  Future<void> tambahTugas(String judul, String desc, String username,
      String prio, String tglDead) async {
    final db = await database;
    await db.insert(
      _tabelTugas,
      {
        _kolomJudul: judul,
        _kolomDesc: desc,
        _kolomUser: username,
        _kolomPrio: prio,
        _kolomTglDeadline: tglDead,
        _kolomStatus: 'WIP'
      },
    );
  }

  Future<List<Map<String, dynamic>>> readTugasAll() async {
    final db = await database;
    return await db.query(_tabelTugas);
  }

  Future<List<Map<String, dynamic>>> readTugasByUser(String username) async {
    final db = await database;

    final result = await db.query(
      _tabelTugas,
      where: '$_kolomUser = ?', // Memfilter berdasarkan username
      whereArgs: [username], // Argumen untuk query
    );

    return result;
  }

  Future<int> updateTugas(int idTugas, String judul, String desc, String prio,
      String tglDead) async {
    final db = await database;
    return await db.update(
      _tabelTugas,
      {
        _kolomJudul: judul,
        _kolomDesc: desc,
        _kolomPrio: prio,
        _kolomTglDeadline: tglDead
      },
      where: '$_kolomIDTugas = ?',
      whereArgs: [idTugas],
    );
  }

  Future<int> updateStatusTugas(int idTugas, String statusTugas) async {
    final db = await database;
    return await db.update(
      _tabelTugas,
      {_kolomStatus: statusTugas},
      where: '$_kolomIDTugas = ?',
      whereArgs: [idTugas],
    );
  }

  Future<int> deleteTugas(int idTugas) async {
    final db = await database;
    return await db.delete(
      _tabelTugas,
      where: '$_kolomIDTugas = ?',
      whereArgs: [idTugas],
    );
  }
}
