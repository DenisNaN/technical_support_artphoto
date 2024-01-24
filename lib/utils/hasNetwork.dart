import 'package:connectivity_plus/connectivity_plus.dart';


class HasNetwork{
  static bool isConnecting = false;

  Future checkConnectingToInterten() async{

    final connectivityResult = await (Connectivity().checkConnectivity());

    if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
      isConnecting = true;
    }
  }
}