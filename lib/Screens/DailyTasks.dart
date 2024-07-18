import 'dart:convert';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/AddplanUser.dart';
import 'package:bms/Screens/Pmsheet.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

import 'package:bms/pojos/models/DailyTaskListpojo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

List<todolistpojo> listdata = [];

class DailyTasks extends StatefulWidget {

  const DailyTasks({super.key, required this.title});
  final String title;

  @override
  State<DailyTasks> createState() => _DailyTasksState();
}

class _DailyTasksState extends State<DailyTasks> {
  DateTime _selectedValue = DateTime.now();
  bool isLoading = true;
  String? errorMessage;
  var achivments=TextEditingController();
  var comments=TextEditingController();
int roleid=0;
  @override
  void initState() {
    super.initState();
    listTodo();
  }

  Future<void> listTodo() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      setState(() {
        roleid=sharedPreferences.getInt("role_id")??0;
      });
      var url = Uri.parse('https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_daily_plan');
      final response = await http.post(url, body: {
        "user_id": "${sharedPreferences.getInt("user_id")}",
        "role_id": "${sharedPreferences.getInt("role_id")}",
        "plan_date": "${_selectedValue.year}-${_selectedValue.month}-${_selectedValue.day}"
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        setState(() {
          listdata = List<todolistpojo>.from(data.map((i) => todolistpojo.fromJson(i)));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load tasks. Please try again later.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "An error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonth = DateFormat.MMMM().format(_selectedValue);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Tasks"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.12,
              child: DatePicker(
                DateTime.now().subtract(Duration(days: 10)), // Arbitrary past date to allow selection of past dates
                initialSelectedDate: _selectedValue,
                selectionColor: Colors.blueAccent.shade100,
                selectedTextColor: Colors.white,
                onDateChange: (date) {
                  setState(() {
                    _selectedValue = date;
                    isLoading = true;
                    errorMessage = null;
                  });
                  listTodo();
                },
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(top: 8, left: 15),
              child: Text(
                "My Daily Tasks ${_selectedValue.day} $formattedMonth ${_selectedValue.year}",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.72,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : ListView.builder(
                          itemCount: listdata.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: Key(listdata[index].planId.toString()),
                              background: Container(
                                color: Colors.redAccent,
                                child: const Icon(Icons.delete, color: Colors.grey),
                                alignment: Alignment.centerRight,
                              ),
                              direction: DismissDirection.endToStart,
                              child: Card(
                                margin: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15.0, top: 5),
                                            child: Text(
                                              "${listdata[index].planDate}",
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Visibility(
                                            visible: (listdata[index].status == 1),
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 10.0, top: 5),
                                              child: Icon(
                                                Icons.verified_sharp,
                                                size: 24,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                                      child: Text(
                                        "${listdata[index].userName}",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(11)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              listdata[index].planName.toString(),
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Text("Achievements...",
                                              style: TextStyle(
                                                  color: Colors.black, fontWeight: FontWeight.w500)),
                                        ),
                                        Visibility(
                                          visible: (listdata[index].achievements.isNull),
                                          child: GestureDetector(
                                            onTap: (){
                                                  showDialog(context: context,builder: (context){
                                                    return Dialog(
                                                          child: Container(
                                                            height: MediaQuery.of(context).size.height*0.4,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(height: 10,),
                                                                Text("Add Achivements",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                                                             Padding(
                                                               padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20),
                                                               child: TextField(
                                                              
                                                                controller: achivments,
                                                                maxLines: 5,
                                                                decoration: InputDecoration(
                                                                  hintText: "write here...",
                                                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)))
                                                                ),
                                                               ),
                                                             ),

                                                             ElevatedButton(onPressed: (){
                                                                  updateplan(listdata[index].planId??0,listdata[index].planDate??"",listdata[index].planName??"",listdata[index].achievements??achivments.text,listdata[index].comments??comments.text);
                                                             }, child: Text("Add Achivments",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),))

                                                              ],
                                                            ),
                                                          ),
                                                    );
                                                  });
                                            },
                                            child: Icon(Icons.add,color: Colors.blueAccent,)))
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(11)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              listdata[index].achievements??" ......",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                                            child: Text("Comment:",
                                                style: TextStyle(
                                                    color: Colors.black, fontWeight: FontWeight.w600)),
                                          ),
                                         ((listdata[index].comments.isNull))?GestureDetector(
                                          onTap: (){
                                      
                                                showDialog(context: context,builder: (context){
                                                      return Dialog(
                                                            child: Container(
                                                              height: MediaQuery.of(context).size.height*0.4,
                                                              child: Column(
                                                                children: [
                                                                  SizedBox(height: 10,),
                                                                  Text("Add Comment",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                                                               Padding(
                                                                 padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20),
                                                                 child: TextField(
                                                                
                                                                  controller: comments,
                                                                  maxLines: 5,
                                                                  decoration: InputDecoration(
                                                                    hintText: "write here...",
                                                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)))
                                                                  ),
                                                                 ),
                                                               ),
                                      
                                                               ElevatedButton(onPressed: (){
                                                                    updateplan(listdata[index].planId??0,listdata[index].planDate??"",listdata[index].planName??"",listdata[index].achievements??achivments.text,listdata[index].comments??comments.text);
                                                               }, child: Text("Add Comment",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),))
                                      
                                                                ],
                                                              ),
                                                            ),
                                                      );
                                                    });
                                      
                                          },
                                          child: Icon(Icons.add,color: Colors.blueAccent,)):Expanded(child: Text("${listdata[index].comments}")),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: (roleid==1),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10.0, bottom: 5),
                                            child: Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Task",
        onPressed: () {
     (roleid==1)?Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProjectManagerSheet())):    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddPlanUser()));
        },
        backgroundColor: Colors.blueAccent.shade100,
        child: const Icon(Icons.add),
      ),
    );
  }
  void updateplan(int i,String date,String plan_name,String achivmentses,String commentsss)async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    final requestBody = {
    "user_id": "${sharedPreferences.getInt("user_id")}",
    "plan_name": "${plan_name}",
    "achievements": "${achivmentses}",
    "comments": "${commentsss}",
    "plan_id":"${i}",
    "plan_date": "${date}",
    "created_by": "${sharedPreferences.getInt("user_id")}",
};
      print(requestBody);
    try {
      bool success = await ApiCalls.updateDailyplan(requestBody);
      if (success) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data inserted successfully.')),
        );
        listTodo();

Navigator.pop(context);
        achivments.clear();
        comments.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to insert data.')),
        );
      }
      print(success);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to insert data: $e')),
      );
    }
    
  


  
}
}


