
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/pojos/models/snoozedPojo.dart';
import 'package:get/get.dart';

class BmsAppController extends GetxController{



List<SnozzedClassPojo> dataofCardsSnoozed=<SnozzedClassPojo>[].obs;


var isLoading=true.obs;



Future<List<SnozzedClassPojo>> getSnoozedApiCall()async{

isLoading(true);

dataofCardsSnoozed=await ApiCalls.getSnoozedData();
printError(info: dataofCardsSnoozed.length.toString());

if(dataofCardsSnoozed.isEmpty){
  return dataofCardsSnoozed;
}
else{
    isLoading(false);
  return dataofCardsSnoozed;

}






}



}