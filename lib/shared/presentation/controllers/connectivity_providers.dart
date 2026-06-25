import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the Connectivity plugin instance.
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Streams the current internet connectivity status.
/// Emits `true` when connected, `false` when offline.
final hasInternetProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);

  final controller = StreamController<bool>();

  // Check initial status
  connectivity.checkConnectivity().then((result) {
    controller.add(_isConnected(result));
  });

  // Listen for changes
  final sub = connectivity.onConnectivityChanged.listen((result) {
    controller.add(_isConnected(result));
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

bool _isConnected(dynamic result) {
  if (result is ConnectivityResult) {
    return result != ConnectivityResult.none;
  }
  if (result is List) {
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }
  return false;
}
