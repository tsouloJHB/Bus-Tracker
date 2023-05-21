import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mao/models/coordinates_model.dart';
import 'package:google_mao/services/bus_tracking_api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/bus_model.dart';
import '../views/states/bus_tracking_state.dart';

class BusTracker {
  final BusTrackingService busTrackingService = BusTrackingService();

  BuildContext? _context;
  // BusTracker(this.context);
  //get The build context object
  void setBuildContext(BuildContext localContext) {
    _context = localContext;
  }

  Bus getBusPosition() {
    Bus bus = Bus(
      busNumber: 'C5',
      coordinates: Coordinates(latitude: -26.183186, longitude: 28.004540),
      busId: '435445',
    );

    return bus;
  }

  //cast the coordinates into LatLng
  LatLng coordinatesToLatlng(Coordinates coordinates) {
    return LatLng(coordinates.latitude, coordinates.longitude);
  }

  //get the bus's position
  int upTimer = 0;
  List<Bus> getBusPositions(BuildContext context) {
    //List<dynamic> busCoordinatesList = busTrackingService.fetchBusCoordinates();
    List<dynamic> busCoordinatesList =
        busTrackingService.fetchBusCoordinatesMock(upTimer);
    final busList = busCoordinatesList.map((busCoordinates) {
      final bus = Bus(
          busNumber: busCoordinates['bus_numbers'],
          coordinates: Coordinates(
              latitude: busCoordinates['coordinates']['latitude'],
              longitude: busCoordinates['coordinates']['longitude']),
          busId: busCoordinates['bus_id']);

      // String timeEstimate = busTrackingService.getEstimatedArrivalTime(
      //     LatLng(busCoordinates['coordinates']['latitude'],
      //         busCoordinates['coordinates']['longitude']),
      //     LatLng(-26.1742, 27.95722)) as String;

      final busTrackingState =
          Provider.of<BusTrackingState>(context, listen: false);
      busTrackingState.updateBusArrivalText("C5 Arriving in $upTimer");

      upTimer++;
      return bus;
    }).toList();

    return busList;
  }

  List<Bus> getBusPositionsByBusNumber(List<int>) {
      
  }
  List<Bus> getBusInfo() {
    return getBusPositions(_context!);
  }

  //get position in specific intervals
  void busPositionTimer() {
    // Start calling the function every 10 seconds
    Timer.periodic(Duration(seconds: 10), (timer) {
      List<Bus> busList = getBusPositions(_context!);
      print(busList);
    });
  }

  LatLng castStringToLatLng(stringLatLng) {
    // Extract the latitude and longitude values from the string
    RegExp regex = RegExp(r"(-?\d+.\d+)");
    Iterable<Match> matches = regex.allMatches(stringLatLng);

    if (matches.length >= 2) {
      double latitude = double.parse(matches.elementAt(0).group(0)!);
      double longitude = double.parse(matches.elementAt(1).group(0)!);

      LatLng latLng = LatLng(latitude, longitude);
      // Now you have the LatLng object
      print(latLng); // Output: LatLng(-26.17389, 27.95929)
      return latLng;
    }
    return const LatLng(0, 0);
  }
}
