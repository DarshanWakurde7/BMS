

import 'package:bms/pojos/models/CardPojodata.dart';
import 'package:bms/pojos/models/Commentpojo.dart';
import 'package:bms/pojos/models/Enquirepojo.dart';
import 'package:bms/pojos/models/FilterDataPojo.dart';

import 'package:bms/pojos/models/TimesheetPojo.dart';
import 'package:bms/pojos/models/enquireComment.dart';
import 'package:bms/pojos/models/getAllDataofEnquireCard.dart';
import 'package:bms/pojos/models/snoozedPojo.dart';
import 'package:bms/widgets/enquireCommentCard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



List<Autogenerated> dataOfCards=<Autogenerated>[];
List<Autogenerated> dataofCardClear=[];
 List<String> myStatus=[]; 
 List<String> getTasks=[]; 
 List<String> myCategories=[]; 
 List<String> myprority=[];
 List<Commentpojo> myComment=[];
 List<TimeSheetPojo> timeSheet=[];
class ApiCalls{

  // static String baseurl="https://pw-bms-dev.portalwiz.in/laravelapi/public/api/";
  static String baseurl="https://portalwiz.net/laravelapi/public/api/";

static Future<dynamic> getDataofCards(String status_id)async{

  dataOfCards.clear();
var pref=await SharedPreferences.getInstance();

try{
  Uri uri=Uri.parse('${baseurl}fetch_project_tasks_by_user');

var body={
"account_id":pref.getInt('account_id').toString(),
"user_id":pref.getInt('user_id').toString(),
"role_id":pref.getInt('role_id').toString(),

"status_group_id":status_id,


};





var response=await http.post(uri,body: body);
var data=jsonDecode(response.body);



  
for(Map<String,dynamic> i in data){

dataOfCards.add(Autogenerated.fromJson(i));

}

}
catch(e){
 print(e);
}




}


static Future<dynamic> getStatus(String accid)async{



var body2={
"account_id":accid,
};


Uri uri2=Uri.parse('${baseurl}fetch_task_status?');
Uri uripriority=Uri.parse('${baseurl}fetch_priority');
try{
var response2=await http.post(uri2,body: body2);
var status=jsonDecode(response2.body.toString());
var responsepriority=await http.get(uripriority);
var priority=jsonDecode(responsepriority.body.toString());




myStatus.clear();
for(Map<String,dynamic> i in status){

myStatus.add(i["task_status"]);

}
myprority.clear();
for(Map<String,dynamic> i in priority){


myprority.add(i['priority']);

}


}
catch (E){
  print(E);
}
}

static Future<void> getComments(int accid,int projectid,int projectTaskId)async{

  
var body={

  "account_id":accid.toString(),
  "project_id":projectid.toString(),
  "project_task_id":projectTaskId.toString()
};
try{
Uri url=Uri.parse("${baseurl}fetch_task_comment?");

final response=await http.post(url,body: body);

if(response.statusCode==200){
myComment.clear();
for(Map<String,dynamic>  i in jsonDecode(response.body.toString())){

myComment.add(Commentpojo.fromJson(i));

}

}
}
catch (e){
  print(e);
}








}

//----------------------------------------------------
static Future<void> getProjectComment(int accid,int projectid)async{

  
var body={

  "account_id":accid.toString(),
  "project_id":projectid.toString(),

};

Uri url=Uri.parse("${baseurl}fetch_project_comment?");
try{
final response=await http.post(url,body: body);

if(response.statusCode==200){
myComment.clear();
for(Map<String,dynamic>  i in jsonDecode(response.body.toString())){

myComment.add(Commentpojo.fromJson(i));

}}





}
catch(e){
  print(e);
}








}




static Future<bool> postComment(int accid,int projectid,int projectTaskId,int createby,String message,int useid)async{

  
var body={

  "account_id":accid.toString(),
  "project_id":projectid.toString(),
  "project_task_id":projectTaskId.toString(),
  "created_by":createby.toString(),
  "message":message,
  "user_id":useid.toString(),
};

Uri url=Uri.parse("${baseurl}add_task_comment?");

final response=await http.post(url,body: body);

if(response.statusCode==200){
return true;
}
else{
  return false;
}








}


static Future<dynamic> getDataofTimeShaeet(int accid,int userid)async{


var body={
"account_id":accid.toString(),
"user_id":userid.toString(),
};

// var body={
//     "account_id": "1100",
//     "user_id": 97.toString()
// };

Uri url=Uri.parse("${baseurl}fetch_timesheet_by_user?");

final response=await http.post(url,body: body);


if(response.statusCode==200){
timeSheet.clear();
for(Map<String,dynamic> i in jsonDecode(response.body.toString())){

timeSheet.add(TimeSheetPojo.fromJson(i));

}



}

}

static Future<dynamic> deleteTaskbyUser(int accid,int projectid,BuildContext context)async{




var body={
"account_id":accid.toString(),
"project_id":projectid.toString(),
};

Uri url=Uri.parse("${baseurl}delete_project_task?");

final response=await http.post(url,body: body);


if(response.statusCode==200){

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  backgroundColor: Colors.redAccent,
  content: Text(jsonDecode(response.body.toString())['message']
  )
  )
  );
}

}


