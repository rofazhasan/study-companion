import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
Stream<bool> isOnline(IsOnlineRef ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // Check if any connection type is available (not none)
    return results.any((result) => result != ConnectivityResult.none);
  });
}

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  @override
  Future<bool> build() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final results = await Connectivity().checkConnectivity();
    state = AsyncValue.data(results.any((result) => result != ConnectivityResult.none));
  }
}
