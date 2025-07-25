import 'package:google_navigation_flutter/google_navigation_flutter.dart';

class Place {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? photoReference;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.photoReference,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return Place(
      id: json['place_id'],
      name: json['name'],
      address: json['formatted_address'] ?? json['vicinity'] ?? '',
      latitude: location['lat'].toDouble(),
      longitude: location['lng'].toDouble(),
      photoReference: json['photos']?.isNotEmpty == true
          ? json['photos'][0]['photo_reference']
          : null,
    );
  }

  NavigationWaypoint toWaypoint() {
    return NavigationWaypoint(
      target: LatLng(latitude: latitude, longitude: longitude),
      placeID: id,
      title: name,
    );
  }
}
