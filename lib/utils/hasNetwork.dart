import 'package:connectivity_plus/connectivity_plus.dart';

class HasNetwork{
  Future<bool> isConnectInterten() async{
    bool isConnect = false;

    final connectivityResult = await (Connectivity().checkConnectivity());

    if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
      isConnect = true;
    }

    return isConnect;
  }
}