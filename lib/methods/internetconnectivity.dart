import 'package:bms/controller/networkcontroller.dart';
import 'package:get/get.dart';

class DependacyInjection{
  static void init(){

      Get.put<NetworkController>(NetworkController(),permanent: true);

  }
}