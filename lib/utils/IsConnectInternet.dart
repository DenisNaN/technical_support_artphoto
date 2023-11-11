import 'dart:io';

class ConnectInternet{
  Future<bool> isConnectInterten() async{
    bool isConnect = false;

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnect = true;
      }
    } on SocketException catch (_) {}

    return isConnect;
  }
}