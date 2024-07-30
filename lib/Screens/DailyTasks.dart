import 'dart:convert';

import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/AddplanUser.dart';
import 'package:bms/Screens/Pmsheet.dart';
import 'package:bms/Screens/PopUpFroCopydailyPLan.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:bms/pojos/models/DailyTaskListpojo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:multi_dropdown/models/value_item.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'animated_search_bar.dart';

List<todolistpojo> listData = [];
List<todolistpojo> filteredList = [];

class DailyTasks extends StatefulWidget {
  const DailyTasks({super.key, required this.title});
  final String title;

  @override
  State<DailyTasks> createState() => _DailyTasksState();
}

class _DailyTasksState extends State<DailyTasks> {
  DateTime _selectedValue = DateTime.now();
  bool isLoading = true;
  String valueofTeam="Select Team";
  bool openIt = false;
  String? errorMessage;
  var achievementss = TextEditingController();
  var comments = TextEditingController();
  int roleId = 0;
  List<dynamic> _teamsList = [];
  List<dynamic> _employeeList = [];
   TextEditingController _searchController = TextEditingController();
  List<ValueItem> _selectedTeam=[];
  List<todolistpojo> _filteredListnew=[];
  List<ValueItem<dynamic>> _selectedEmployee=[];
  final searchController = TextEditingController();
  int countpendding=0;
  int countCompleted=0;
 DatePickerController _dateController = DatePickerController();
  //  static String baseurl="https://pw-bms-dev.portalwiz.in/laravelapi/public/api/";
  static String baseurl = "https://portalwiz.net/laravelapi/public/api/";
  @override
  void initState() {
    super.initState();
    _filterList("");
    fetchTeams();
    listTodo();
    fetchCountfordate();
      WidgetsBinding.instance.addPostFrameCallback((_) {
      // Animate to the selected date after the frame is rendered
      _dateController.animateToDate(_selectedValue);
    });
  }

  Future<void> listTodo() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      setState(() {
        roleId=sharedPreferences.getInt("role_id")??0;
      });
  
      final Map<String, dynamic> requestBody = {
    "plan_date": "${_selectedValue.year}-${_selectedValue.month.toString().padLeft(2, '0')}-${_selectedValue.day.toString().padLeft(2, '0')}",
  "user_id":[
  ...(_selectedEmployee == null ||(_selectedEmployee.isEmpty) 
      ? [sharedPreferences.getInt("user_id") ?? 0] // Provide a default value if null
      : _selectedEmployee.map((e) => e.value).toList())
],
    "team_id":_selectedTeam.isEmpty?null:_selectedTeam.map((e){return e.value;}).toList(), // Replace with actual team IDs if needed
    "role_id": "${sharedPreferences.getInt("role_id")}",
  };

print(requestBody);
  // Prepare the URL
  var url = Uri.parse('${baseurl}fetch_daily_plan');

  // Perform the POST request
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );



      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        if (mounted) {
          setState(() {
            roleId=sharedPreferences.getInt("role_id")??0;
            listData = List<todolistpojo>.from(data.map((i) => todolistpojo.fromJson(i)));
            filteredList = listData;

            isLoading = false;
          });
      _filterList("");
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = "Failed to load tasks. Please try again later.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "An error occurred: $e";
        });
      }
    }
  }



