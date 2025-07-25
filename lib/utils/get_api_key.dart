import 'package:flutter/services.dart';

const platform = MethodChannel('com.example.myhighst_map_app_v2/secrets');

Future<String> getApiKey() async {
  try {
    final String apiKey = await platform.invokeMethod('getApiKey');
    return apiKey;
  } on PlatformException catch (e) {
    print("Failed to get API key: '${e.message}'.");
    return '';
  }
}
