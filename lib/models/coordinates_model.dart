class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return 'MyClass{latitude: $latitude, longitude:$longitude}';
  }
}
