import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myhighst_map_app_v2/utils/get_api_key.dart';
import '../models/place.dart';

final placesProvider = StateNotifierProvider<PlacesNotifier, PlacesState>((
  ref,
) {
  return PlacesNotifier();
});

class PlacesState {
  final List<Place> places;
  final bool isLoading;
  final String? error;

  PlacesState({this.places = const [], this.isLoading = false, this.error});

  PlacesState copyWith({List<Place>? places, bool? isLoading, String? error}) {
    return PlacesState(
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PlacesNotifier extends StateNotifier<PlacesState> {
  PlacesNotifier() : super(PlacesState());

  final Dio _dio = Dio();
  static final String _apiKey = 'TOKEN';

  // PlacesNotifier() : super(PlacesState()) {
  //   _init();
  // }

  // TODO test if this implementation wworks correctly
  // Future<void> _init() async {
  //   _apiKey = await getApiKey();
  // }

  Future<void> searchPlaces(String query, {double? lat, double? lng}) async {
    if (query.isEmpty) {
      state = state.copyWith(places: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json';
      Map<String, dynamic> params = {'query': query, 'key': _apiKey};

      if (lat != null && lng != null) {
        params['location'] = '$lat,$lng';
        params['radius'] = '50000';
      }

      final response = await _dio.get(url, queryParameters: params);

      if (response.data['status'] == 'OK') {
        final List<Place> places = (response.data['results'] as List)
            .map((json) => Place.fromJson(json))
            .toList();

        state = state.copyWith(places: places, isLoading: false);
      } else {
        throw Exception('Failed to search places: ${response.data['status']}');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
