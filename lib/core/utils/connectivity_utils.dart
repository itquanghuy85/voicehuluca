import 'package:connectivity_plus/connectivity_plus.dart';

/// True when the device reports no usable network.
bool isOfflineResult(List<ConnectivityResult> results) =>
    results.isEmpty ||
    results.every((result) => result == ConnectivityResult.none);
