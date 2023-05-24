import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mao/models/bus_arrival_model.dart';
import 'package:google_mao/models/coordinates_model.dart';
import 'package:google_mao/services/bus_tracking_api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/bus_model.dart';
import '../views/states/bus_tracking_state.dart';

class BusTracker {
  final BusTrackingService busTrackingService = BusTrackingService();
  BuildContext? _context;

  //timers and timer variables
  Timer? _timer;
  Timer? estimatedArrivalTimer;
  bool _timers = false;
  bool busEstimatedTimes = false;

  //flags
  bool _isGetBusPositionsCalled = false;
  bool _isEstimatedBusArrivalCalled = false;
  late List<dynamic> estimatedArrivalBuses;
  late LatLng estimatedArrivalDestination;

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

      //get estimated arrival times
      // if (busEstimatedTimes) {
      //   final busTrackingState =
      //       Provider.of<BusTrackingState>(context, listen: false);
      //   busTrackingState.updateBusArrivalText("C5 Arriving in $upTimer");
      // }

      upTimer++;
      return bus;
    }).toList();
    print(busList);

    return busList;
  }

  List<Bus> getBusPositionsByBusNumbers(List<String> busNumbers) {
    List<Bus> busList =
        busTrackingService.fetchBusCoordinatesByBusNumberMock(busNumbers);
    return busList;
  }

  //get estimated bus arrivals
  Future<List<BusArrival>> getEstimatedArrivalTimes(
      List<dynamic> buses, LatLng destination) async {
    List<String> stringList = buses.map((bus) => bus.toString()).toList();

    List<Bus> busObjects = getBusPositionsByBusNumbers(stringList);
    List<Future<BusArrival>> estimates = busObjects.map((bus) async {
      String timeEstimate = await busTrackingService.getEstimatedArrivalTime(
          destination,
          LatLng(bus.coordinates.latitude, bus.coordinates.longitude));

      return BusArrival(busNumber: bus.busNumber, time: timeEstimate);
    }).toList();

    List<BusArrival> busArrivalObject = await Future.wait(estimates);
    //update Bus estimate state
    print(busArrivalObject);
    final busTrackingState =
        Provider.of<BusTrackingState>(_context!, listen: false);
    busTrackingState.setBusArrival(busArrivalObject);
    return busArrivalObject;
  }

  List<Bus> getBusInfo() {
    return getBusPositions(_context!);
  }

  //get position in specific intervals
  void busPositionTimer() {
    // Start calling the function every 10 seconds

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      List<Bus> busList = getBusPositions(_context!);

      print(busList);
    });
  }

  //timer for the bus estimated arrival
  void timerEstimatedArrival(List<String> stringList, destination) {}

  void stopTimer() {
    _timer?.cancel();

    print("Timer stoppeddd.");
  }

  void stopEstimatedTimer() {
    estimatedArrivalTimer?.cancel();
    estimatedArrivalTimer = null;
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

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      print("start timer running");
      if (_isGetBusPositionsCalled) {
        getBusPositions(_context!);
      }
      if (_isEstimatedBusArrivalCalled) {
        getEstimatedArrivalTimes(
            estimatedArrivalBuses, estimatedArrivalDestination);
      }

      // Check if both functions don't want to be called
      if (!_isGetBusPositionsCalled && !_isEstimatedBusArrivalCalled) {
        print("I'm not suppose to run");
        stopTimer();
      }

      // Reset the function call flags after each timer iteration
      // _isGetBusPositionsCalled = false;
      // _isEstimatedBusArrivalCalled = false;
    });
  }

  void stopTimer2() {
    _timer?.cancel();
  }

  // Call this function when getBusPositions should be called within the timer
  void callGetBusPositions() {
    _isGetBusPositionsCalled = true;
    startTimer();
  }

  // Call this function when estimatedBusArrival should be called within the timer
  void callEstimatedBusArrival(List<dynamic> buses, LatLng destination) {
    _isEstimatedBusArrivalCalled = true;
    estimatedArrivalBuses = buses;
    estimatedArrivalDestination = destination;
    startTimer();
  }

  void resetIsEstimatedBusArrival() {
    _isEstimatedBusArrivalCalled = false;
    if (!_isEstimatedBusArrivalCalled && !_isGetBusPositionsCalled) {
      stopTimer();
    }
  }

  void resetGetBusPostions() {
    _isGetBusPositionsCalled = false;
  }
}
