import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/places_provider.dart';
import '../providers/location_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/place.dart';

class SearchWidget extends ConsumerStatefulWidget {
  const SearchWidget({super.key});

  @override
  ConsumerState<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends ConsumerState<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _showResults = false;

  @override
  Widget build(BuildContext context) {
    final placesState = ref.watch(placesProvider);
    final locationState = ref.watch(locationProvider);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for places...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _showResults = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _showResults = value.isNotEmpty;
              });

              if (value.isNotEmpty) {
                ref
                    .read(placesProvider.notifier)
                    .searchPlaces(
                      value,
                      lat: locationState.currentPosition?.latitude,
                      lng: locationState.currentPosition?.longitude,
                    );
              }
            },
          ),
        ),

        if (_showResults && placesState.places.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: placesState.places.length,
              itemBuilder: (context, index) {
                final place = placesState.places[index];
                return ListTile(
                  title: Text(place.name),
                  subtitle: Text(
                    place.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: const Icon(Icons.place),
                  onTap: () {
                    _selectPlace(place);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _selectPlace(Place place) {
    _searchController.text = place.name;
    setState(() {
      _showResults = false;
    });

    // Set destination for navigation
    ref.read(navigationProvider.notifier).setDestination(place);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