fetchCountfordate()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      
      final response=await  http.post(Uri.parse("https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_daily_plan_count"),body: {
          "user_id":"${50}",
          "plan_date":"${_selectedValue.year}-${_selectedValue.month}-${_selectedValue.day}"
        });
        print(response.body);
      if(response.statusCode==200){
        print(jsonDecode(response.body));
          setState(() {
            countpendding=jsonDecode(response.body)["pending"];
            countCompleted=jsonDecode(response.body)["complete"];

          });
      }
    } catch (e) {
      print(e);
    }
}

 Future<bool> fetchTeamEmployees(List<dynamic> teamId) async {
  setState(() {
      _employeeList.clear();
  });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var url = Uri.parse('${baseurl}fetch_team_employee');

      // API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "team_id": teamId,
          "account_id": "${prefs.getInt("account_id")}",
          "user_id": ["${prefs.getInt("user_id")}"]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> employees = List<Map<String, dynamic>>.from(data);
        setState(() {
          _employeeList.addAll(employees);
        });

        print("Employee List: $_employeeList"); // Debug: Print the employee list
        return true;
      } else {
        print('Failed to fetch employees. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error fetching employees: $e');
      return false;
    }
  }

  Future<void> fetchTeams() async {
        setState(() {
      _teamsList.clear();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id') ?? 0;






    if (!(userId == null)) {
      try {
        final response = await http.post(
          Uri.parse('${baseurl}fetch_teams'),
          body: {"user_id": "$userId", "role_id": "${prefs.getInt("role_id")}"},
        );
        print({"user_id": "$userId", "role_id": "${prefs.getInt("role_id")}"});

        if (response.statusCode == 200) {
          final List<dynamic> teamsData = jsonDecode(response.body);

          if (mounted) {
               
            setState(() {
              _teamsList.addAll(teamsData);
            });

            print(_teamsList.length);
       
          }
        } else {
          print('Failed to fetch teams. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching teams: $e');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  
 void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredListnew = filteredList;
      } 
      else if(_filteredListnew.length==0){
    searchController.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No data found!")));
    listTodo();
      }
      
      else {
        _filteredListnew = filteredList
            .where((item) => item.planName!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });


        
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonth = DateFormat.MMMM().format(_selectedValue);
 
 
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Plans"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
             
            height: MediaQuery.of(context).size.height * 0.11,
            child: DatePicker(
              height: MediaQuery.of(context).size.height * 0.06,
              DateTime.now().subtract(Duration(days: 10)),
              initialSelectedDate: _selectedValue,
              controller: _dateController,
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
            padding: EdgeInsets.only(top: 8, left: 15,right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Daily Plan ${_selectedValue.day} $formattedMonth ${_selectedValue.year}",
                  style: TextStyle(color: Colors.grey),
                ),
                Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.redAccent,child: Text("${countpendding}",style: TextStyle(color: Colors.white,fontSize: 12),),radius: 13,),
                    SizedBox(width: 5,),
                    CircleAvatar(backgroundColor: Colors.greenAccent.shade700,child: Text("$countCompleted",style: TextStyle(color: Colors.white,fontSize: 12),),radius: 13,),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
              visible: ((roleId==1)&&(!(_teamsList.isEmpty))),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   Expanded(
                     child: MultiSelectDropDown(
                      hint: "Select Team",
                        onOptionSelected: (val) {
                            
                          fetchTeamEmployees(val.map((e){return e.value;}).toList());
                          setState(() {
                            _selectedTeam = val;
                            _employeeList;
                          });
                       
                        listTodo();
                         // Ensure to refresh the task list
                         
                        },
                        options: _teamsList.map((e) => ValueItem(label: e["team_name"], value: e["team_id"])).toList(),
                        selectedOptions: _selectedEmployee ?? [],
                      ),
                   ),
                   SizedBox(width: 5,),
                  Visibility(
                    visible: _employeeList.isNotEmpty,
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MultiSelectDropDown(
                        hint: "Select Employees",
                        onOptionSelected: (val) {
                          setState(() {
                            _selectedEmployee = val;
                          });
                          listTodo(); // Ensure to refresh the task list
                        },
                        options: _employeeList.map((e) => ValueItem(label: e["first_name"] + " " + e["last_name"], value: e["user_id"])).toList(),
                        selectedOptions: _selectedEmployee ?? [],
                      
                      ),),)
                ],
              ),
            ),
          ),
     Expanded(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : (errorMessage != null || _filteredListnew.isEmpty)
                ? Center(child: Text(errorMessage ?? "No tasks available"))
                : ListView.builder(
      itemCount: _filteredListnew.length + 2, // +1 for the search bar
      itemBuilder: (context, index) {
        if (index == 0) {
          // Search bar
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onChanged: (val){
              _filterList(val);
              print(val);
              },
            ),
          );
        } 
        else if(index>_filteredListnew.length){
            return Center(child: Padding(padding: EdgeInsets.all(20),child: Text("No More Plans"),));
        }
        else {
          // Adjust index for the search bar
          index -= 1;
          return Dismissible(
            key: Key(_filteredListnew[index].planId.toString()),
            background: Container(
              color: Colors.redAccent,
              child: const Icon(Icons.delete, color: Colors.grey),
              alignment: Alignment.centerRight,
            ),
            direction: DismissDirection.endToStart,
            child: Card(
              margin: EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: (_filteredListnew[index].status == 0)
                        ? Colors.redAccent
                        : Colors.greenAccent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              _teamsList.firstWhere((e) => e["team_id"] == _filteredListnew[index].teamId)["team_name"],
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                          Visibility(
                            visible: (_filteredListnew[index].status == 1),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "${_filteredListnew[index].userName}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Visibility(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 0.0),
                            child: GestureDetector(
                              onTap: () => showDialog(
                                context: context,
                                builder: (cocontext) {
                                  return Dialog(
                                    child: StatefulBuilder(
                                      builder: (context, setState) {
                                        return ProjectManagerPopup(
                                          planid: _filteredListnew[index].planId,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              child: Icon(
                                Icons.copy,
                                size: 20,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Divider(
                        color: const Color.fromARGB(255, 203, 203, 203),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 5,),
                          Expanded(
                            child: Text(
                              _filteredListnew[index].planName.toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Divider(
                        color: const Color.fromARGB(255, 203, 203, 203),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text("Achievements",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Visibility(
                            visible: (_filteredListnew[index].achievements == null ||
                                _filteredListnew[index].achievements!.isEmpty),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        child: Container(
                                          height: MediaQuery.of(context).size.height * 0.4,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 10,),
                                              Text(
                                                "Add Achievements",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 20),
                                                child: TextField(
                                                  controller: achievementss,
                                                  maxLines: 5,
                                                  decoration: InputDecoration(
                                                    hintText: "Write here...",
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(15))),
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    updateplan(
                                                      _filteredListnew[index].planId ?? 0,
                                                      _filteredListnew[index].planDate ?? "",
                                                      _filteredListnew[index].planName ?? "",
                                                      achievementss.text,
                                                      _filteredListnew[index].comments ??
                                                          comments.text,
                                                      _filteredListnew[index].userId ?? 0,
                                                      _filteredListnew[index].teamId ?? 0,
                                                      _filteredListnew[index].status ?? 0,
                                                    );
                                                  },
                                                  child: Text(
                                                    "Add Achievements",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w500),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Icon(Icons.add, color: Colors.blueAccent),
                            ))
                      ],
                    ),
                    Visibility(
                      visible: !(_filteredListnew[index].achievements == null),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(11)),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _filteredListnew[index].achievements ?? " ......",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Divider(
                        color: const Color.fromARGB(255, 203, 203, 203),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0,),
                            child: Text("Comments:",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600)),
                          ),
                          (_filteredListnew[index].comments == null ||
                              _filteredListnew[index].comments!.isEmpty)
                              ? GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: Container(
                                        height: MediaQuery.of(context).size.height * 0.4,
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10,),
                                            Text(
                                              "Add Comment",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10.0, vertical: 20),
                                              child: TextField(
                                                controller: comments,
                                                maxLines: 5,
                                                decoration: InputDecoration(
                                                  hintText: "Write here...",
                                                  border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.all(
                                                          Radius.circular(15))),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  updateplan(
                                                    _filteredListnew[index].planId ?? 0,
                                                    _filteredListnew[index].planDate ?? "",
                                                    _filteredListnew[index].planName ?? "",
                                                    _filteredListnew[index].achievements ??
                                                        achievementss.text,
                                                    comments.text,
                                                    _filteredListnew[index].userId ?? 0,
                                                    _filteredListnew[index].teamId ?? 0,
                                                    _filteredListnew[index].status ?? 0,
                                                  );
                                                },
                                                child: Text(
                                                  "Add Comment",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500),
                                                ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Icon(Icons.add, color: Colors.blueAccent),
                          )
                              : Expanded(child: Text("${_filteredListnew[index].comments}")),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (roleId == 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Divider(
                          color: const Color.fromARGB(255, 203, 203, 203),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: (roleId == 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0, bottom: 5),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectManagerSheet(
                                        planid: _filteredListnew[index].planId ?? 0,
                                        updateList: () => listTodo(),
                                      ),
                                    ));
                              },
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    ),
      ),

        ],
      ),

      floatingActionButton: FloatingActionButton(
        
        foregroundColor: Colors.blueAccent.shade200,
        onPressed: (){

         (roleId==1)? Navigator.push(context, MaterialPageRoute(builder: (context)=>ProjectManagerSheet(planid: null,updateList: ()=>listTodo(),))):Navigator.push(context, MaterialPageRoute(builder: (context)=>AddPlanUser()));

      },child: Icon(Icons.add,color: Colors.black,),),
    );
  }

void updateplan(int i, String date, String plan_name, String achievements, String commentss, int user_id, int team_id,int status) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final requestBody = {
      "user_id": "${user_id}",
      "plan_name": "${plan_name}",
      "achievements": "${achievements}",
      "comments": "${commentss}",
      "plan_id": "${i}",
      "plan_date": "${date}",
      "updated_by": "${sharedPreferences.getInt("user_id")}",
      "team_id": "${team_id}",
          "status": "${status}",

    };
    print(requestBody);
    
    try {
      bool success = await ApiCalls.updateDailyPlan(requestBody);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully.')),
        );
        listTodo();
        Navigator.pop(context);
        achievementss.clear();
        comments.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update data.')),
        );
      }
      print(success);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data: $e')),
      );
    }
  }



}
