import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_mao/models/coordinates_model.dart';
import 'package:google_mao/services/bus_tracking_api_service.dart';
import 'package:google_mao/views/states/bus_tracking_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_mao/bustop_services.dart';
import 'package:google_mao/data_access.dart';
import 'package:google_mao/controllers/bus_tracker_controllers.dart';
import 'package:provider/provider.dart';

import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart' as earth_math;

import '../models/bus_model.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;

  BusServices busServices = BusServices(apiKey: google_api_key);
  DataAccess dataAccess = DataAccess();

  BusTracker busTracker = BusTracker();

  BusTrackingService busTrackingService = BusTrackingService();
  List<Marker> _busStopMarkers = [];
  List<Marker> _busMarkers = [];
  List<dynamic> _busStopsCoordinates = [];

  final List<LatLng> _busRoute = [
    LatLng(-26.173839015619123, 27.957135056912423),
    LatLng(-26.173725338555313, 27.956976434785023),
    LatLng(-26.173443655235183, 27.95676244287596),
    LatLng(-26.173259770996177, 27.956527239978365),
    LatLng(-26.17310510993247, 27.956316503397465),
    LatLng(-26.1729073120177, 27.95598574129468),
    LatLng(-26.172798504103262, 27.955698946631252),
    LatLng(-26.17270770267249, 27.95544509285286),
    LatLng(-26.172591307328086, 27.95517077338087),
    LatLng(-26.17244782700815, 27.954942106365325),
    LatLng(-26.17237423636996, 27.9547787506471),
    LatLng(-26.172265428046356, 27.95455979722482),
    LatLng(-26.172157962147607, 27.954318791304512),
    LatLng(-26.171990471031044, 27.954065938897674),
    LatLng(-26.17186535974677, 27.953887925276312),
    LatLng(-26.17168944978936, 27.953646919356003),
    LatLng(-26.171564337810064, 27.95347840947158),
    LatLng(-26.17144626501108, 27.953277271992954),
    LatLng(-26.171333585829856, 27.953086281289328),
    LatLng(-26.171179832969014, 27.952872289380265),
  ];

  int _busPosition = 0;
  //create bus marker

  Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('marker1'),
      position: LatLng(-26.174096456043298, 27.955551747031624),
      infoWindow: InfoWindow(
        title: 'Marker 1',
      ),
    ),
    Marker(
      markerId: MarkerId('marker2'),
      position: LatLng(-26.173995177466437, 27.955729332096443),
      infoWindow: InfoWindow(
        title: 'Marker 2',
      ),
    ),
    Marker(
      markerId: MarkerId('marker3'),
      position: LatLng(-26.173855522183277, 27.95591958940063),
      infoWindow: InfoWindow(
        title: 'Marker 3',
      ),
    ),
  };

  Marker _marker = Marker(
    markerId: MarkerId('bus'),
    position: LatLng(-26.173839015619123, 27.957135056912423),
  );

  static const LatLng sourceLocation =
      LatLng(-26.174048312641773, 27.955648306547495);
  static const LatLng destination =
      LatLng(-26.174086827362956, 27.962815168668484);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

