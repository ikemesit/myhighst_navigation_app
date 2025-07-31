import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import '../models/navigation_route.dart';
import '../models/place.dart';

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });

class NavigationState {
  final NavigationRoute? route;
  final bool isLoading;
  final String? error;
  final bool isNavigating;
  final NavigationWaypoint? destination;
  final List<NavigationWaypoint> waypoints;

  NavigationState({
    this.route,
    this.isLoading = false,
    this.error,
    this.isNavigating = false,
    this.destination,
    this.waypoints = const [],
  });

  NavigationState copyWith({
    NavigationRoute? route,
    bool? isLoading,
    String? error,
    bool? isNavigating,
    NavigationWaypoint? destination,
    List<NavigationWaypoint>? waypoints,
  }) {
    return NavigationState(
      route: route ?? this.route,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isNavigating: isNavigating ?? this.isNavigating,
      destination: destination ?? this.destination,
      waypoints: waypoints ?? this.waypoints,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  Future<void> setDestination(Place place) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final waypoint = place.toWaypoint();
      final waypoints = [waypoint];

      // Create a basic navigation route
      final navigationRoute = NavigationRoute(
        polylinePoints: [], // Will be populated by Google Navigation
        duration: 'Ready', // Will be updated by navigation events
        distance: 'Ready', // Will be updated by navigation events
        steps: [], // Will be populated by Google Navigation
        destination: waypoint,
      );

      state = state.copyWith(
        route: navigationRoute,
        destination: waypoint,
        waypoints: waypoints,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> startNavigation() async {
    if (state.waypoints.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true);

      // Set destinations and start navigation
      await GoogleMapsNavigator.setDestinations(
        Destinations(
          waypoints: state.waypoints,
          displayOptions: NavigationDisplayOptions(
            showDestinationMarkers: true,
            showTrafficLights: true,
          ),
        ),
      );

      await GoogleMapsNavigator.startGuidance();

      state = state.copyWith(isNavigating: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> stopNavigation() async {
    try {
      await GoogleMapsNavigator.stopGuidance();
      state = state.copyWith(
        isNavigating: false,
        route: null,
        destination: null,
        waypoints: [],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> simulateNavigation() async {
    if (state.waypoints.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true);

      // Set destinations with simulation options
      await GoogleMapsNavigator.setDestinations(
        Destinations(
          waypoints: state.waypoints,
          displayOptions: NavigationDisplayOptions(
            showDestinationMarkers: true,
            showTrafficLights: true,
          ),
          routingOptions: RoutingOptions(
            travelMode: NavigationTravelMode.driving,
          ),
        ),
      );
      await GoogleMapsNavigator.startGuidance();

      state = state.copyWith(isNavigating: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