static Future<dynamic>  gettaskByUser(int accid) async{


var body={
"account_id":accid.toString(),
};

Uri url=Uri.parse("${baseurl}fetch_task_types?");

final response= await http.post(url,body: body);


if(response.statusCode==200){


  getTasks.clear();

for(Map<String,dynamic> i in jsonDecode(response.body.toString())){

getTasks.add(i["task_type"]);

}


}





}



static Future<dynamic> gettaskCategory(int accid)async{



var body={
"account_id":accid.toString(),
};

Uri url=Uri.parse("${baseurl}fetch_task_categories?");

final response= await http.post(url,body: body);


if(response.statusCode==200){


  myCategories.clear();

for(Map<String,dynamic> i in jsonDecode(response.body.toString())){

myCategories.add(i["task_category"]??"");

}


}
}



static Future<dynamic> getUsersByTask(int accid,List<int> projectid)async{


          Uri url=Uri.parse("${baseurl}fetch_users_by_projects");

          var body=jsonEncode({"account_id":accid.toString(),"project_id":projectid,
          });

        final response=await http.post(url,body: jsonEncode(body));
        if(response.statusCode==200){

print(jsonDecode(response.body.toString()));
     print(body.runtimeType);

        }
        else{
          print(response.statusCode);
     
        }


}



static Future<void> getTimesheetbyTask(int accid,int taskid)async{


          Uri url=Uri.parse("${baseurl}fetch_timesheet_by_task?");

          var body={
            "account_id":accid.toString(),"task_id":taskid.toString(),
};

        final response=await http.post(url,body: body);
        if(response.statusCode==200){

timeSheet.clear();

for(Map<String,dynamic> i in jsonDecode(response.body.toString())){
  timeSheet.add(TimeSheetPojo.fromJson(i));
}

        }
        else{
         
     
        }


}










static Future<dynamic>  addTimeSheetOfProject(int project_task_id,int accid,int projectid,String startdate,String enddate,int taskStatus,int prorityid,int assignedto,int createdBy,String taskdesc,String reported_date,String comment,String startTime,String endTime)async{

      var body={
    "project_task_id": project_task_id,
    "account_id": accid,
    "project_id": projectid,
    "act_start_date": startdate,
    "act_end_date": enddate,
    "task_status": taskStatus,
    "priority_id": prorityid,
    "assinged_to": assignedto,
    "created_by": createdBy,
    "task_desc": taskdesc,
    "reported_date": reported_date,
    "reported_time": null,
    "comment": comment,
    "start_time": startTime,
    "end_time": endTime
};








Uri url=Uri.parse("${baseurl}update_project_task_by_user?");
http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
// print(body)

if(response.statusCode==200){
  print("okkk added");
  print(response.body);
}
else{
  print(response.body);
}



}



static Future<List<SnozzedClassPojo>> getSnoozedData()async{

   List<SnozzedClassPojo> snoozedData=[];
var pref=await SharedPreferences.getInstance();
var body={
"account_id":pref.getInt('account_id').toString(),
"user_id":pref.getInt('user_id').toString(),
"role_id":pref.getInt('role_id').toString(),
};

Uri url=Uri.parse("${baseurl}fetch_snooze_task");

final response=await http.post(url,body: body);


for(Map<String,dynamic> i in jsonDecode(response.body)){
snoozedData.add(SnozzedClassPojo.fromJson(i));
}

return snoozedData;


}



