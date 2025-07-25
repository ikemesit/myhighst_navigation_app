import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:myhighst_map_app_v2/models/navigation_step.dart';

class NavigationRoute {
  final List<LatLng> polylinePoints;
  final String duration;
  final String distance;
  final List<NavigationStep> steps;
  final NavigationWaypoint destination;

  NavigationRoute({
    required this.polylinePoints,
    required this.duration,
    required this.distance,
    required this.steps,
    required this.destination,
  });
}

class RPosition {
  final double latitude;
  final double longitude;

  RPosition(this.latitude, this.longitude);

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
