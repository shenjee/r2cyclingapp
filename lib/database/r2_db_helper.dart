import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:r2cyclingapp/devicemanager/r2_device.dart';
import 'package:r2cyclingapp/usermanager/r2_account.dart';
import 'package:r2cyclingapp/usermanager/r2_group.dart';


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
    final path = join(dbPath, 'r2cycling.db');

    return await openDatabase(
      path,
      version: 4, // Increment the version number to handle schema changes
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE accounts(uid INTEGER PRIMARY KEY, account TEXT KEY, nickname TEXT, phoneNumber TEXT, email TEXT, avatarPath TEXT, isPasswdSet INTEGER)',
        );
        await db.execute(
          'CREATE TABLE groups(uid INTEGER PRIMARY KEY, groupId INTEGER, groupCode TEXT, FOREIGN KEY(uid) REFERENCES accounts(uid))',
        );
        await db.execute(
          'CREATE TABLE devices(deviceId TEXT PRIMARY KEY, model TEXT, brand TEXT, name TEXT, bleAddress TEXT, classicAddress TEXT, imageUrl TEXT)',
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
            'ALTER TABLE devices ADD COLUMN imageUrl TEXT',
          );
        }
        if (oldVersion < 4) {
          // Remove mac column from devices table
          await db.execute(
            'CREATE TABLE devices_new(deviceId TEXT PRIMARY KEY, model TEXT, brand TEXT, name TEXT, bleAddress TEXT, classicAddress TEXT, imageUrl TEXT)',
          );
          await db.execute(
            'INSERT INTO devices_new(deviceId, model, brand, name, bleAddress, classicAddress, imageUrl) SELECT deviceId, model, brand, name, bleAddress, classicAddress, imageUrl FROM devices',
          );
          await db.execute('DROP TABLE devices');
          await db.execute('ALTER TABLE devices_new RENAME TO devices');
        }
      },
    );
  }

  // Operations for account
  Future<int> saveAccount(R2Account account) async {
    final db = await database;
    return await db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<R2Account?> getAccount({int? uid}) async {
    final db = await database;
    List<Map<String, Object?>> accounts;
    if (null == uid) {
      accounts = await db.query('accounts');
    } else {
      accounts = await db.query(
        'accounts',
        where: 'uid = ?',
        whereArgs: [uid],
      );
    }
    return accounts.isNotEmpty ? R2Account.fromMap(accounts.first) : null;
  }

  Future<int> deleteAccount(int uid) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Operation for user group
  Future<int> saveGroup(int uid, R2Group group) async {
    final db = await database;

    // Save the user profile
    final map = {'uid': uid, 'groupId': group.groupId, 'groupCode': group.groupCode};

    return await db.insert(
      'groups',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<R2Group?> getGroup(int uid) async {
    final db = await database;
    R2Group? group;
    final result = await db.query(
      'groups',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (result.isNotEmpty) {
      Map<String, dynamic> data = result.first;
      final groupId = data['groupId'];
      final groupCode = data['groupCode'];
      group = R2Group(groupId: groupId, groupCode: groupCode);
    } else {
      group = null;
    }
    return group;
  }

  Future<int> deleteGroup(int groupId) async {
    final db = await database;
    return await db.delete(
      'groups',
      where: 'groupId = ?',
      whereArgs: [groupId],
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

  Future<R2Device?> getFirstDevice() async {
    final db = await database;
    final result = await db.query('devices');
    return result.isNotEmpty ? R2Device.fromMap(result.first) : null;
  }

  Future<R2Device?> getDevice(String deviceId) async {
    final db = await database;
    final result = await db.query(
      'devices',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );
    return result.isNotEmpty ? R2Device.fromMap(result.first) : null;
  }

  Future<int> deleteDevice(String deviceId) async {
    final db = await database;
    return await db.delete(
      'devices',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );
  }

  Future<int> deleteAllDevices() async {
    final db = await database;
    return await db.delete('devices');
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

  Future<void> saveEmergencyContactEnabled(String ifEmergencyContactEnable) async {
    final db = await database;
    final emergencyContactEnabled = ifEmergencyContactEnable == 'true' ? 1 : 0;
    await db.insert(
      'settings',
      {'id': 1, 'emergencyContactEnabled': emergencyContactEnabled},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}