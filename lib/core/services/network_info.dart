import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  // دالة سريعة بترجع true لو فيه نت، و false لو مفيش
  Future<bool> get isConnected async {
    final List<ConnectivityResult> connectivityResults = await _connectivity
        .checkConnectivity();

    // لو القائمة فيها none يبقى مفيش نت خالص
    if (connectivityResults.contains(ConnectivityResult.none)) {
      return false;
    }
    // لو واصل واي فاي أو موبايل داتا يبقى تمام
    return connectivityResults.contains(ConnectivityResult.wifi) ||
        connectivityResults.contains(ConnectivityResult.mobile);
  }

  // ميزة مراقبة النت بشكل مستمر (Stream)
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
