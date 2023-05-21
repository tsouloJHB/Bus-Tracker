import 'package:flutter/material.dart';
import 'package:google_mao/views/order_traking_page.dart';
import 'package:provider/provider.dart';
import 'package:google_mao/views/states/bus_tracking_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BusTrackingState(), // Replace with your actual state class
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const OrderTrackingPage(),
    );
  }
}
