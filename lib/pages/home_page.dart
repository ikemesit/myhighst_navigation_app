import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:myhighst_map_app_v2/providers/scaffold_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final GoogleMapViewController _mapViewController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onViewCreated(GoogleMapViewController controller) async {
    _mapViewController = controller;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingBox(
        backdrop: Backdrop(body: _backdrop()),
        minHeight: 400,
        maxHeight: 400,
        style: BoxStyle.shadow,
        color: Colors.white,
        draggableIconBackColor: Colors.white,
        body: _body(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleDrawer() {
    ref.read(appScaffoldProvider.notifier).toggleDrawer();
  }

  _backdrop() {
    return Stack(
      children: [
        GoogleMapsMapView(
          onViewCreated: _onViewCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude: 37.7749, longitude: -122.4194),
            zoom: 15,
          ),
        ),
        Positioned(
          top: 100,
          left: 20,
          width: 50,
          height: 50,
          child: IconButton(
            onPressed: _toggleDrawer,
            icon: Icon(Icons.menu),
            iconSize: 30,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(CircleBorder()),
              elevation: WidgetStatePropertyAll(2.0),
              shadowColor: WidgetStatePropertyAll(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  _body() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Text(
            'Where would you like to go?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter a destination',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
