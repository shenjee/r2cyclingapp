import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'r2_device.dart';
import 'r2_account.dart';

class R2DBHelper {
  static final R2DBHelper _instance = R2DBHelper._internal();
  factory R2DBHelper() => _instance;

  static Database? _database;

  R2DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ble_devices.db');

    return await openDatabase(
      path,
      version: 2, // Increment the version number to handle schema changes
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE accounts(account TEXT PRIMARY KEY, nickname TEXT, iconPath INTEGER)',
        );
        await db.execute(
          'CREATE TABLE devices(id TEXT PRIMARY KEY, brand TEXT, name TEXT)',
        );
        await db.execute(
          'CREATE TABLE emergency_contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT)',
        );
        await db.execute(
          'CREATE TABLE settings(id INTEGER PRIMARY KEY, emergencyContactEnabled INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE emergency_contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT)',
          );
          await db.execute(
            'CREATE TABLE settings(id INTEGER PRIMARY KEY, emergencyContactEnabled INTEGER)',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'CREATE TABLE accounts(account TEXT PRIMARY KEY, nickname TEXT, icon INTEGER)',
          );
        }
      },
    );
  }

  // Operations for account
  Future<void> saveAccount(R2Account account) async {
    final db = await database;
    await db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<R2Account?> getLocalAccount() async {
    final db = await database;
    final result = await db.query('accounts');
    return result.isNotEmpty ? R2Account.fromMap(result.first) : null;
  }

  Future<R2Account?> getAccount(String account) async {
    final db = await database;
    final result = await db.query(
      'accounts',
      where: 'account = ?',
      whereArgs: [account],
    );
    return result.isNotEmpty ? R2Account.fromMap(result.first) : null;
  }

  Future<int> deleteAccount(String account) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'account = ?',
      whereArgs: [account],
    );
  }

  // operation for device
  Future<void> saveDevice(R2Device device) async {
    final db = await database;
    await db.insert(
      'devices',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<R2Device?> getDevice() async {
    final db = await database;
    final result = await db.query('devices');
    return result.isNotEmpty ? R2Device.fromMap(result.first) : null;
  }

  // operation for emergency contacts
  Future<int> saveContact(Map<String, dynamic> contact) async {
    final db = await database;
    if (contact.containsKey('id')) {
      // Update existing contact
      return await db.update(
        'emergency_contacts',
        contact,
        where: 'id = ?',
        whereArgs: [contact['id']],
      );
    } else {
      // Insert new contact
      return await db.insert('emergency_contacts', contact);
    }
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await database;
    return await db.query('emergency_contacts');
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete('emergency_contacts', where: 'id = ?', whereArgs: [id]);
  }

  // operations for settings
  Future<void> saveSetting(Map<String, dynamic> setting) async {
    final db = await database;
    await db.insert('settings', setting, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getSetting() async {
    final db = await database;
    final result = await db.query('settings');
    return result.isNotEmpty ? result.first : null;
  }
}