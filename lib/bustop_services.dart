import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class BusServices {
  final String apiKey;

  BusServices({required this.apiKey});

  Future<List<LatLng>> getBusStops(
      {required double latitude,
      required double longitude,
      required int radius,
      String type = 'transit_station',
      String keyword = "C5"}) async {
    print(latitude);
    print(longitude);

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$apiKey';
    // print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // print(response.body);
      //print(jsonData);
      final results = jsonData['results'] as List<dynamic>;

      results.forEach((place) {
        final String placeType = place['types'][0];
        final String placeName = place['name'];
        //print(place['plus_code']);
        //print('Type: $placeType, Name: $placeName');
      });

      for (final place in results) {
        final String placeId = place['place_id'];
        final placeDetails = await getPlaceDetails(placeId);
        //print(placeDetails);
        // Process and display place details
        final String placeName = placeDetails['name'];
        final String placeAddress = placeDetails['formatted_address'];
        // final String placeBuses = placeDetails['buses'];
        // Extract and use other desired details

        // print('Place Name: $placeName');
        // print('Place Address: $placeAddress');
        // print(place);
        // Print or process other details as needed
      }

      final busStops = results.map((result) {
        final location = result['geometry']['location'];
        final lat = location['lat'] as double;
        final lng = location['lng'] as double;

        return LatLng(lat, lng);
      }).toList();

      return busStops;
    } else {
      throw Exception('Failed to load bus stops');
    }
  }

  Future<dynamic> getPlaceDetails(String placeId) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final placeDetails = result['result'];
      return placeDetails;
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  //get direction for start position and destination in coordinates
  Future<dynamic> getTransitDirections(double originLat, double originLng,
      double destinationLat, double destinationLng) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&mode=transit&key=$apiKey'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print('Directions');
      print(result);
      final routes = result['routes'];
      if (routes.isNotEmpty) {
        final firstRoute = routes[0];
        final legs = firstRoute['legs'];
        if (legs.isNotEmpty) {
          final firstLeg = legs[0];
          final steps = firstLeg['steps'];
          print(steps);
          return steps;
        }
      }
      return null;
    } else {
      throw Exception('Failed to fetch transit directions');
    }
  }
}
