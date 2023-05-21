import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DataAccess {
  // Future<List<dynamic>> loadJsonData() async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   String path = directory.path + '/busStops.json';
  //   String jsonString = await File(path).readAsString();
  //   return json.decode(jsonString);
  // }

  Future<List<dynamic>> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/busStops.json');
    var jsonData = json.decode(jsonString);
    return jsonData['bus_stops'];
  }

  // Future<List<dynamic>> filterByCoordinates(
  //     double latitude, double longitude) async {
  //   List<dynamic> busStops = await loadJsonData();
  //   List<dynamic> filteredBusStops = busStops.where((busStop) {
  //     double stopLatitude = busStop['coordinates']['latitude'];
  //     double stopLongitude = busStop['coordinates']['longitude'];
  //     return (stopLatitude == latitude && stopLongitude == longitude);
  //   }).toList();
  //   return filteredBusStops;
  // }

  Future<List<dynamic>> filterByCoordinates(
      double latitude, double longitude) async {
    List<dynamic> busStops = await loadJsonData();
    List<dynamic> filteredBusStops = busStops.where((busStop) {
      double stopLatitude = busStop['coordinates']['latitude'];
      double stopLongitude = busStop['coordinates']['longitude'];

      // Define the tolerance level for coordinate comparison
      double tolerance = 0.0001;

      // Compare coordinates with tolerance
      bool coordinatesMatch = (stopLatitude - latitude).abs() < tolerance &&
          (stopLongitude - longitude).abs() < tolerance;

      return coordinatesMatch;
    }).toList();

    return filteredBusStops.map((busStop) {
      Map<String, dynamic> filteredBusStop = {
        'coordinates': busStop['coordinates'],
        'street_direction': busStop['street_direction'],
        'address': busStop['address'],
        'bus_numbers': busStop['bus_numbers'],
      };

      return filteredBusStop;
    }).toList();
  }

  // Future<List<dynamic>> filterByCoordinates(
  //     double latitude, double longitude) async {
  //   List<dynamic> busStops = await loadJsonData();
  //   List<dynamic> filteredBusStops = busStops.where((busStop) {
  //     double stopLatitude = busStop['coordinates']['latitude'];
  //     double stopLongitude = busStop['coordinates']['longitude'];
  //     return (stopLatitude == latitude && stopLongitude == longitude);
  //   }).toList();
  //   return filteredBusStops.map((busStop) {
  //     Map<String, dynamic> filteredBusStop = {
  //       'coordinates': busStop['coordinates'],
  //       'street_direction': busStop['street_direction'],
  //       'address': busStop['address'],
  //       'bus_numbers': busStop['bus_numbers'],
  //     };

  //     return filteredBusStop;
  //   }).toList();
  // }

  // Future<List<dynamic>> filterByCoordinates(
  //     double latitude, double longitude) async {
  //   List<dynamic> busStops = await loadJsonData();
  //   List<dynamic> filteredBusStops = busStops.where((busStop) {
  //     double stopLatitude = busStop['coordinates']['latitude'];
  //     double stopLongitude = busStop['coordinates']['longitude'];
  //     return (stopLatitude == latitude && stopLongitude == longitude);
  //   }).toList();
  //   return filteredBusStops;
  // }
}
