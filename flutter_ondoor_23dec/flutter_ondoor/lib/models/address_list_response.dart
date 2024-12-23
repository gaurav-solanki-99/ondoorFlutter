class AddressListResponse {
  bool? success;
  String? dateText;
  String? selectDateText;
  List<AddressData>? data;
  String? timeSlotText;
  GstInfo? gstInfo;
  String? popupText;
  String? message;
  int? isCocoaddressExist;
  int? statusCode;
  String? statusText;
  String? txtAddAddress;
  String? txtSetAnotherDeliveryLocation;
  String? txtSelectAnAddress;
  String? changeAddress;
  String? deliveryTo;

  AddressListResponse(
      {this.success,
      this.dateText,
      this.selectDateText,
      this.data,
      this.timeSlotText,
      this.gstInfo,
      this.popupText,
      this.message,
      this.statusText,
      this.statusCode,
      this.isCocoaddressExist,
      this.txtAddAddress,
      this.txtSetAnotherDeliveryLocation,
      this.txtSelectAnAddress,
      this.changeAddress,
      this.deliveryTo});

  AddressListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? "";
    dateText = json['date_text'] ?? "";
    statusText = json['statusText'] ?? "";
    statusCode = json["statusCode"] ?? 0;
    selectDateText = json['select_date_text'] ?? "";
    if (json['data'] != null) {
      data = <AddressData>[];
      json['data'].forEach((v) {
        data!.add(AddressData.fromJson(v));
      });
    }
    timeSlotText = json['time_slot_text'];
    gstInfo = json['gst_info'] != null
        ? new GstInfo.fromJson(json['gst_info'])
        : GstInfo();
    popupText = json['popup_text'] ?? "";
    message = json['message'] ?? "";
    isCocoaddressExist = json['is_cocoaddress_exist'] ?? "";
    txtAddAddress = json['txt_add_address'] ?? "";
    txtSetAnotherDeliveryLocation =
        json['txt_set_another_delivery_location'] ?? "";
    txtSelectAnAddress = json['txt_select_an_address'] ?? "";
    changeAddress = json['change_address'] ?? "";
    deliveryTo = json['delivery_to'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['date_text'] = this.dateText;
    data['select_date_text'] = this.selectDateText;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['time_slot_text'] = this.timeSlotText;
    if (this.gstInfo != null) {
      data['gst_info'] = this.gstInfo!.toJson();
    }
    data['popup_text'] = this.popupText;
    data['message'] = this.message;
    data['is_cocoaddress_exist'] = this.isCocoaddressExist;
    data['txt_add_address'] = this.txtAddAddress;
    data['txt_set_another_delivery_location'] =
        this.txtSetAnotherDeliveryLocation;
    data['txt_select_an_address'] = this.txtSelectAnAddress;
    data['change_address'] = this.changeAddress;
    data['delivery_to'] = this.deliveryTo;
    return data;
  }
}

