import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScaffoldNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void toggleDrawer() {
    state = !state;
  }
}

final appScaffoldProvider = NotifierProvider<AppScaffoldNotifier, bool>(
  AppScaffoldNotifier.new,
);
