// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:ondoor/services/sqlite_database/DBConstant.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DatabaseHelper extends ChangeNotifier {
//   static final DatabaseHelper db = DatabaseHelper.internal();
//
//   DatabaseHelper.internal();
//
//   factory DatabaseHelper() {
//     return db;
//   }
//
//   static Database? database;
//
//   static Future<Database> getDatabase() async {
//     if (database == null) {
//       database = await initDB();
//     }
//     return database!;
//   }
//
//   //init data base
//   static initDB() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, DBConstant.DATA_BASE_NAME);
//     return await openDatabase(path, version: 1, onOpen: (db) {},
//         onCreate: (Database db, int version) async {
//       await db.execute(DBConstant.CREATE_CART_TABLE);
//     });
//   }
//
//   //Clear database
//   static clearDatabase() async {
//     try {
//       final db = await getDatabase();
//       //here we execute a query to drop the table if exists which is called "tableName"
//       //and could be given as method's input parameter too
//       await db.execute("DROP TABLE IF EXISTS ${DBConstant.CART_TABLE}");
//
//       await db.execute(DBConstant.CREATE_CART_TABLE);
//     } catch (error) {
//       throw Exception('DatabaseHelper.clearDatabase: $error');
//     }
//   }
//
// //   static Future<int> addGiftToCart(GiftDataModel giftDataModel) async {
// //     int id = 0;
// //     try {
// //       giftDataModel.userId =
// //           await Utility.getStringPreference(Constant.USER_ID);
//
// //       final db = await getDatabase();
//
// //       bool exist = await checkGiftExist(giftDataModel.id.toString());
//
// //       if (exist) {
// //         List<Map<String, dynamic>> data = await db.query(DBConstant.CART_TABLE,
// //             columns: [DBConstant.QUANTITY],
// //             where: DBConstant.GIFT_ID + "= ? AND " + DBConstant.USER_ID + "= ?",
// //             whereArgs: [
// //               giftDataModel.id.toString(),
// //               await Utility.getStringPreference(Constant.USER_ID)
// //             ]);
//
// //         int q = data.first["quantity"] as int;
//
// //         giftDataModel.quantity = giftDataModel.quantity! + q;
//
// //         id = await db.update(DBConstant.CART_TABLE, giftDataModel.toMap(),
// //             whereArgs: [
// //               giftDataModel.id.toString(),
// //               await Utility.getStringPreference(Constant.USER_ID)
// //             ],
// //             where:
// //                 DBConstant.GIFT_ID + "= ? AND " + DBConstant.USER_ID + "= ?");
// //       } else {
// //         id = await db.insert(DBConstant.CART_TABLE, giftDataModel.toMap());
// //       }
//
// //       /**
// //        * close database
// //        */
// //       // db.close();
// //     } catch (error) {
// //       print('DatabaseHelper.addProductInRetrievalTable: ' + error.toString());
// //     }
//
// //     return id;
// //   }
//
// //   static Future<List<GiftDataModel>> getCart() async {
// //     List<GiftDataModel> cart = [];
//
// //     try {
// //       final db = await getDatabase();
// //       String selectQuery = "SELECT  * FROM ${DBConstant.CART_TABLE} WHERE " +
// //           DBConstant.USER_ID +
// //           "= ?";
// //       List<Map<String, dynamic>> data = await db.rawQuery(
// //           selectQuery, [await Utility.getStringPreference(Constant.USER_ID)]);
// //       // log(data.toString());
//
// //       if (data.isNotEmpty) {
// //         data.forEach((element) {
// //           GiftDataModel giftDataModel =
// //               GiftDataModel.fromJson(jsonEncode(element));
//
// //           print(giftDataModel.toMap());
// //           cart.add(giftDataModel);
// //         });
// //       }
//
// //       /**
// //        * close database
// //        */
// //       // db.close();
// //     } catch (error) {
// //       print('DatabaseHelper.addProductInRetrievalTable: ' + error.toString());
// //     }
//
// //     return cart;
// //   }
//
// //   static Future<int> getCartCount() async {
// //     int count = 0;
//
// //     try {
// //       final db = await getDatabase();
// //       String selectQuery = "SELECT  * FROM ${DBConstant.CART_TABLE} WHERE " +
// //           DBConstant.USER_ID +
// //           "= ?";
// //       List<Map<String, dynamic>> data = await db.rawQuery(
// //           selectQuery, [await Utility.getStringPreference(Constant.USER_ID)]);
//
// //       if (data.isNotEmpty) {
// //         data.forEach((element) {
// //           count = count + element[DBConstant.QUANTITY] as int;
// //         });
// //       }
//
// //       Constant.cartCount = count;
//
// //       /**
// //        * close database
// //        */
// //       // db.close();
// //     } catch (error) {
// //       print('DatabaseHelper.addProductInRetrievalTable: ' + error.toString());
// //     }
//
// //     return count;
// //   }
//
// //   static Future<int> getGiftCountByGiftId(String giftId) async {
// //     // debugPrint("getGiftCountByGiftId-->$giftId");
// //     int count = 0;
//
// //     try {
// //       final db = await getDatabase();
// //       String selectQuery = "SELECT  * FROM ${DBConstant.CART_TABLE} WHERE " +
// //           DBConstant.USER_ID +
// //           " = ? AND " +
// //           DBConstant.GIFT_ID +
// //           " = ?";
// //       List<Map<String, dynamic>> data = await db.rawQuery(selectQuery,
// //           [await Utility.getStringPreference(Constant.USER_ID), giftId]);
//
// //       if (data.isNotEmpty) {
// //         data.forEach((element) {
// //           count = count + element[DBConstant.QUANTITY] as int;
// //         });
// //       }
//
// //       Constant.cartCount = count;
//
// //       /**
// //        * close database
// //        */
// //       // db.close();
// //     } catch (error) {
// //       print('DatabaseHelper.addProductInRetrievalTable: ' + error.toString());
// //     }
//
// //     return count;
// //   }
//
// //   static Future<bool> clearCart() async {
// //     bool clear = false;
//
// //     try {
// //       final db = await getDatabase();
//
// //       int i = await db.delete(DBConstant.CART_TABLE,
// //           where: DBConstant.USER_ID + " = ?",
// //           whereArgs: [await Utility.getStringPreference(Constant.USER_ID)]);
//
// //       if (i > 0) {
// //         clear = true;
// //         Constant.cartCount = 0;
// //       }
//
// //       /**
// //        * close database
// //        */
// //       // db.close();
// //     } catch (error) {
// //       print('DatabaseHelper.addProductInRetrievalTable: ' + error.toString());
// //     }
//
// //     return clear;
// //   }
//
// //   static Future<bool> deleteItemFromCart(GiftDataModel giftDataModel) async {
// //     bool clear = false;
//
// //     try {
// //       final db = await getDatabase();
//
// //       int i = await db.delete(DBConstant.CART_TABLE,
// //           where: DBConstant.USER_ID + "= ? AND " + DBConstant.GIFT_ID + "= ? ",
// //           whereArgs: [
// //             await Utility.getStringPreference(Constant.USER_ID),
// //             giftDataModel.id
// //           ]);
//
// //       if (i > 0) {
// //         clear = true;
// //       }
//
// //       /**
// //        * close database
// //        */
// //       // db.close();
// //     } catch (error) {
// //       print('DatabaseHelper.addProductInRetrievalTable: ' + error.toString());
// //     }
//
// //     return clear;
// //   }
//
// //   static Future<bool> checkGiftExist(String giftId) async {
// //     bool isExist = false;
// //     try {
// //       final db = await getDatabase();
//
// //       //String selectQuery = "SELECT  * FROM " + DBConstant.TABLE_ALL_PRODUCT + " WHERE " + DBConstant.ORDER_ID + " = '" + order_id + "' AND " + DBConstant.CUSTOM_PRODUCT_ID + "='" + custom_product_id + "' AND " + DBConstant.IS_OFFER_PRODUCT + "='" + isOfferProduct + "'";
// //       String selectQuery = "SELECT  * FROM " +
// //           DBConstant.CART_TABLE +
// //           " WHERE " +
// //           DBConstant.GIFT_ID +
// //           " = '" +
// //           giftId +
// //           "' AND " +
// //           DBConstant.USER_ID +
// //           "='" +
// //           await Utility.getStringPreference(Constant.USER_ID) +
// //           "'";
// //       List<Map> result = await db.rawQuery(selectQuery);
// //       if (result.length > 0) {
// //         isExist = true;
// //       }
// //       // db.close();
// //     } catch (error) {
// //       print('DatabaseHelper.checkProductIfAlreadyExist: ' + error.toString());
// //     }
//
// //     return isExist;
// //   }
// }
//
// abstract class CartUpdateListener {
//   onUpdate();
// }
