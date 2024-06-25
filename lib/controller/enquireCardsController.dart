import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/pojos/models/Enquirepojo.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/models/value_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnquireCardsController extends GetxController {
  List<EnquiresPojo> enquiredata = <EnquiresPojo>[].obs;
  var isLoading = true.obs;
  Future<List<EnquiresPojo>> getEnquireCards(
      List<int> enqids,
      List<int> assigned,
      List<ValueItem> Enqsource,
      List<ValueItem> EnqType,
      String createdDatefrom,
      String createdDateto,
      String updatedfromdate,
      String updatedtodate,
      String enqfromdate,
      String Enqtodate,
      String EnqCount) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isLoading(true);
    enquiredata = await ApiCalls.getEnquireCard(
        sharedPreferences.getInt('account_id').toString(),
        enqids,
        assigned,
        Enqsource,
        EnqType,
        createdDatefrom,
        createdDateto,
        updatedfromdate,
        updatedtodate,
        enqfromdate,
        Enqtodate,
        EnqCount);
    if (enquiredata.isEmpty) {
      isLoading(false);
      return enquiredata;
    } else {
      isLoading(false);
      return enquiredata;
    }
  }
}
