import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../model/RoomModel.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbRooms {
  DbHelper dbHelper = DbHelper();

  Future<List<RoomModel>> allRooms() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('rooms')
          .orderBy('room_name', descending: false)
          .get();
      return snap.docs.map((doc) => RoomModel.fromMap(doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from rooms ORDER by room_name ASC';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult
        .map((e) => RoomModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addRoom(String roomName) async {
    if (kIsWeb) {
      final id = DateTime.now().millisecondsSinceEpoch;
      final model = RoomModel(id: id, name: roomName);
      await FirebaseSyncService.instance.syncRoom(model);
      return;
    }
    Database? db = await dbHelper.openDb();
    final id = await db!.insert(
      'rooms',
      {'room_name': roomName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final model = RoomModel(id: id, name: roomName);
    await FirebaseSyncService.instance.pushRoom(model);
  }

  Future<void> deleteRoom(int id) async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance.collection('rooms').where('id', isEqualTo: id).get();
      for (var doc in snap.docs) {
        await doc.reference.delete();
      }
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.delete(
      'rooms',
      where: 'room_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRoom(int id, String roomName) async {
    final model = RoomModel(id: id, name: roomName);
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncRoom(model);
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.update(
      'rooms',
      {'room_name': roomName},
      where: 'room_id = ?',
      whereArgs: [id],
    );
    await FirebaseSyncService.instance.pushRoom(model);
  }

  Future<void> updateRoomName(String oldName, String newName) async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance.collection('rooms').where('room_name', isEqualTo: oldName).get();
      for (var doc in snap.docs) {
        await doc.reference.update({'room_name': newName});
      }
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.update(
      'rooms',
      {'room_name': newName},
      where: 'room_name = ?',
      whereArgs: [oldName],
    );
  }

  Future<void> deleteRoomByName(String roomName) async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance.collection('rooms').where('room_name', isEqualTo: roomName).get();
      for (var doc in snap.docs) {
        await doc.reference.delete();
      }
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.delete(
      'rooms',
      where: 'room_name = ?',
      whereArgs: [roomName],
    );
  }

  Future<bool> tableExists() async {
    if (kIsWeb) return true;
    Database? db = await dbHelper.openDb();
    final result = await db!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='rooms'",
    );
    return result.isNotEmpty;
  }

  Future<void> createRoomsTable() async {
    if (kIsWeb) return;
    Database? db = await dbHelper.openDb();
    try {
      await db!.execute(
        '''CREATE TABLE IF NOT EXISTS rooms
          (
            room_id INTEGER PRIMARY KEY,
            room_name TEXT NOT NULL UNIQUE
          )''',
      );
      print('Rooms table created successfully');
    } catch (e) {
      print('Error creating rooms table: $e');
    }
  }

  Future<void> ensureDefaultRooms() async {
    await createRoomsTable();
    final rooms = await allRooms();
    if (rooms.isEmpty) {
      // حفظ الغرف الافتراضية
      await addRoom('غرفة 1');
      await addRoom('غرفة 2');
      await addRoom('غرفة 3');
      print('Default rooms added');
    }
  }
}
