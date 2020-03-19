import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'image_link.dart';
 
class DBHelper 
{
  static Database _db;

  // Columns

  static const String ID      = 'id';
  static const String LINK    = 'link';
  static const String UID     = 'user_id';

  // Table 
  static const String TABLE   = 'SavedImages';

  // Database
  static const String DB_NAME = 'local.db';
 
  Future<Database> get db async 
  {
    if (_db != null) 
    {
      return _db;
    }
    _db = await initDb();
    return _db;
  }
 
  initDb() async 
  {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, DB_NAME);

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);

    return db;
  }
 
  _onCreate(Database db, int version) async 
  {
    await db.execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $LINK TEXT, $UID INTEGER)");
  }
 
  Future<ImageLink> create(ImageLink imageLink) async 
  {
    var dbClient = await db;

    imageLink.id = await dbClient.insert(TABLE, imageLink.toMap());

    return imageLink;
  }
 
  Future<List<ImageLink>> getAllRecordsByUser(String userId) async 
  {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(TABLE, columns: [ID, LINK, UID], where: 'user_id = ?', whereArgs: [userId]);

    List<ImageLink> imageLink = [];

    if (maps.length > 0) 
    {
      for (int i = 0; i < maps.length; i++) 
      {
        imageLink.add(ImageLink.fromMap(maps[i]));
      }
    }

    return imageLink;
  }

  Future<int> findIfExistsByUser(String link, String userId) async 
  {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(TABLE, columns: [ID,LINK,UID], where: 'link = ? AND user_id = ?', whereArgs: [link, userId] );

    if (maps.length > 0) 
    {
      return maps.length;
    }
    else
    {
      return -1;
    }
  }

  Future<int> update(ImageLink imageLink) async 
  {
    var dbClient = await db;

    return await dbClient.update(TABLE, imageLink.toMap(), where: '$ID = ?', whereArgs: [imageLink.id]);
  }
 
  Future<int> deleteById(int id) async 
  {
    var dbClient = await db;

    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  Future<int> deleteByLink(String link) async 
  {
    var dbClient = await db;

    return await dbClient.delete(TABLE, where: 'link = ?', whereArgs: [link]);
  }
 
  Future close() async 
  {
    var dbClient = await db;

    dbClient.close();
  }
}