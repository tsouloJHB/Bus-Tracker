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
    LatLng(-26.183105, 28.004168),
    LatLng(-26.182949, 28.003584),
    LatLng(-26.182669, 28.002393),
    LatLng(-26.182082, 27.999389),
    LatLng(-26.181745, 27.997940),
    LatLng(-26.181524, 27.996942),
    LatLng(-26.181283, 27.994839),
    LatLng(-26.182255, 27.992812),
    LatLng(-26.183247, 27.990473),
    LatLng(-26.184345, 27.987962),
    LatLng(-26.186164, 27.983596),
    LatLng(-26.183690, 27.981310),
    LatLng(-26.181119, 27.978596),
    LatLng(-26.178452, 27.974240),
    LatLng(-26.176295, 27.969831),
    LatLng(-26.174745, 27.964541),
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
