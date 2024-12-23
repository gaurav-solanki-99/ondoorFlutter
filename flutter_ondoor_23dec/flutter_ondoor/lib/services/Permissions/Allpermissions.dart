// /*
// import 'package:geocoding/geocoding.dart';
// import 'package:location/location.dart' as loc;
//
// class Allpermissions {
//
//   static Future<loc.LocationData?> getCurrentLocation() async {
//     loc.Location location = loc.Location();
//
//     bool _serviceEnabled;
//     loc.PermissionStatus _permissionGranted;
//     loc.LocationData _locationData;
//
//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return null;
//       }
//     }
//
//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == loc.PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != loc.PermissionStatus.granted) {
//         return null;
//       }
//     }
//     _locationData = await location.getLocation();
//     print("Current   >> Latitude " + _locationData.latitude.toString());
//     print("Current   >> Longitude " + _locationData.longitude.toString());
//
//     return _locationData;
//     //
//
//
//   }
//
//
//   static Future<List<Placemark>> getPlacemarks(double lat, double long) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
//
//       var address = '';
//
//       if (placemarks.isNotEmpty) {
//
//         // Concatenate non-null components of the address
//         var streets = placemarks.reversed.map((placemark) => placemark.street).where((street) => street != null);
//
//         // Filter out unwanted parts
//         streets = streets.where((street) =>
//         street!.toLowerCase() !=
//             placemarks.reversed.last.locality!
//                 .toLowerCase()); // Remove city names
//         streets =
//             streets.where((street) => !street!.contains('+')); // Remove street codes
//
//         address += streets.join(', ');
//
//         address += ', ${placemarks.reversed.last.subLocality ?? ''}';
//         address += ', ${placemarks.reversed.last.locality ?? ''}';
//         address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
//         address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
//         address += ', ${placemarks.reversed.last.postalCode ?? ''}';
//         address += ', ${placemarks.reversed.last.country ?? ''}';
//       }
//
//       print("Your Address for ($lat, $long) is: $address");
//       print("Your Address for ($lat, $long) is: $placemarks");
//
//       return placemarks;
//     } catch (e) {
//       print("Error getting placemarks: $e");
//       return [];
//     }
//   }
//
// }
// */
