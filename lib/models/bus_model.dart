import 'package:google_mao/models/coordinates_model.dart';

class Bus {
  final String busNumber;
  final Coordinates coordinates;
  final String busId;

  Bus({
    required this.busNumber,
    required this.coordinates,
    required this.busId,
  });

  @override
  String toString() {
    final String coordinateString = coordinates.toString();
    return 'MyClass{busNumber: $busNumber, Coordinates: $coordinateString,busId:$busId}';
  }
}
