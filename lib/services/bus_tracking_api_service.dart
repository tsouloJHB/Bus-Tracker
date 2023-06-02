import 'dart:math';

import 'package:google_mao/models/bus_model.dart';
import 'package:google_mao/models/coordinates_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mao/constants.dart';

class BusTrackingService {
  // Future<List<dynamic>> fetchBusStops() async {
  //   final response = await http.get(Uri.parse('https://example.com/bus-stops'));
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to fetch bus stops');
  //   }
  // }

  List<LatLng> _busRoute = [
    LatLng(-26.183186, 28.004540),
    LatLng(-26.183113, 28.004327),
    LatLng(-26.183043, 28.004027),
    LatLng(-26.182973, 28.003748),
    LatLng(-26.182882, 28.003372),
    LatLng(-26.182817, 28.003026),
    LatLng(-26.182723, 28.002554),
    LatLng(-26.182586, 28.001958),
    LatLng(-26.182475, 28.001288),
    LatLng(-26.182357, 28.000564),
    LatLng(-26.182160, 27.999681),
    LatLng(-26.181926, 27.998984),
    LatLng(-26.181782, 27.998295),
    LatLng(-26.181652, 27.997603),
    LatLng(-26.181450, 27.996688),
    LatLng(-26.181240, 27.995671),
    LatLng(-26.181257, 27.995100),
    LatLng(-26.17144626501108, 27.953277271992954),
    LatLng(-26.171333585829856, 27.953086281289328),
    LatLng(-26.171179832969014, 27.952872289380265),
  ];

  List<dynamic> fetchBusCoordinates() {
    List<dynamic> predefinedList = [
      {
        'coordinates': {'latitude': -26.183186, 'longitude': 28.004540},
        'bus_id': '344545',
        'bus_numbers': 'C5',
      }
    ];

    return predefinedList;
  }

  List<dynamic> fetchBusCoordinatesMock(int position) {
    print("print mock");
    print(position);
    print(_busRoute.length);
    if (position > _busRoute.length) {
      position = _busRoute.length;
    }
    List<dynamic> predefinedList = [
      {
        'coordinates': {
          'latitude': _busRoute[position].latitude,
          'longitude': _busRoute[position].longitude
        },
        'bus_id': '344545',
        'bus_numbers': 'C5',
      }
    ];

    return predefinedList;
  }

   
   
  //get the bus information  by the bus numbers
  List<Bus> fetchBusCoordinatesByBusNumberMock(List<String> buses) {
    Random random = Random();
    final fetchedBuses = buses.map((bus) {
      int randomIndex = random.nextInt(_busRoute.length);
      final busObj = Bus(
          busNumber: bus,
          coordinates: Coordinates(
              latitude: _busRoute[randomIndex].latitude,
              longitude: _busRoute[randomIndex].longitude),
          busId: "45hkty6");
      return busObj;
    }).toList();
    return fetchedBuses;
  }

  List<dynamic> fetchBusCoordinatesByBusStop(LatLng coordinates, int position) {
    if (position > _busRoute.length) {
      position = _busRoute.length;
    }
    List<dynamic> predefinedList = [
      {
        'coordinates': {
          'latitude': _busRoute[position].latitude,
          'longitude': _busRoute[position].longitude
        },
        'bus_id': '344545',
        'bus_numbers': 'C5',
      },
      {
        'coordinates': {
          'latitude': _busRoute[position].latitude,
          'longitude': _busRoute[position].longitude
        },
        'bus_id': '434843749',
        'bus_numbers': 't3',
      }
    ];

    return predefinedList;
  }

  Future<String> getEstimatedArrivalTime(
      LatLng origin, LatLng destination) async {
    const apiKey = google_api_key; // Replace with your Google Maps API key

    final apiUrl =
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${origin.latitude},${origin.longitude}&destinations=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final durationText =
            jsonData['rows'][0]['elements'][0]['duration']['text'];
        print("Estimatio ----");
        print(durationText);
        return durationText;
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return 'Unknown'; // Return a default value or handle the error case
  }
}
