import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripSetupWidget extends ConsumerWidget {
  const TripSetupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Start Location',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Handle start location change
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'End Location',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Handle end location change
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.greenAccent,
            ),
            onPressed: () {
              // Handle trip setup submission
            },
            child: const Text('Start Trip'),
          ),
          SizedBox(height: 64),
          // Uncomment if you want to display route information
          // const SizedBox(height: 8),
          // Text(
          //   'End Location: ${route.endLocation}',
          //   style: Theme.of(context).textTheme.bodyMedium,
          // ),
        ],
      ),
    );
  }
}
