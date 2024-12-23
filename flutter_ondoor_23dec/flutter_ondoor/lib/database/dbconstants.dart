class DBConstants {
  //Database constant
  static final String DATABASE_NAME = "ondoor.db";
  static final int VERSION =
      8; // changed by GAJANAND previous 5   // changed by HIMANSHu previous 6
  static final String ANDROID = "android";

  static final String REPLACE_SYMBOL =
      "ondoor_apostrophe"; // "'"  to "(ondoor_apostrophe)"

  //////////////////////// TABLE NAME ///////////////////////

  static final String RECENT_SEARCH = "RECENT_SEARCH";
  static final String ADDRESS_LIST_TABLE = "ADDRESS_LIST_TABLE";

  //////////////////////// TABLE NAME ///////////////////////

  static final String PRODUCT_LIST_TABLE = "PRODUCT_LIST";
  static final String PRODUCT_OPTION_TABLE = "PRODUCT_OPTION_TABLE";
  static final String SHOPPING_LIST = "SHOPPING_LIST";

  //////////////////////// COMMON FOR BOTH TABLE //////////////////////////

  static final String ID = "ID"; //INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
  static final String PRODUCT_ID = "PRODUCT_ID"; //INTEGER

  /////////////////////// PRODUCT LIST DATA //////////////////////////////

  static final String PRODUCT_NAME = "PRODUCT_NAME"; //  TEXT
  static final String IMAGE = "IMAGE"; //  TEXT
  static final String DISTEXT = "DISTEXT"; //  TEXT
  static final String DISLABEL = "DISLABEL"; //  TEXT
  static final String DETAIL_IMAGE = "DETAIL_IMAGE"; //  TEXT

  //code added by himanshu for image array
  static const String IMAGE_ARRAY = "IMAGE_ARRAY"; //  TEXT

  static final String PRODUCT_WEIGHT = "PRODUCT_WEIGHT"; //  TEXT
  static final String PRODUCT_WEIGHT_UNIT = "PRODUCT_WEIGHT_UNIT"; //  TEXT
  static final String ORDER_QTY_LIMIT = "ORDER_QTY_LIMIT"; //  TEXT
  static final String CNF_SHIPPING_SURCHARGE =
      "CNF_SHIPPING_SURCHARGE"; //  TEXT
  static final String SHIPPING_MAX_AMOUNT = "SHIPPING_MAX_AMOUNT"; //  TEXT
  static final String PRICE = "PRICE"; //  REAL
  static final String SPECIAL_PRICE = "SPECIAL_PRICE"; //  REAL
  static final String SORT_PRICE = "SORT_PRICE"; //  REAL
  static final String OPTION_PRICE_ALL = "OPTION_PRICE_ALL"; //  REAL
  static final String DESCRIPTION = "DESCRIPTION"; //  TEXT
  static final String MODEL = "MODEL"; //  TEXT
  static final String QUANTITY = "QUANTITY"; //  INTEGER
  static final String TOTALQUANTITY = "TOTALQUANTITY"; //  INTEGER
  static final String SUBTRACT = "SUBTRACT"; //  TEXT
  static final String MSG_ON_CAKE = "MSG_ON_CAKE"; //  TEXT
  static final String MSG_ON_CARD = "MSG_ON_CARD"; //  TEXT
  static final String VENDOR_PRODUCT = "VENDOR_PRODUCT"; //  TEXT
  static final String SELLER_ID = "SELLER_ID"; //  TEXT
  static final String GIFT_ITEM = "GIFT_ITEM"; //  TEXT
  static final String SHIPPING_OPTION_ID = "SHIPPING_OPTION_ID"; //  TEXT
  static final String DELIVERY_DATE = "DELIVERY_DATE"; //  TEXT
  static final String DELIVERY_TIME_SLOT = "DELIVERY_TIME_SLOT"; //  TEXT
  static final String TIME_SLOT_JSON = "TIME_SLOT_JSON"; //  TEXT
  static final String SHIPPING_CHARGE = "SHIPPING_CHARGE"; //  TEXT
  static final String IS_OPTION = "IS_OPTION"; //  TEXT
  static final String SELLER_NICKNAME = "SELLER_NICKNAME"; //  TEXT
  static final String SHOW_CARD_MSG = "SHOW_CARD_MSG"; //  TEXT
  static final String SHOW_CAKE_MGS = "SHOW_CAKE_MGS"; //  TEXT
  static final String SHIPPING_JSON = "SHIPPING_JSON"; //  TEXT
  static final String OPTION_JSON_ALL = "OPTION_JSON_ALL"; //  TEXT
  static final String SHIPPING_OPTION_SELECTED =
      "SHIPPING_OPTION_SELECTED"; //  TEXT
  static final String TIME_SLOT_SELECT = "TIME_SLOT_SELECT"; //  TEXT
  static final String SELLER_DATA = "SELLER_DATA"; //  TEXT
  static final String OPTION_UNI = "OPTION_UNI"; //  TEXT

  // ---- add in build 1.3.5 ------DB VERSION 2 ///
  static final String REWARD_POINTS = "REWARD_POINTS"; //  TEXT
  static final String ACTUAL_SHIPPING_CHARGE =
      "ACTUAL_SHIPPING_CHARGE"; //  real
  static final String OFFER_DESC = "OFFER_DESC"; //  Text
  static final String OFFER_LABEL = "OFFER_LABEL"; //  Text

  //////////////////////// PRODUCT OPTION DATA BY PRODUCT LIST ID ///////////////////////

  static final String PRODUCT_LIST_ID = "PRODUCT_LIST_ID"; //  INTEGER
  static final String PRODUCT_OPTION_ID = "PRODUCT_OPTION_ID"; //  TEXT
  static final String SUB_PRODUCT = "SUB_PRODUCT"; //  TEXT
  static final String PRODUCT_OPTION_VALUE_ID =
      "PRODUCT_OPTION_VALUE_ID"; //  TEXT
  static final String OPTION_ID = "OPTION_ID"; //  TEXT
  static final String OPTION_VALUE_ID = "OPTION_VALUE_ID"; //  TEXT
  static final String NAME = "NAME"; //  TEXT
  static final String PRODUCT_OPTION_NAME = "PRODUCT_OPTION_NAME"; //  TEXT
  static final String PRODUCT_TYPE = "PRODUCT_TYPE"; //  TEXT
  static final String PRICE_PREFIX = "PRICE_PREFIX"; //  TEXT
  static final String OPTION_PRICE = "OPTION_PRICE"; //  TEXT
  static final String OPTION_PRICE_WITH_PREFIX =
      "OPTION_PRICE_WITH_PREFIX"; //  real
  static final String OPTION_JSON = "OPTION_JSON"; //  TEXT

  //////////////////////// SHOPPING LIST ///////////////////////
  static final String SHOPPING_LIST_ID = "SHOPPING_LIST_ID";
  static final String PLACEID = "PLACEID";
  static final String LAT = "LAT";
  static final String LNG = "LNG";
  static final String ADDRESS = "ADDRESS";
  static final String POSTALCODE = "POSTALCODE";
  static final String LANDMARK = "LANDMARK";
  static final String ADDRESS_TYPE = "ADDRESS_TYPE";
  static final String CITY = "CITY";
  static final String STATE = "STATE";
  static final String INSERTED_DATE = "INSERTED_DATE";
  static final String SUBADDRESS = "SUBADDRESS";
  static final String STATUS = "STATUS";

  static final String OFFER_ID = "C_OFFER_ID";
  static final String OFFER_TYPE = "C_OFFER_TYPE";

  static final String OFFER_PRODUCT = "OFFER_PRODUCT";
  static final String OFFER_COUNT = "C_OFFER_COUNT";
  static final String OFFER_MAX = "C_OFFER_MAX";
  static final String OFFER_APPLIED = "C_OFFER_APPLIED";
  static final String OFFER_WARNING = "C_OFFER_WARNING";
  static final String BUY_QTY = "BUY_QTY";
  static final String GET_QTY = "GET_QTY";
}