//get current location and bus stops

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
      getBusStop();
    });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      // googleMapController.animateCamera(CameraUpdate.newCameraPosition(
      //   CameraPosition(
      //       zoom: 15.5,
      //       target: LatLng(
      //         newLoc.latitude!,
      //         newLoc.longitude!,
      //       )),
      // ));

      setState(() {});
      // print("The current location");
      // print(currentLocation);
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    // print("ran");
    // print(result.points);
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_source.png")
        .then((icon) {
      sourceIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_destination.png")
        .then((icon) {
      destinationIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_current_location.png")
        .then((icon) {
      currentLocationIcon = icon;
    });
    //getBusStop();
  }

  void _startBusSimulation() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (_busPosition == _busRoute.length - 1) {
        timer.cancel();
        return;
      }
      setState(() {
        _busPosition++;
      });
    });
  }

  //calculate the distance between markers using the Haversine algorithm
  double _calculateDistance(LatLng start, LatLng end) {
    const int earthRadius = 6371;
    double lat1 = earth_math.radians(start.latitude);

    double lon1 = earth_math.radians(start.longitude);
    double lat2 = earth_math.radians(end.latitude);
    double lon2 = earth_math.radians(end.longitude);
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1) *
            Math.cos(lat2) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  //get the closest marker
  Marker _findNearestMarker(LatLng userLocation) {
    double shortestDistance = double.infinity;
    Marker nearestMarker = _markers.first;
    for (Marker marker in _markers) {
      double distance = _calculateDistance(marker.position, userLocation);
      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestMarker = marker;
      }
    }
    return nearestMarker;
  }

  @override
  void initState() {
    super.initState();
    final busTrackingState =
        Provider.of<BusTrackingState>(context, listen: false);
    print("ran1");
    busTracker.setBuildContext(context);
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();

    _startBusSimulation();
    // Marker foundMark = _findNearestMarker(
    //   LatLng(
    //     currentLocation?.latitude ?? 0.0,
    //     currentLocation?.longitude ?? 0.0,
    //   ),
    // );
    print("Found");
    _createBusMarkers();
    // busTrackingService.getEstimatedArrivalTime(
    //     const LatLng(-26.1742, 27.95722), const LatLng(-26.183186, 28.004540));
    busTracker.busPositionTimer();

    // dataAccess
    //     .filterByCoordinates(-26.174159869717354, 27.957245724156362)
    //     .then((busStops) {
    //   // Process the filtered bus stops
    //   print("Bus_number");
    //   print(busStops[0]['bus_numbers']);
    // });

//     final api = GooglePlacesApi(apiKey: 'YOUR_API_KEY');
    // print(currentLocation);
    // print(foundMark);
  }

  void getBusStop() async {
    print("getBusInside");

    final busStops = await busServices.getBusStops(
      latitude: currentLocation?.latitude ?? 0.0,
      longitude: currentLocation?.longitude ?? 0.0,
      radius: 1000,
    );
    print(busStops);
    // await busServices.getTransitDirections(-26.1740319390168,
    //     27.956400781280113, -26.183177132555347, 27.99042141048071);

    //check if the current bus stops are reya vays bus stops and filter out the none
    List<dynamic> filteredBusStops = [];
    List<LatLng> coordinatesBusStops = []; // Declare the list outside the loop
    await Future.wait(busStops.map((LatLng busStop) async {
      List<dynamic> filteredStops = await dataAccess.filterByCoordinates(
        busStop.latitude,
        busStop.longitude,
      );
      print("Inside ");
      print(busStop.latitude);
      if (filteredStops.isNotEmpty) {
        print("The data");
        print(filteredStops);
        dynamic busStop = busStops.first;
        // dynamic coordinates = busStop["coordinates"];
        print(busStop);
        // double latitude = coordinates["latitude"];
        // double longitude = coordinates["longitude"];
        // LatLng coor = LatLng(latitude, longitude);
        coordinatesBusStops.add(busStop);
        filteredBusStops
            .addAll(filteredStops); // Update the list with the filtered stops
      }
    }));

    // print(filteredBusStops);
    // print(coordinatesBusStops);
    // _busStopsCoordinates = coordinatesBusStops;
    _busStopsCoordinates = filteredBusStops;
    _createMarkers();

    print("busStops ");
    // print(busStops);

    // Fetch and display details for each place
  }

  // void _createMarkers() {
  //   setState(() {
  //     _busStopMarkers = _busStopsCoordinates.map((LatLng latLng) {
  //       return Marker(
  //         markerId: MarkerId(latLng.toString()),
  //         position: latLng,
  //       );
  //     }).toList();
  //   });
  // }

  //create bus marks
  void _createBusMarkers() {
    // final busList = busTracker.getBusPositions();
    // print(busList.toString());
    //BuildContext context
    setState(() {
      List<Bus> busList = busTracker.getBusPositions(context);
      _busMarkers = busList.map((Bus bus) {
        // Coordinates coordinates = bus.coordinates;
        print("cooordinates");
        // print(busTracker
        //     .coordinatesToLatlng(busList.first.coordinates)
        //     .toString());
        return Marker(
          markerId: MarkerId(
              busTracker.coordinatesToLatlng(bus.coordinates).toString()),
          position: busTracker.coordinatesToLatlng(bus.coordinates),
          infoWindow: InfoWindow(
              title: 'Reya vaya',
              snippet:
                  busTracker.coordinatesToLatlng(bus.coordinates).toString()),
          // (${context.watch<BusTrackingState>().busArrivalState}),
          onTap: () {
            onMarkerTapped(MarkerId(
                busTracker.coordinatesToLatlng(bus.coordinates).toString()));
          },
        );
      }).toList();
    });
  }

  void _createMarkers() {
    setState(() {
      _busStopMarkers = _busStopsCoordinates.map((dynamic busStop) {
        dynamic coordinates = busStop["coordinates"];
        double latitude = coordinates["latitude"];
        double longitude = coordinates["longitude"];
        List bus = busStop["bus_numbers"];

        LatLng latLng = LatLng(latitude, longitude);

        return Marker(
          markerId: MarkerId(latLng.toString()),
          position: latLng,
          infoWindow: InfoWindow(title: 'Reya vaya', snippet: bus.toString()),
          onTap: () {
            onMarkerTapped(MarkerId(latLng.toString()));
          },
        );
      }).toList();
    });
  }

  //create global busPositions State

