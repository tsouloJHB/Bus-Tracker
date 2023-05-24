import 'package:flutter/foundation.dart';
import 'package:google_mao/controllers/bus_tracker_controllers.dart';
import 'package:google_mao/models/bus_arrival_model.dart';

class BusTrackingState with ChangeNotifier {
  BusTracker busTracker = BusTracker();
  String _busArrivalText = 'C5 15 min away ';
  String get busArrivalText => _busArrivalText;

  late List<BusArrival> busArrivals;
  List<BusArrival> get getBusArrivals => busArrivals;

  void updateBusArrivalText(String newText) {
    _busArrivalText = newText;
    notifyListeners(); // Notify listeners that the state has changed
  }

  String getBusArrivalText() {
    //get the bus click
    busTracker.getBusInfo();
    notifyListeners();
    return "";
  }

  void setBusArrival(List<BusArrival> busArrivalLocal) {
    busArrivals = busArrivalLocal;
    notifyListeners();
  }
}
