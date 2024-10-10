import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/controllers/split_payment_controller.dart';
import 'package:flutter_expense_tracker_app/models/transaction.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // Make sure to import this for path operations

class DatabaseProvider {
  static Database? _db;
  static final int _version = 2; // Incremented version
  static final String _tableName = 'transactions';
  static final String _path = 'expenses.db';
  static final String _splitPaymentTable = 'split_payments';

  static Future<void> initDb() async {
    // deleteDatabase();
    if (_db != null) {
      return; // If the database is already initialized, return
    }
    try {
      String path =
          join(await getDatabasesPath(), _path); // Correctly join the path
      _db = await openDatabase(
        path,
        version: _version,
        onCreate: (db, version) async {
          // Create transactions table
          await db.execute('''
            CREATE TABLE $_tableName(
              id TEXT PRIMARY KEY,
              type TEXT, 
              image TEXT, 
              name TEXT, 
              amount TEXT, 
              date TEXT, 
              time TEXT, 
              category TEXT, 
              mode TEXT)
          ''');

          // Create split payments table
          await db.execute('''
            CREATE TABLE $_splitPaymentTable(
              id TEXT PRIMARY KEY,
              description TEXT,
              paidBy TEXT,
              isPaid INTEGER DEFAULT 0,  
              amount REAL)
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Add the isPaid column if upgrading from version 1
            await db.execute('''
              ALTER TABLE $_splitPaymentTable ADD COLUMN isPaid INTEGER DEFAULT 0
            ''');
          }
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error initializing database: $e',
        backgroundColor: Color(0xFF212121),
        colorText: Colors.red,
      );
    }
  }

  static Future<int> insertTransaction(TransactionModel transaction) async {
    if (_db == null) await initDb(); // Ensure DB is initialized
    return await _db!.insert(_tableName, transaction.toMap());
  }

  static Future<int> deleteTransaction(String id) async {
    if (_db == null) await initDb(); // Ensure DB is initialized
    return await _db!.delete(_tableName, where: 'id=?', whereArgs: [id]);
  }

  static Future<int> updateTransaction(TransactionModel tm) async {
    if (_db == null) await initDb(); // Ensure DB is initialized
    return await _db!.update(
      _tableName,
      tm.toMap(),
      where: 'id = ?',
      whereArgs: [tm.id],
    );
  }

  static Future<List<Map<String, dynamic>>> queryTransaction() async {
    if (_db == null) await initDb(); // Ensure DB is initialized
    return await _db!.query(_tableName);
  }

  static Future<int> insertSplitPayment(SplitPayment payment) async {
    if (_db == null) await initDb(); // Ensure DB is initialized
    return await _db!.insert(_splitPaymentTable, payment.toMap());
  }

  // static Future<List<SplitPayment>> querySplitPayments() async {
  //   if (_db == null) await initDb(); // Ensure DB is initialized
  //   final List<Map<String, dynamic>> maps =
  //       await _db!.query(_splitPaymentTable);
  //   return List.generate(maps.length, (i) {
  //     return SplitPayment.fromMap(maps[i]);
  //   });
  // }

  static Future<List<SplitPayment>> querySplitPayments() async {
    if (_db == null) await initDb(); // Ensure DB is initialized
    final List<Map<String, dynamic>> maps =
        await _db!.query(_splitPaymentTable);

    // Debug: Print the maps to see what is retrieved
    print(maps);

    return List.generate(maps.length, (i) {
      return SplitPayment.fromMap(maps[i]);
    });
  }


  static Future<int> deleteSplitPayment(String id) async {
    if (_db == null) await initDb(); // Ensure DB is initialized
    return await _db!
        .delete(_splitPaymentTable, where: 'id=?', whereArgs: [id]);
  }

  static Future<int> updateSplitPayment(SplitPayment payment) async {
    if (_db == null) await initDb(); // Ensure DB is initialized
    return await _db!.update(
      _splitPaymentTable,
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }
 static Future<void> deleteDatabase() async {
    try {
      // Get the directory where the database is stored
      String path = join(await getDatabasesPath(), _path); 

      // Check if the database file exists
      final file = File(path);
      if (await file.exists()) {
        // Delete the database file
        await file.delete();
        print("Database deleted successfully.");
      } else {
        print("Database file does not exist.");
      }
    } catch (e) {
      print("Error deleting database: $e");
    }
  }
}