//markers call back function

  void onMarkerTapped(MarkerId markerId) {
    // Find the corresponding bus stop based on the markerId
    print(markerId.value);
    // LatLng busStopCoordinates =  busTracker.castStringToLatLng(markerId.value);
    print(LatLng(_busStopsCoordinates.first["coordinates"]['latitude'],
        _busStopsCoordinates.first["coordinates"]['longitude']));

    dynamic busStop = _busStopsCoordinates.firstWhere(
      (busStop) =>
          MarkerId(LatLng(busStop["coordinates"]['latitude'],
                  busStop["coordinates"]['longitude'])
              .toString()) ==
          markerId,
      orElse: () => null,
    );

    if (busStop != null) {
      // Bus stop found, extract the bus numbers
      List busNumbers = busStop["bus_numbers"]; 

      //get bus positions of provided bus numbers

      //get bus info
      busTracker.getBusPositions(context);
      // showModalBottomSheet(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return Container(
      //       child: Padding(
      //         padding: EdgeInsets.all(16.0),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             Text(
      //               'Bus Stop ',
      //               style: TextStyle(
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: 18.0,
      //               ),
      //             ),
      //             SizedBox(height: 16.0),
      //             Text('Bus\'s: ${busNumbers.join(", ")}'),
      //             Text('Bus Arrivals'),
      //             Text(busTrackingState.busArrivalText),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // );
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Consumer<BusTrackingState>(
            builder: (context, busTrackingState, _) {
              // Access the busArrivalText from the busTrackingState and use it in the UI
              return Container(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bus Stop',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                      SizedBox(height: 16.0),
                      Text('Bus\'s: ${busNumbers.join(", ")}'),
                      Text('Bus Arrivals'),
                      Text(busTrackingState.busArrivalText),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Bus tacker",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: currentLocation == null
            ? const Center(child: Text("Loading"))
            : GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 15.5,
                ),
                polylines: {
                  Polyline(
                    polylineId: PolylineId("route"),
                    points: polylineCoordinates,
                    color: primaryColor,
                    width: 6,
                  ),
                },
                markers: {
                  ..._busStopMarkers,
                  ..._busMarkers, // Add the _markers list here
                  Marker(
                    markerId: const MarkerId("currentLocation"),
                    icon: currentLocationIcon,
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                  ),
                  Marker(
                    markerId: MarkerId("source"),
                    icon: sourceIcon,
                    position: sourceLocation,
                  ),
                  Marker(
                    markerId: MarkerId("destination"),
                    icon: destinationIcon,
                    position: destination,
                  ),
                  Marker(
                    markerId: MarkerId('busMarker'),
                    position: _busRoute[_busPosition],
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure),
                    infoWindow: const InfoWindow(
                      title: 'Bus Location',
                    ),
                  ),
                },
                // onMapCreated: (mapController) {
                //   _controller.complete(mapController);
                // },
              ));
  }
}
