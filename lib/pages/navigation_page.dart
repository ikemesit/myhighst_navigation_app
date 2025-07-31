// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_navigation_flutter/google_navigation_flutter.dart';
//
// import '../providers/location_provider.dart';
// import '../providers/navigation_provider.dart';
//
// class HomePage extends ConsumerStatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   ConsumerState<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends ConsumerState<HomePage> {
//   late final GoogleNavigationViewController _controller;
//   bool _navigationSessionInitialized = false;
//   bool _mapInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeNavigationSession();
//   }
//
//   Future<void> _initializeNavigationSession() async {
//     try {
//       // Check and show terms if needed
//       if (!await GoogleMapsNavigator.areTermsAccepted()) {
//         await GoogleMapsNavigator.showTermsAndConditionsDialog(
//           'Navigation App',
//           'Your Company Name',
//         );
//       }
//
//       // Initialize navigation session
//       await GoogleMapsNavigator.initializeNavigationSession(
//         taskRemovedBehavior: TaskRemovedBehavior.continueService,
//       );
//
//       setState(() {
//         _navigationSessionInitialized = true;
//       });
//
//       // Get current location after initialization
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ref.read(locationProvider.notifier).getCurrentLocation();
//       });
//     } catch (e) {
//       debugPrint('Error initializing navigation session: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final locationState = ref.watch(locationProvider);
//     final navigationState = ref.watch(navigationProvider);
//     MediaQuery.of(context).size.height * 0.7,
//
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Google Navigation Map
//           GoogleMapsNavigationView(
//             onViewCreated: (GoogleNavigationViewController controller) {
//               _controller = controller;
//               setState(() {
//                 _mapInitialized = true;
//               });
//               _initializeMap();
//             },
//             initialCameraPosition: CameraPosition(
//               target:
//                   locationState.currentLatLng ??
//                   LatLng(latitude: 37.7749, longitude:-122.4194),
//               zoom: 14.0,
//             ),
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             compassEnabled: true,
//             rotateGesturesEnabled: true,
//             scrollGesturesEnabled: true,
//             tiltGesturesEnabled: true,
//             zoomGesturesEnabled: true,
//             mapType: MapType.normal,
//             buildingsEnabled: true,
//             trafficEnabled: true,
//           ),
//
//           // Search Widget
//           const Positioned(top: 50, left: 16, right: 16, child: SearchWidget()),
//
//           // Route Information
//           if (navigationState.route != null && !navigationState.isNavigating)
//             const Positioned(
//               bottom: 180,
//               left: 16,
//               right: 16,
//               child: RouteInfoWidget(),
//             ),
//
//           // Navigation Controls
//           if (navigationState.route != null)
//             const Positioned(
//               bottom: 30,
//               left: 16,
//               right: 16,
//               child: NavigationControlsWidget(),
//             ),
//
//           // Loading indicator
//           if (locationState.isLoading || navigationState.isLoading)
//             const Positioned(
//               top: 120,
//               left: 16,
//               child: Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(width: 16),
//                       Text('Loading...'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//           // Error display
//           if (navigationState.error != null)
//             Positioned(
//               top: 120,
//               left: 16,
//               right: 16,
//               child: Card(
//                 color: Colors.red[50],
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Icon(Icons.error, color: Colors.red[700]),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           navigationState.error!,
//                           style: TextStyle(color: Colors.red[700]),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close),
//                         onPressed: () {
//                           // Clear error by resetting navigation state
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   void _initializeMapController() async {
//     if (_controller == null) return;
//
//     try {
//       // Enable location
//       await _controller!.setMyLocationEnabled(true);
//
//       // Set up navigation event listeners using the correct API
//       GoogleMapsNavigator.setOnArrivalListener((OnArrivalEvent event) {
//         debugPrint('Destination reached: ${event.toString()}');
//         ref.read(navigationProvider.notifier).stopNavigation();
//       });
//
//       GoogleMapsNavigator.setOnRouteChangedListener(() {
//         debugPrint('Route changed');
//       });
//
//       GoogleMapsNavigator.setOnNavigationInfoChangedListener((NavInfo navInfo) {
//         debugPrint('Navigation info changed: ${navInfo.toString()}');
//       });
//     } catch (e) {
//       debugPrint('Error initializing map controller: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     // Clean up navigation session when disposing
//     if (_navigationSessionInitialized) {
//       GoogleMapsNavigator.cleanup();
//     }
//     super.dispose();
//   }
//
// }
