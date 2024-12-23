import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:ondoor/screens/AddCard/card_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/AllProducts.dart';
import '../screens/AddCard/card_event.dart';
import 'dbconstants.dart';

class DatabaseHelper {
  late Database _db;

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DBConstants.DATABASE_NAME);
    _db = await openDatabase(
      path,
      version: DBConstants.VERSION,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
/*
    await db.execute('''
        CREATE TABLE IF NOT EXISTS ${DBConstants.ADDRESS_LIST_TABLE} (
          ${DBConstants.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          ${DBConstants.PLACEID} TEXT,
          ${DBConstants.LAT} TEXT,
          ${DBConstants.LNG} TEXT,
          ${DBConstants.LANDMARK} TEXT,
          ${DBConstants.ADDRESS} TEXT,
          ${DBConstants.POSTALCODE} TEXT,
          ${DBConstants.CITY} TEXT,
          ${DBConstants.STATE} TEXT,
          ${DBConstants.INSERTED_DATE} TEXT,
          ${DBConstants.ADDRESS_TYPE} TEXT,
        )
      ''');
*/
    await db.execute('''
  CREATE TABLE IF NOT EXISTS ${DBConstants.ADDRESS_LIST_TABLE} (
    ${DBConstants.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    ${DBConstants.PLACEID} TEXT,
    ${DBConstants.LAT} TEXT,
    ${DBConstants.LNG} TEXT,
    ${DBConstants.LANDMARK} TEXT,
    ${DBConstants.ADDRESS} TEXT,
    ${DBConstants.POSTALCODE} TEXT,
    ${DBConstants.CITY} TEXT,
    ${DBConstants.STATE} TEXT,
    ${DBConstants.INSERTED_DATE} TEXT,
    ${DBConstants.ADDRESS_TYPE} TEXT
  )
''');
    await db.execute('''
    CREATE TABLE ${DBConstants.PRODUCT_LIST_TABLE} (
      ${DBConstants.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      ${DBConstants.PRODUCT_ID} INTEGER,
      ${DBConstants.PRODUCT_NAME} TEXT,
      ${DBConstants.PRODUCT_WEIGHT} TEXT,
      ${DBConstants.PRODUCT_WEIGHT_UNIT} TEXT,
      ${DBConstants.ORDER_QTY_LIMIT} TEXT,
      ${DBConstants.CNF_SHIPPING_SURCHARGE} TEXT,
      ${DBConstants.SHIPPING_MAX_AMOUNT} TEXT,
      ${DBConstants.IMAGE} TEXT,
      ${DBConstants.DISTEXT} TEXT,
      ${DBConstants.DISLABEL} TEXT,
      ${DBConstants.DETAIL_IMAGE} TEXT,
      ${DBConstants.IMAGE_ARRAY} TEXT DEFAULT '[]',
      ${DBConstants.PRICE} REAL,
      ${DBConstants.SPECIAL_PRICE} REAL,
      ${DBConstants.SORT_PRICE} REAL,
      ${DBConstants.OPTION_PRICE_ALL} REAL DEFAULT 0 NOT NULL,
      ${DBConstants.DESCRIPTION} TEXT,
      ${DBConstants.MODEL} TEXT,
      ${DBConstants.QUANTITY} INTEGER,
      ${DBConstants.TOTALQUANTITY} INTEGER,
      ${DBConstants.SUBTRACT} TEXT,
      ${DBConstants.MSG_ON_CAKE} TEXT,
      ${DBConstants.MSG_ON_CARD} TEXT,
      ${DBConstants.VENDOR_PRODUCT} TEXT,
      ${DBConstants.SELLER_ID} TEXT,
      ${DBConstants.GIFT_ITEM} TEXT,
      ${DBConstants.SHIPPING_OPTION_ID} TEXT,
      ${DBConstants.DELIVERY_DATE} TEXT,
      ${DBConstants.DELIVERY_TIME_SLOT} TEXT,
      ${DBConstants.TIME_SLOT_JSON} TEXT,
      ${DBConstants.SHIPPING_CHARGE} TEXT,
      ${DBConstants.IS_OPTION} TEXT,
      ${DBConstants.SELLER_NICKNAME} TEXT,
      ${DBConstants.SHOW_CARD_MSG} TEXT,
      ${DBConstants.SHOW_CAKE_MGS} TEXT,
      ${DBConstants.SHIPPING_JSON} TEXT,
      ${DBConstants.SHIPPING_OPTION_SELECTED} TEXT,
      ${DBConstants.TIME_SLOT_SELECT} TEXT,
      ${DBConstants.SELLER_DATA} TEXT,
      ${DBConstants.OPTION_UNI} TEXT,
      ${DBConstants.OPTION_JSON_ALL} TEXT,
      ${DBConstants.ACTUAL_SHIPPING_CHARGE} REAL DEFAULT 0,
      ${DBConstants.REWARD_POINTS} TEXT DEFAULT '',
      ${DBConstants.OFFER_DESC} TEXT DEFAULT '',
      ${DBConstants.OFFER_LABEL} TEXT DEFAULT '',
      ${DBConstants.OFFER_ID} TEXT DEFAULT '',
      ${DBConstants.OFFER_TYPE} TEXT DEFAULT '',
      ${DBConstants.SUB_PRODUCT} TEXT DEFAULT '',
      ${DBConstants.OFFER_PRODUCT} TEXT DEFAULT '',
      ${DBConstants.OFFER_COUNT} INTEGER DEFAULT 0,
      ${DBConstants.OFFER_MAX} INTEGER DEFAULT 0,
      ${DBConstants.OFFER_APPLIED} TEXT DEFAULT '',
      ${DBConstants.OFFER_WARNING} TEXT DEFAULT '',
      ${DBConstants.BUY_QTY} INTEGER DEFAULT 0,
      ${DBConstants.GET_QTY} INTEGER DEFAULT 0
    )
  ''');
  }

  Future<List<Map<String, dynamic>>> retrieveAddressFromLocal() async {
    return await _db.query(DBConstants.ADDRESS_LIST_TABLE);
  }

  Future<int> insertAddCardProduct(Map<String, dynamic> row) async {
    return await _db.insert(DBConstants.PRODUCT_LIST_TABLE, row);
  }

  Future<int> insertAddress(Map<String, dynamic> row) async {
    return await _db.insert(DBConstants.ADDRESS_LIST_TABLE, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRowsCardProducts() async {
    return await _db.query(DBConstants.PRODUCT_LIST_TABLE);
  }

  Future<int> updateCard(Map<String, dynamic> row) async {
    print("updateCardupdateCard${row}");
    int id = row[DBConstants.PRODUCT_ID];
    return await _db.update(
      DBConstants.PRODUCT_LIST_TABLE,
      row,
      where: '${DBConstants.PRODUCT_ID} = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateAddress(Map<String, dynamic> row) async {
    int id = row[DBConstants.ID];
    return await _db.update(
      DBConstants.ADDRESS_LIST_TABLE,
      row,
      where: '${DBConstants.ID} = ?',
      whereArgs: [id],
    );
  }

  Future<int> cleanCartDatabase() async {
    return await _db.delete(DBConstants.PRODUCT_LIST_TABLE);
  }

  Future<int> deleteCard(int id) async {
    return await _db.delete(
      DBConstants.PRODUCT_LIST_TABLE,
      where: '${DBConstants.PRODUCT_ID} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAddressCard(int id) async {
    return await _db.delete(
      DBConstants.ADDRESS_LIST_TABLE,
      where: '${DBConstants.ID} = ?',
      whereArgs: [id],
    );
  }

  updateCard2(ProductUnit model, CardBloc cardBloc) async {
    int status = await updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
    });

    loadAddCardProducts(cardBloc);
  }

  addCard(ProductUnit model, CardBloc cardBloc) async {
    if (model.addQuantity != 0) {
      print("${jsonEncode(model.imageArray)}       >>>>>>>>>>>>>>>>>>");
      String image_array_json = "";

      print("Image Array .length " + model.imageArray!.length.toString());
      for (int i = 0; i < model!.imageArray!.length; i++) {
        print("** $i ");
        if (i == 0) {
          image_array_json = model!.imageArray![i].toJson() + "";
        } else {
          image_array_json =
              image_array_json + "," + model!.imageArray![i].toJson();
        }
      }

      if (image_array_json.startsWith(',')) {
        image_array_json = image_array_json.substring(1);
      }
      image_array_json = '[${image_array_json}]';

      print("Moodel to Add " + image_array_json);
      bool isSubProductAvailable = false;

      if (model!.cOfferId != 0 && model.cOfferId != null) {
        debugPrint("SubProduct Json >>>${model.subProduct!.toJson()}");
        isSubProductAvailable = true;
      }
      int status = await insertAddCardProduct({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.PRODUCT_NAME: model.name,
        DBConstants.PRODUCT_WEIGHT: model.productWeight,
        DBConstants.PRODUCT_WEIGHT_UNIT: model.productWeightUnit,
        DBConstants.ORDER_QTY_LIMIT: model.orderQtyLimit,
        DBConstants.CNF_SHIPPING_SURCHARGE: "",
        DBConstants.SHIPPING_MAX_AMOUNT: "",
        DBConstants.IMAGE: model.image,
        DBConstants.DISTEXT: model.discountText,
        DBConstants.DISLABEL: model.discountLabel,
        DBConstants.DETAIL_IMAGE: model.detailsImage,
        DBConstants.IMAGE_ARRAY: image_array_json,
        DBConstants.PRICE: model.price,
        DBConstants.SPECIAL_PRICE: model.specialPrice,
        DBConstants.SORT_PRICE: model.sortPrice,
        DBConstants.OPTION_PRICE_ALL: 0,
        DBConstants.DESCRIPTION: model.description,
        DBConstants.MODEL: model.model,
        DBConstants.QUANTITY: model.addQuantity,
        DBConstants.TOTALQUANTITY: model.quantity,
        DBConstants.SUBTRACT: model.subtract,
        DBConstants.MSG_ON_CAKE: model.messageOnCake,
        DBConstants.MSG_ON_CARD: model.messageOnCard,
        DBConstants.VENDOR_PRODUCT: model.ondoorProduct,
        DBConstants.SELLER_ID: "",
        DBConstants.GIFT_ITEM: "",
        DBConstants.SHIPPING_OPTION_ID: "",
        DBConstants.DELIVERY_DATE: "",
        DBConstants.DELIVERY_TIME_SLOT: "",
        DBConstants.TIME_SLOT_JSON: "",
        DBConstants.SHIPPING_CHARGE: "",
        DBConstants.IS_OPTION: model.isOption,
        DBConstants.SELLER_NICKNAME: "",
        DBConstants.SHOW_CARD_MSG: model.messageOnCard,
        DBConstants.SHOW_CAKE_MGS: model.messageOnCake,
        DBConstants.SHIPPING_JSON: "",
        DBConstants.SHIPPING_OPTION_SELECTED: "",
        DBConstants.TIME_SLOT_SELECT: "",
        DBConstants.SELLER_DATA: "",
        DBConstants.OPTION_UNI: "",
        DBConstants.OPTION_JSON_ALL: "",
        DBConstants.ACTUAL_SHIPPING_CHARGE: 0,
        DBConstants.REWARD_POINTS: model.rewardPoints,
        DBConstants.OFFER_DESC: "",
        DBConstants.OFFER_LABEL: "",
        DBConstants.OFFER_ID: model.cOfferId.toString(),
        DBConstants.OFFER_TYPE: model.cOfferType.toString(),
        DBConstants.SUB_PRODUCT:
            isSubProductAvailable ? model.subProduct!.toJson() : "",
        DBConstants.OFFER_PRODUCT: "",
        DBConstants.OFFER_COUNT: 0,
        DBConstants.OFFER_MAX: 0,
        DBConstants.OFFER_APPLIED: "",
        DBConstants.OFFER_WARNING: "",
        DBConstants.BUY_QTY: 0,
        DBConstants.GET_QTY: 0
      });

      print("Add Card Status $status");

      cardBloc.add(AddCardEvent(count: status));
      loadAddCardProducts(cardBloc);
    }
  }

  Future<bool> checkItemId(String id) async {
    final allRows = await queryAllRowsCardProducts();
    for (final row in allRows) {
      String id2 = row[DBConstants.PRODUCT_ID].toString();

      if (id == id2) {
        return true;
      }
    }
    return false;
  }

  Future<int> getQuanityt(String id) async {
    final allRows = await queryAllRowsCardProducts();
    for (final row in allRows) {
      String id2 = row[DBConstants.PRODUCT_ID].toString();

      if (id == id2) {
        return row[DBConstants.QUANTITY];
      }
    }
    return 0;
  }

  loadAddCardProducts(CardBloc cardBloc) async {
    final allRows = await queryAllRowsCardProducts();

    List<ProductUnit> al = [];
    for (final row in allRows) {
      print(row.toString());

      ProductUnit model = ProductUnit();

      model.productId = row[DBConstants.PRODUCT_ID].toString();
      model.name = row[DBConstants.PRODUCT_NAME];
      model.productWeight = row[DBConstants.PRODUCT_WEIGHT];
      model.productWeightUnit = row[DBConstants.PRODUCT_WEIGHT_UNIT];
      model.orderQtyLimit = row[DBConstants.ORDER_QTY_LIMIT];
      model.image = row[DBConstants.IMAGE];
      model.discountLabel = row[DBConstants.DISLABEL];
      model.discountText = row[DBConstants.DISTEXT];
      model.detailsImage = row[DBConstants.DETAIL_IMAGE];
      model.price = row[DBConstants.PRICE].toString();
      model.specialPrice = row[DBConstants.SPECIAL_PRICE].toString();
      model.sortPrice = row[DBConstants.SORT_PRICE].toString();
      model.description = row[DBConstants.DESCRIPTION];
      model.model = row[DBConstants.MODEL];
      model.addQuantity = row[DBConstants.QUANTITY];
      model.quantity = row[DBConstants.TOTALQUANTITY].toString();
      model.subtract = row[DBConstants.SUBTRACT];
      model.messageOnCake = row[DBConstants.MSG_ON_CAKE];
      model.messageOnCard = row[DBConstants.MSG_ON_CARD];
      model.isOption = row[DBConstants.IS_OPTION];
      model.rewardPoints = row[DBConstants.REWARD_POINTS];

      print("OFFER_TYPE${row[DBConstants.OFFER_TYPE]}");
      print("OFFER_ID${row[DBConstants.OFFER_ID]}");
      print("OFFER_ID${row[DBConstants.OFFER_TYPE] == "null"}");

      log("" + row[DBConstants.OFFER_TYPE]);
      if (row[DBConstants.OFFER_TYPE] != "null" &&
          row[DBConstants.OFFER_TYPE] != "") {
        model.cOfferType = int.parse(row[DBConstants.OFFER_TYPE] ?? "0");
      }
      if (row[DBConstants.OFFER_ID] != "null" &&
          row[DBConstants.OFFER_ID] != "") {
        model.cOfferId = int.parse(row[DBConstants.OFFER_ID] ?? "0");
      }

      model.subProduct = row[DBConstants.SUB_PRODUCT] == ""
          ? null
          : SubProduct.fromJson(row[DBConstants.SUB_PRODUCT]);

      List<ImageArray> list_imagearray = [];
      print("LOAD IMAGE ARRAY ${row[DBConstants.IMAGE_ARRAY]}");
      print(
          "Sub Product >>  ${row[DBConstants.SUB_PRODUCT] == "" ? null : SubProduct.fromJson(row[DBConstants.SUB_PRODUCT])}");
      String jsonString = '''${row[DBConstants.IMAGE_ARRAY].toString()}''';
      List<dynamic> jsonData = jsonDecode(jsonString);

      // Accessing data
      for (var item in jsonData) {
        int type = item['type'];
        String title = item['title'];
        String imageUrl = item['image_url'];
        String videoUrl = item['video_url'];

        // Printing the values
        print('Type: $type');
        print('Title: $title');
        print('Image URL: $imageUrl');
        print('Video URL: $videoUrl');
        ImageArray imageArray = ImageArray();
        imageArray.type = type;
        imageArray.title = title;
        imageArray.imageUrl = imageUrl;
        imageArray.videoUrl = videoUrl;

        list_imagearray.add(imageArray);
      }

      model.imageArray = list_imagearray;

      al.add(model);
    }
    print("All Add Card Models " + al.length.toString());
    if (al.isNotEmpty) {
      cardBloc.add(CardNullEvent());
      cardBloc.add(AddCardProductEvent(listProduct: al));
    } else {
      cardBloc.add(CardEmptyEvent());
    }
  }

  getAllCarts(CardBloc cardBloc) async {
    final allRows = await queryAllRowsCardProducts();

    List<ProductUnit> al = [];
    for (final row in allRows) {
      print(row.toString());

      ProductUnit model = ProductUnit();

      model.productId = row[DBConstants.PRODUCT_ID].toString();
      model.name = row[DBConstants.PRODUCT_NAME];
      model.productWeight = row[DBConstants.PRODUCT_WEIGHT];
      model.productWeightUnit = row[DBConstants.PRODUCT_WEIGHT_UNIT];
      model.orderQtyLimit = row[DBConstants.ORDER_QTY_LIMIT];
      model.image = row[DBConstants.IMAGE];
      model.discountLabel = row[DBConstants.DISLABEL];
      model.discountText = row[DBConstants.DISTEXT];
      model.detailsImage = row[DBConstants.DETAIL_IMAGE];
      model.price = row[DBConstants.PRICE].toString();
      model.specialPrice = row[DBConstants.SPECIAL_PRICE].toString();
      model.sortPrice = row[DBConstants.SORT_PRICE].toString();
      model.description = row[DBConstants.DESCRIPTION];
      model.model = row[DBConstants.MODEL];
      model.addQuantity = row[DBConstants.QUANTITY];
      model.quantity = row[DBConstants.TOTALQUANTITY].toString();
      model.subtract = row[DBConstants.SUBTRACT];
      model.messageOnCake = row[DBConstants.MSG_ON_CAKE];
      model.messageOnCard = row[DBConstants.MSG_ON_CARD];
      model.isOption = row[DBConstants.IS_OPTION];
      model.rewardPoints = row[DBConstants.REWARD_POINTS];

      print("OFFER_TYPE${row[DBConstants.OFFER_TYPE]}");
      print("OFFER_ID${row[DBConstants.OFFER_ID]}");
      print("OFFER_ID${row[DBConstants.OFFER_TYPE] == "null"}");

      log("" + row[DBConstants.OFFER_TYPE]);
      if (row[DBConstants.OFFER_TYPE] != "null" &&
          row[DBConstants.OFFER_TYPE] != "") {
        model.cOfferType = int.parse(row[DBConstants.OFFER_TYPE] ?? "0");
      }
      if (row[DBConstants.OFFER_ID] != "null" &&
          row[DBConstants.OFFER_ID] != "") {
        model.cOfferId = int.parse(row[DBConstants.OFFER_ID] ?? "0");
      }

      model.subProduct = row[DBConstants.SUB_PRODUCT] == ""
          ? null
          : SubProduct.fromJson(row[DBConstants.SUB_PRODUCT]);

      List<ImageArray> list_imagearray = [];
      print("LOAD IMAGE ARRAY ${row[DBConstants.IMAGE_ARRAY]}");
      print(
          "Sub Product >>  ${row[DBConstants.SUB_PRODUCT] == "" ? null : SubProduct.fromJson(row[DBConstants.SUB_PRODUCT])}");
      String jsonString = '''${row[DBConstants.IMAGE_ARRAY].toString()}''';
      List<dynamic> jsonData = jsonDecode(jsonString);

      // Accessing data
      for (var item in jsonData) {
        int type = item['type'];
        String title = item['title'];
        String imageUrl = item['image_url'];
        String videoUrl = item['video_url'];

        // Printing the values
        print('Type: $type');
        print('Title: $title');
        print('Image URL: $imageUrl');
        print('Video URL: $videoUrl');
        ImageArray imageArray = ImageArray();
        imageArray.type = type;
        imageArray.title = title;
        imageArray.imageUrl = imageUrl;
        imageArray.videoUrl = videoUrl;

        list_imagearray.add(imageArray);
      }

      model.imageArray = list_imagearray;

      al.add(model);
    }
    print("All Add Card Models " + al.length.toString());
    if (al.length != 0) {
      cardBloc.add(AddCardProductEvent(listProduct: al));
    } else {
      cardBloc.add(CardEmptyEvent());
    }

    return al;
  }
}
