class GeoData {
  String address = '';
  String city = "";
  String country = "";
  String subLocality = "";
  String postalCode = "";
  String state = "";
  String streetNumber = "";
  String countryCode = "";
  String placeId = "";
  String latitude = "";
  String longitude = "";
  GeoData(
      {required this.address,
      required this.city,
      required this.state,
      required this.subLocality,
      required this.streetNumber,
      required this.country,
      required this.placeId,
      required this.postalCode,
      required this.longitude,
      required this.latitude,
      required this.countryCode});
  Map<String, dynamic> toJson() => {
        "address": address,
        "city": city,
        "state": state,
        "streetNumber": streetNumber,
        "subLocality": subLocality,
        "country": country,
        "placeId": placeId,
        "postalCode": postalCode,
        "longitude": longitude,
        "latitude": latitude,
        "countryCode": countryCode,
      };
}
