import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override 
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print("okk");

       Get.rawSnackbar(shouldIconPulse: true,title: "Poor Internet Connection",message: "Sorry Try or Check your Internet Again",icon: Icon(Icons.wifi_off),isDismissible: true,backgroundColor: Colors.redAccent,duration: Duration(days:1));

      } else {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
      }
  }
}