static Future<List<EnquiresPojo>> getEnquireCard(String id,List enqids,List<int> assigned,List Enqsource,List EnqType,String createdDatefrom,String createdDateto,String updatedfromdate,String updatedtodate,String enqfromdate,String Enqtodate,String EnqCount)async{

   List<EnquiresPojo> enquireData=[];
// var pref=await SharedPreferences.getInstance();

DateTime dateTime=DateTime.now();
String date="${dateTime.month}/${dateTime.day}/${dateTime.year}";
print(date);
Map<String, dynamic> requestBody =
{
    "account_id":id,
    "enquiry_status_id":(enqids.isEmpty)?null:enqids,
    "assigned_to":(assigned.isEmpty)?null:assigned,
    "enquiry_sources": (Enqsource.isEmpty)?null:Enqsource,
    "enquiry_type": (EnqType.isEmpty)?null:EnqType,
    "created_from_date": (createdDatefrom.isEmpty)?"09/24/2022":createdDatefrom,
    "created_to_date":(createdDateto.isEmpty)? date:createdDateto,
    "updated_from_date": (updatedfromdate.isEmpty)?null:updatedfromdate,
    "updated_to_date": (updatedtodate.isEmpty)?null:updatedtodate,
    "enquiry_from_date": (enqfromdate.isEmpty)?null:enqfromdate,
    "enquiry_to_date": (Enqtodate.isEmpty)?null:Enqtodate,
    "enq_count": "50"
};




  // Encode the request body to JSON
  try{
  String jsonBody = jsonEncode(requestBody);
Uri url=Uri.parse("${baseurl}filtered_enquiries");
 http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );

print("-----------");
print(requestBody);
print(response.body);
for(Map<String,dynamic> i in jsonDecode(response.body)){
enquireData.add(EnquiresPojo.fromJson(i));
}
  }
  catch(e){
    print(e);

  }

return enquireData;


}



static String customJsonEncode(Object object) {
  if (object == null) {
    return 'null';
  }
  return json.encode(object);
}

static Future<String> addEnquireCall(String fname, String lname, String phone, String email, String state, String city, String enq_detail_msg, String whatsapp_no, String company_name, String created_by, String account_id, String enquiry_date, String data_source, String address, String enquiry_type_id, String applicant_type_id, String enquiry_mode_id, String lead_level_id, String enquiry_status_id, String assigned_to, String estimated_closure_date, String next_appointment_date, String notes) async {

  // Helper function to handle null values
  dynamic encodeValue(dynamic value) {
    return value.isEmpty ? null : value;
  }

  var requestBody = {
    "fname": encodeValue(fname),
    "lname": encodeValue(lname),
    "phone": encodeValue(phone),
    "email": encodeValue(email),
    "state": encodeValue(state),
    "city": encodeValue(city),
    "pan_number": "",
    "enq_detail_msg": encodeValue(enq_detail_msg),
    "whatsapp_no": encodeValue(whatsapp_no),
    "loan_amount": "",
    "company_name": encodeValue(company_name),
    "pin": "",
    "created_by": encodeValue(created_by),
    "account_id": encodeValue(account_id),
    "enquiry_date": encodeValue(enquiry_date),
    "loan_type": "",
    "data_source": encodeValue(data_source),
    "address": encodeValue(address),
    "enquiry_type_id": encodeValue(enquiry_type_id),
    "applicant_type_id": encodeValue(applicant_type_id),
    "enquiry_mode_id": encodeValue(enquiry_mode_id),
    "lead_level_id": encodeValue(lead_level_id),
    "enquiry_status_id": encodeValue(enquiry_status_id),
    "assigned_to": encodeValue(assigned_to),
    "estimated_closure_date": encodeValue(estimated_closure_date),
    "next_appointment_date": encodeValue(next_appointment_date),
    "notes": encodeValue(notes),
  };

  print(customJsonEncode(requestBody));

  try {
    Uri url = Uri.parse("${baseurl}add_enquiry");
    http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: customJsonEncode(requestBody), // Encode the body as JSON
    );

    print(response.body);

    return jsonDecode(response.body)['message'];
  } catch (e) {
    print(e);
    return "Something Went Wrong";
  }
}













static Future<GetAllDropdownEnquire> getAllDropDOwnsEnquire()async{
var pref=await SharedPreferences.getInstance();
Uri url=Uri.parse("${baseurl}enquiry_dropdown/${pref.getInt('account_id')??1}");

final response=await http.get(url);


print(response.body);


return GetAllDropdownEnquire.fromJson(jsonDecode(response.body));


}





