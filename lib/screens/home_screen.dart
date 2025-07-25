import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:myhighst_map_app_v2/widgets/trip_setup_widget.dart';
import '../models/navigation_route.dart';
import '../providers/location_provider.dart';
import '../providers/places_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/search_widget.dart';
import '../widgets/route_info_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PolylineAnnotationManager? polylineAnnotationManager;
  static const String _mapboxToken =
      'pk.eyJ1IjoibXloaWdoc3QiLCJhIjoiY21kNmxtZHF5MDh2cjJqcXZpeWZoZTQyOSJ9.uPFUiIYR_2U66CJdwpWo4g'; // Replace with your token

  @override
  void initState() {
    super.initState();
    // Set the access token
    MapboxOptions.setAccessToken(_mapboxToken);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).getCurrentLocation();
      // showBottomSheet(context, TripSetupWidget());
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final navigationState = ref.watch(navigationProvider);

    // Listen to route changes and update map
    ref.listen<NavigationState>(navigationProvider, (previous, next) {
      if (next.route != null && next.route != previous?.route) {
        _updateMapWithRoute(next.route!);
      }
    });

    return Scaffold(
      body: SlidingBox(
        collapsed: false,
        // maxHeight: context.size?.height,
        minHeight: 300,
        body: TripSetupWidget(),
        backdrop: Backdrop(
          moving: true,
          body: Stack(
            children: [
              // Mapbox Map
              MapWidget(
                key: const ValueKey("mapWidget"),
                cameraOptions: CameraOptions(
                  center: locationState.currentPosition != null
                      ? Point(
                          coordinates: Position(
                            locationState.currentPosition!.longitude,
                            locationState.currentPosition!.latitude,
                          ),
                        )
                      : Point(
                          coordinates: Position(101.7116, 3.1575),
                        ), // Default to San Francisco
                  zoom: 14.0,
                ),
                styleUri: MapboxStyles.MAPBOX_STREETS,
                onMapCreated: (MapboxMap map) {
                  mapboxMap = map;
                  _initializeManagers();
                },
              ),

              // Search Widget
              const Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: SearchWidget(),
              ),

              // Route Information
              if (navigationState.route != null)
                const Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: RouteInfoWidget(),
                ),

              // Navigation Controls
              if (navigationState.route != null)
                Positioned(
                  bottom: 30,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      if (!navigationState.isNavigating)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(navigationProvider.notifier)
                                  .startNavigation();
                            },
                            child: const Text('Start Navigation'),
                          ),
                        ),
                      if (navigationState.isNavigating) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(navigationProvider.notifier)
                                  .stopNavigation();
                              _clearMap();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Stop Navigation'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Loading indicator
              if (locationState.isLoading || navigationState.isLoading)
                const Positioned(
                  top: 120,
                  left: 16,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Loading...'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  showBottomSheet(
    BuildContext context,
    Widget child, {
    bool isScrollControlled = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      builder: (context) => child,
    );
  }

  Future<void> _initializeManagers() async {
    if (mapboxMap == null) return;

    pointAnnotationManager = await mapboxMap!.annotations
        .createPointAnnotationManager();
    polylineAnnotationManager = await mapboxMap!.annotations
        .createPolylineAnnotationManager();
  }

  Future<void> _updateMapWithRoute(NavigationRoute route) async {
    if (mapboxMap == null || polylineAnnotationManager == null) return;

    // Clear existing annotations
    await _clearMap();

    // Add route polyline
    final polylinePoints = route.polylinePoints
        .map((point) => Position(point.longitude, point.latitude))
        .toList();

    final polylineAnnotation = PolylineAnnotation(
      id: 'route',
      geometry: LineString(coordinates: polylinePoints),
      lineColor: Colors.blue.toARGB32(),
      lineWidth: 5.0,
    );

    await polylineAnnotationManager!.create(
      polylineAnnotation as PolylineAnnotationOptions,
    );

    // Add start and end markers
    if (route.polylinePoints.isNotEmpty) {
      final startPoint = route.polylinePoints.first;
      final endPoint = route.polylinePoints.last;

      final startMarker = PointAnnotation(
        id: 'start',
        geometry: Point(
          coordinates: Position(startPoint.longitude, startPoint.latitude),
        ),
        iconImage: 'marker-15',
        iconSize: 2.0,
      );

      final endMarker = PointAnnotation(
        id: 'end',
        geometry: Point(
          coordinates: Position(endPoint.longitude, endPoint.latitude),
        ),
        iconImage: 'marker-15',
        iconSize: 2.0,
      );

      await pointAnnotationManager!.createMulti(
        [startMarker, endMarker] as List<PointAnnotationOptions>,
      );

      // Fit camera to route bounds
      await _fitCameraToRoute(route.polylinePoints);
    }
  }

  Future<void> _fitCameraToRoute(List<RPosition> points) async {
    if (mapboxMap == null || points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = CoordinateBounds(
      southwest: Point(coordinates: Position(minLng, minLat)),
      northeast: Point(coordinates: Position(maxLng, maxLat)),
      infiniteBounds: false,
    );

    await mapboxMap!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            ((minLng + maxLng) / 2),
            ((minLat + maxLat) / 2),
          ),
        ),
        zoom: 12.0,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  Future<void> _clearMap() async {
    if (pointAnnotationManager != null) {
      await pointAnnotationManager!.deleteAll();
    }
    if (polylineAnnotationManager != null) {
      await polylineAnnotationManager!.deleteAll();
    }
  }

  @override
  void dispose() {
    pointAnnotationManager?.deleteAll();
    polylineAnnotationManager?.deleteAll();
    super.dispose();
  }
}