/*
class AddressData {
  String? addressId;
  String? firstname;
  String? lastname;
  String? company;
  String? address1;
  String? address2;
  String? telephone;
  String? postcode;
  String? city;
  String? zoneId;
  String? zone;
  String? zoneCode;
  String? countryId;
  String? country;
  String? isoCode2;
  String? isoCode3;
  String? addressFormat;
  String? creditprogramVerified;
  String? verifyMsg;
  String? customField;
  String? locationId;
  String? storeCode;
  String? areaDetail;
  String? latitude;
  String? longitude;
  String? flatSectorApartment;
  String? landmark;
  String? storeId;
  String? storeName;
  String? wmsStoreId;
  String? onlineStatus;
  String? addressType;
  String? title;
  String? subtitle;
  String? deliveryAddress;

  AddressData(
      {this.addressId,
      this.firstname,
      this.lastname,
      this.company,
      this.address1,
      this.address2,
      this.telephone,
      this.postcode,
      this.city,
      this.zoneId,
      this.zone,
      this.zoneCode,
      this.countryId,
      this.country,
      this.isoCode2,
      this.isoCode3,
      this.addressFormat,
      this.creditprogramVerified,
      this.verifyMsg,
      this.customField,
      this.locationId,
      this.storeCode,
      this.areaDetail,
      this.latitude,
      this.longitude,
      this.flatSectorApartment,
      this.landmark,
      this.storeId,
      this.storeName,
      this.wmsStoreId,
      this.onlineStatus,
      this.addressType,
      this.title,
      this.subtitle,
      this.deliveryAddress});
  factory AddressData.fromMap(Map<String, dynamic> json) => AddressData(
        addressId: json['address_id'] ?? "",
        firstname: json['firstname'] ?? "",
        lastname: json['lastname'] ?? "",
        company: json['company'] ?? "",
        address1: json['address_1'] ?? "",
        address2: json['address_2'] ?? "",
        telephone: json['telephone'] ?? "",
        postcode: json['postcode'] ?? "",
        city: json['city'] ?? "",
        zoneId: json['zone_id'] ?? "",
        zone: json['zone'] ?? "",
        zoneCode: json['zone_code'] ?? "",
        countryId: json['country_id'] ?? "",
        country: json['country'] ?? "",
        isoCode2: json['iso_code_2'] ?? "",
        isoCode3: json['iso_code_3'] ?? "",
        addressFormat: json['address_format'] ?? "",
        creditprogramVerified: json['creditprogram_verified'],
        verifyMsg: json['verify_msg'] ?? "",
        customField: json['custom_field'] ?? "",
        addressType: json['address_type'] ?? "",
        locationId: json['location_id'] ?? "",
        storeCode: json['store_code'] ?? "",
        title: json['title'] ?? "",
        areaDetail: json['area_detail'] ?? "",
        deliveryAddress: json['delivery_address'] ?? "",
        flatSectorApartment: json['flat_sector_apartment'] ?? "",
      );
  AddressData.fromJson(Map<String, dynamic> json) {
    addressId = json['address_id'] ?? "";
    firstname = json['firstname'] ?? "";
    lastname = json['lastname'] ?? "";
    company = json['company'] ?? "";
    address1 = json['address_1'] ?? "";
    address2 = json['address_2'] ?? "";
    telephone = json['telephone'] ?? "";
    postcode = json['postcode'] ?? "";
    city = json['city'] ?? "";
    zoneId = json['zone_id'] ?? "";
    zone = json['zone'] ?? "";
    zoneCode = json['zone_code'] ?? "";
    countryId = json['country_id'] ?? "";
    country = json['country'] ?? "";
    isoCode2 = json['iso_code_2'] ?? "";
    isoCode3 = json['iso_code_3'] ?? "";
    addressFormat = json['address_format'] ?? "";
    creditprogramVerified = json['creditprogram_verified'] ?? "";
    verifyMsg = json['verify_msg'] ?? "";
    customField = json['custom_field'] ?? "";
    addressType = json['address_type'] ?? "";
    locationId = json['location_id'] ?? "";
    storeCode = json['store_code'] ?? "";
    flatSectorApartment = json['flat_sector_apartment'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_id'] = addressId;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['company'] = company;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['telephone'] = telephone;
    data['postcode'] = postcode;
    data['city'] = city;
    data['zone_id'] = zoneId;
    data['zone'] = zone;
    data['zone_code'] = zoneCode;
    data['country_id'] = countryId;
    data['country'] = country;
    data['iso_code_2'] = isoCode2;
    data['iso_code_3'] = isoCode3;
    data['address_format'] = addressFormat;
    data['creditprogram_verified'] = creditprogramVerified;
    data['verify_msg'] = verifyMsg;
    data['custom_field'] = customField;
    data['location_id'] = locationId;
    data['store_code'] = storeCode;
    return data;
  }
}*/
class AddressData {
  String? addressId;
  String? firstname;
  String? lastname;
  String? company;
  String? address1;
  String? address2;
  String? telephone;
  String? postcode;
  String? city;
  String? zoneId;
  String? zone;
  String? zoneCode;
  String? countryId;
  String? country;
  String? isoCode2;
  String? isoCode3;
  String? addressFormat;
  String? creditprogramVerified;
  String? verifyMsg;
  dynamic? customField;
  String? locationId;
  String? storeCode;
  String? areaDetail;
  String? latitude;
  String? longitude;
  String? flatSectorApartment;
  String? landmark;
  String? storeId;
  String? storeName;
  String? wmsStoreId;
  String? onlineStatus;
  String? addressType;
  String? title;
  String? subtitle;
  String? deliveryAddress;

  AddressData({
    this.addressId,
    this.firstname,
    this.lastname,
    this.company,
    this.address1,
    this.address2,
    this.telephone,
    this.postcode,
    this.city,
    this.zoneId,
    this.zone,
    this.zoneCode,
    this.countryId,
    this.country,
    this.isoCode2,
    this.isoCode3,
    this.addressFormat,
    this.creditprogramVerified,
    this.verifyMsg,
    this.customField,
    this.locationId,
    this.storeCode,
    this.areaDetail,
    this.latitude,
    this.longitude,
    this.flatSectorApartment,
    this.landmark,
    this.storeId,
    this.storeName,
    this.wmsStoreId,
    this.onlineStatus,
    this.addressType,
    this.title,
    this.subtitle,
    this.deliveryAddress,
  });