static Future<GetAllDataofEnquire> getFullDataOfEnquire( int id)async{
Uri url=Uri.parse("${baseurl}enquiry_details");

final response=await http.post(url,body: {
    "enquiry_id": "${id}",
});


print("-------------55--------------");
print(response.body);
print("-------------66--------------");
return GetAllDataofEnquire.fromJson(jsonDecode(response.body)[0]);


}

static Future<String> postEnquireCOmments(String SendtoCustomer,String Enqid,String followupdate,String commentStatusid,String profilepath,String message,String createdby,String accountid)async{




Uri url=Uri.parse("${baseurl}add_commentlog");

var body={
    "send_to_customer": SendtoCustomer,
    "enquiry_id": Enqid,
    "follow_up_date": followupdate,
    "comment_status_id": commentStatusid,
    "profile_path": profilepath,
    "message": message,
    "created_by": createdby,
    "account_id": accountid
};
final response=await http.post(url,body: body);


return (jsonDecode(response.body)['message']);




}


static Future<List<EnquiresCommentss>> getEnquireComment(String accid,String enqid)async{

List<EnquiresCommentss> enquireComment=[];
  try{

Uri url=Uri.parse("${baseurl}fetch_comment_log");
print(accid);
print(enqid);

var body={
    "account_id": accid,
    "enquiry_id": enqid
};

    final response=await http.post(url,body: body);

    // print(response.body);

    for(Map<String,dynamic> i in jsonDecode(response.body)){
      enquireComment.add(EnquiresCommentss.fromJson(i));
    }
    return enquireComment;

  }
  on Exception catch (e){
    print(e);
        return enquireComment;
  }
  catch (e){
    print(e);
        return enquireComment;
  }


  



}



static Future<String> updateProjectTaskByUser(Autogenerated cardData )async{

Uri url=Uri.parse("${baseurl}update_project_task_by_user");

var body={
    "account_id": cardData.accountId,
    "project_task_id":  cardData.projectTaskId,
    "project_id":  cardData.projectId,
    "task_type":  cardData.taskType,
    "phase_id":  cardData.phaseId,
    "task_name":  cardData.taskName,
    "task_category":  cardData.taskCategory,
    "est_start_date":  cardData.estStartDate,
    "est_end_date":  cardData.estEndDate,
    "plan_start_date":  cardData.planStartDate,
    "plan_end_date":  cardData.planEndDate,
    "act_start_date":  cardData.actStartDate,
    "act_end_date":  cardData.actEndDate,
    "task_status":  cardData.taskStatus,
    "priority_id":  cardData.priorityId,
    "sequence":  cardData.sequence,
    "assinged_to":  cardData.assingedTo,
    "collaborators_id":  (cardData.collaborators??[]).join(','),
    "est_efforts":  cardData.estEfforts,
    "due_date":  cardData.dueDate,
    "ext_efforts": "",
    "act_efforts":  cardData.actEfforts,
    "start_time":  cardData.startTime,
    "focus":  cardData.focus,
    "invoiced":  cardData.invoiced,
    "billable":  cardData.billable,
    "snooze_task":  cardData.snoozeTask,
    "snooze_date":  cardData.snoozeDate,
    "edit_mode":  cardData.editMode,
    "created_by":  cardData.createdBy,
    "created_at":  cardData.createdAt,
    "updated_by":  cardData.updatedBy,
    "updated_at":  cardData.updatedAt,
    "attachment":  cardData.attachment,
    "task_desc":  cardData.taskDesc,
    "ref_project_task_id":  cardData.refProjectTaskId,
    "reported_date":  cardData.reportedDate,
    "reported_time":  cardData.reportedTime,
    "end_time":  cardData.endTime,
    "assinged_name":  cardData.assingedName,
    "my_efforts":  cardData.myEfforts,
    "all_efforts":  cardData.allEfforts,
    "task_day_ago":  cardData.taskDayAgo,
    "project_name":  cardData.projectName,
    "priority_name":  cardData.priorityName,
    "task_type_name":  cardData.taskTypeName,
    "task_category_name":  cardData.taskCategoryName,
    "focus_id":  cardData.focusId,
    "collaborators": cardData.collaborators,
    "status": cardData.status,
    "status_group": cardData.statusGroup
};
http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );


print(response.body);



return jsonDecode(response.body)['message'];



}









}







