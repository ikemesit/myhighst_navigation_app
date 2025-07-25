import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/navigation_route.dart';

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });

class NavigationState {
  final NavigationRoute? route;
  final bool isLoading;
  final String? error;
  final bool isNavigating;

  NavigationState({
    this.route,
    this.isLoading = false,
    this.error,
    this.isNavigating = false,
  });

  NavigationState copyWith({
    NavigationRoute? route,
    bool? isLoading,
    String? error,
    bool? isNavigating,
  }) {
    return NavigationState(
      route: route ?? this.route,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  final Dio _dio = Dio();
  static const String _mapboxToken =
      'YOUR_MAPBOX_ACCESS_TOKEN'; // Replace with your token

  Future<void> getRoute(RPosition start, RPosition end) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final String url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': _mapboxToken,
          'geometries': 'geojson',
          'steps': 'true',
          'voice_instructions': 'true',
        },
      );

      if (response.data['routes'].isNotEmpty) {
        final route = response.data['routes'][0];
        final geometry = route['geometry'];
        final legs = route['legs'][0];

        // Decode polyline points
        final List<RPosition> polylinePoints = _decodePolyline(
          geometry['coordinates'],
        );

        // Extract steps
        final List<NavigationStep> steps = (legs['steps'] as List)
            .map(
              (step) => NavigationStep(
                instruction: step['maneuver']['instruction'] ?? '',
                distance: '${(step['distance'] / 1000).toStringAsFixed(1)} km',
                duration: '${(step['duration'] / 60).toStringAsFixed(0)} min',
                startLocation: RPosition(
                  step['maneuver']['location'][1],
                  step['maneuver']['location'][0],
                ),
                endLocation: RPosition(
                  step['geometry']['coordinates'].last[1],
                  step['geometry']['coordinates'].last[0],
                ),
              ),
            )
            .toList();

        final navigationRoute = NavigationRoute(
          polylinePoints: polylinePoints,
          duration: '${(route['duration'] / 60).toStringAsFixed(0)} min',
          distance: '${(route['distance'] / 1000).toStringAsFixed(1)} km',
          steps: steps,
        );

        state = state.copyWith(route: navigationRoute, isLoading: false);
      } else {
        throw Exception('No routes found');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  List<RPosition> _decodePolyline(List<dynamic> coordinates) {
    return coordinates.map((coord) => RPosition(coord[1], coord[0])).toList();
  }

  void startNavigation() {
    state = state.copyWith(isNavigating: true);
  }

  void stopNavigation() {
    state = state.copyWith(isNavigating: false, route: null);
  }
}