  factory AddressData.fromMap(Map<String, dynamic> json) => AddressData(
        addressId: json['address_id'] ?? "",
        firstname: json['firstname'] ?? "",
        lastname: json['lastname'] ?? "",
        company: json['company'] ?? "",
        address1: json['address_1'] ?? "",
        address2: json['address_2'] ?? "",
        telephone: json['telephone'] ?? "",
        postcode: json['postcode'] ?? "",
        city: json['city'] ?? "",
        zoneId: json['zone_id'] ?? "",
        zone: json['zone'] ?? "",
        zoneCode: json['zone_code'] ?? "",
        countryId: json['country_id'] ?? "",
        country: json['country'] ?? "",
        isoCode2: json['iso_code_2'] ?? "",
        isoCode3: json['iso_code_3'] ?? "",
        addressFormat: json['address_format'] ?? "",
        creditprogramVerified: json['creditprogram_verified'] ?? "",
        verifyMsg: json['verify_msg'] ?? "",
        customField: json['custom_field'] ?? "",
        locationId: json['location_id'] ?? "",
        storeCode: json['store_code'] ?? "",
        areaDetail: json['area_detail'] ?? "",
        latitude: json['latitude'] ?? "",
        longitude: json['longitude'] ?? "",
        flatSectorApartment: json['flat_sector_apartment'] ?? "",
        landmark: json['landmark'] ?? "",
        storeId: json['store_id'] ?? "",
        storeName: json['store_name'] ?? "",
        wmsStoreId: json['wms_store_id'] ?? "",
        onlineStatus: json['online_status'] ?? "",
        addressType: json['address_type'] ?? "",
        title: json['title'] ?? "",
        subtitle: json['subtitle'] ?? "",
        deliveryAddress: json['delivery_address'] ?? "",
      );

  AddressData.fromJson(Map<String, dynamic> json) {
    addressId = json['address_id'] ?? "";
    firstname = json['firstname'] ?? "";
    lastname = json['lastname'] ?? "";
    company = json['company'] ?? "";
    address1 = json['address_1'] ?? "";
    address2 = json['address_2'] ?? "";
    telephone = json['telephone'] ?? "";
    postcode = json['postcode'] ?? "";
    city = json['city'] ?? "";
    zoneId = json['zone_id'] ?? "";
    zone = json['zone'] ?? "";
    zoneCode = json['zone_code'] ?? "";
    countryId = json['country_id'] ?? "";
    country = json['country'] ?? "";
    isoCode2 = json['iso_code_2'] ?? "";
    isoCode3 = json['iso_code_3'] ?? "";
    addressFormat = json['address_format'] ?? "";
    creditprogramVerified = json['creditprogram_verified'] ?? "";
    verifyMsg = json['verify_msg'] ?? "";
    customField = json['custom_field'] is String
        ? json['custom_field'] ?? ""
        : json['custom_field'] ?? false;
    locationId = json['location_id'] ?? "";
    storeCode = json['store_code'] ?? "";
    areaDetail = json['area_detail'] ?? "";
    latitude = json['latitude'] ?? "0.0";
    longitude = json['longitude'] ?? "0.0";
    flatSectorApartment = json['flat_sector_apartment'] ?? "";
    landmark = json['landmark'] ?? "";
    storeId = json['store_id'] ?? "";
    storeName = json['store_name'] ?? "";
    wmsStoreId = json['wms_store_id'] ?? "";
    onlineStatus = json['online_status'] ?? "";
    addressType = json['address_type'] ?? "";
    title = json['title'] ?? "";
    subtitle = json['subtitle'] ?? "";
    deliveryAddress = json['delivery_address'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address_id'] = addressId;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['company'] = company;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['telephone'] = telephone;
    data['postcode'] = postcode;
    data['city'] = city;
    data['zone_id'] = zoneId;
    data['zone'] = zone;
    data['zone_code'] = zoneCode;
    data['country_id'] = countryId;
    data['country'] = country;
    data['iso_code_2'] = isoCode2;
    data['iso_code_3'] = isoCode3;
    data['address_format'] = addressFormat;
    data['creditprogram_verified'] = creditprogramVerified;
    data['verify_msg'] = verifyMsg;
    data['custom_field'] = customField;
    data['location_id'] = locationId;
    data['store_code'] = storeCode;
    data['area_detail'] = areaDetail;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['flat_sector_apartment'] = flatSectorApartment;
    data['landmark'] = landmark;
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['wms_store_id'] = wmsStoreId;
    data['online_status'] = onlineStatus;
    data['address_type'] = addressType;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['delivery_address'] = deliveryAddress;
    return data;
  }
}

class GstInfo {
  String? gstNo;
  String? gstFirmName;
  String? addText;
  String? checkText;

  GstInfo({this.gstNo, this.gstFirmName, this.addText, this.checkText});

  GstInfo.fromJson(Map<String, dynamic> json) {
    gstNo = json['gst_no'] ?? "";
    gstFirmName = json['gst_firm_name'] ?? "";
    addText = json['add_text'] ?? "";
    checkText = json['check_text'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gst_no'] = this.gstNo;
    data['gst_firm_name'] = this.gstFirmName;
    data['add_text'] = this.addText;
    data['check_text'] = this.checkText;
    return data;
  }
}
