import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/pojos/models/enquireComment.dart';
import 'package:get/get.dart';

class CommentEnquiredata extends GetxController{
  List<EnquiresCommentss> commentsdata=<EnquiresCommentss>[].obs;   
var isLoading=true.obs;

Future<List<EnquiresCommentss>> getEnquireComments(int accid, int cardid)async{
  isLoading(true);
commentsdata=await  ApiCalls.getEnquireComment(accid.toString(), cardid.toString());


if(commentsdata.isEmpty){
  isLoading(false);
  return commentsdata;
}
else{
  isLoading(false);
  return commentsdata;
}


}

}