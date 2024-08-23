import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/DailyTasks.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddPlanUser extends StatefulWidget {
  @override
  _AddPlanUserState createState() => _AddPlanUserState();
}

class _AddPlanUserState extends State<AddPlanUser> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedEmployee;
  TextEditingController _entryController = TextEditingController();
  int _isPlanCompleted = 2;
  List<Map<String, dynamic>> _employeeList = [];
  List<dynamic> _teamsList = [];
  int? _selectedTeam;
  // static String baseurl="https://pw-bms-dev.portalwiz.in/laravelapi/public/api";
  static String baseurl = "https://portalwiz.net/laravelapi/public/api";
  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> addDailyPlan() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    final requestBody = {
      "plan_date": "${_selectedDate.toIso8601String().split('T')[0]}",
      "user_id": "${sharedPreferences.getInt("user_id")}",
      "user_name": "${sharedPreferences.getString("user_full_name")}",
      "plan_name": _entryController.text,
      "achievements": "",
      "comments": "",
      "team_id": "$_selectedTeam",
      "status": "$_isPlanCompleted",
      "lk_feedback_id": "0",
    };
    print(requestBody);
    try {
      bool success = await ApiCalls.addDailyPlan(requestBody);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data inserted successfully.')),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DailyTasks(
                      title: "tasks",
                      today: true,
                    )));
        _entryController.clear();
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

  Future<void> fetchTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id') ?? 0;

    if (userId != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseurl/fetch_teams'),
          body: {"user_id": "$userId", "role_id": "${prefs.getInt("role_id")}"},
        );
        print(response.body);

        if (response.statusCode == 200) {
          final List<dynamic> teamsData = jsonDecode(response.body);
          setState(() {
            _teamsList = teamsData;
          });
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

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add your Plan'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Daily Plans Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Plans',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Checkbox(
                        //   value: _isPlanCompleted,
                        //   onChanged: (bool? value) {
                        //     setState(() {
                        //       _isPlanCompleted = value ?? false;
                        //     });
                        //   },
                        // ),
                        CustomAnimatedToggleSwitch<int>(
                          key: Key("toggle_switch"),
                          current: _isPlanCompleted,
                          values: [2, 0, 1],
                          iconBuilder: (context, local, global) {
                            switch (local.value) {
                              case 0:
                                return Icon(Icons.clear,
                                    color: Colors.red); // Not Done
                              case 2:
                                return Icon(Icons.access_time,
                                    color: Colors.orange); // Pending
                              case 1:
                                return Icon(Icons.check,
                                    color: Colors.green); // Done
                              default:
                                return Icon(Icons.error);
                            }
                          },
                          onChanged: (value) async {
                            setState(() {});
                            // Add additional logic if needed when the value changes
                          },
                          animationDuration: const Duration(milliseconds: 500),
                          animationCurve: Curves.easeInOutCirc,
                          indicatorSize: const Size(48.0, double.infinity),
                          spacing: 10.0, // Space between icons
                          separatorBuilder:
                              (context, separatorProps, globalProps) {
                            return Container(
                              width: 1.0,
                              color: Colors.grey[300],
                            );
                          },
                          onTap: (tapProps) async {
                            // Handle tap events if needed
                            setState(() {
                              _isPlanCompleted = tapProps.tapped!.value;
                            });
                          },
                          fittingMode: FittingMode.preventHorizontalOverlapping,
                          wrapperBuilder: (context, globalProps, child) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey[200],
                              ),
                              child: child,
                            );
                          },
                          foregroundIndicatorBuilder: (context, globalProps) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: (_isPlanCompleted == 0)
                                    ? Colors.redAccent
                                    : (_isPlanCompleted == 1)
                                        ? Colors.greenAccent
                                        : Colors.white,
                              ),
                              child: Center(
                                  child: Icon((_isPlanCompleted == 0)
                                      ? Icons.cancel_outlined
                                      : (_isPlanCompleted == 1)
                                          ? Icons.check
                                          : Icons.pending_outlined)),
                            );
                          },
                          backgroundIndicatorBuilder: (context, globalProps) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blueAccent,
                              ),
                            );
                          },
                          indicatorAppearingBuilder:
                              (context, animationValue, child) {
                            return Opacity(
                              opacity: animationValue,
                              child: child,
                            );
                          },
                          height: 50.0,
                          iconArrangement: IconArrangement.row,
                          iconsTappable: true,
                          padding: EdgeInsets.zero,
                          minTouchTargetSize: 48.0,
                          dragStartDuration: const Duration(milliseconds: 200),
                          dragStartCurve: Curves.easeInOutCirc,
                          textDirection: TextDirection.ltr,
                          cursors: ToggleCursors(),
                          loading:
                              false, // Add a loading indicator if necessary
                          loadingAnimationDuration:
                              const Duration(milliseconds: 300),
                          loadingAnimationCurve: Curves.easeInOut,
                          indicatorAppearingDuration:
                              const Duration(milliseconds: 500),
                          indicatorAppearingCurve: Curves.easeInOut,
                          allowUnlistedValues: false,
                          active: true,
                          positionListener: (positionInfo) {
                            // Optional: Listen to position changes of the indicator
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 16.0),
                    // Date Picker Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.blue),
                        SizedBox(width: 8.0),
                        TextButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null &&
                                pickedDate != _selectedDate)
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                          },
                          child: Text(
                            "${_selectedDate.toLocal()}".split(' ')[0],
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        IconButton(
                          icon: Icon(Icons.copy, color: Colors.blue),
                          onPressed: () {
                            // Implement your copy plan logic here
                          },
                        ),
                        Text(
                          'Copy Plan',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),

                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Team',
                        labelStyle: TextStyle(fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 8.0),
                        isDense: true,
                      ),
                      value: _selectedTeam,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedTeam = newValue;
                          if (_selectedTeam != null) {
                            // fetchTeamEmployees(_selectedTeam!); // Fetch employees when team changes
                          }
                        });
                      },
                      items: _teamsList.map<DropdownMenuItem<int>>((team) {
                        return DropdownMenuItem<int>(
                          value: team['team_id'],
                          child: Text(
                            team['team_name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                    // Dropdown Row
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //       child: DropdownButtonFormField<String>(
                    //         decoration: InputDecoration(
                    //           labelText: 'Select Employee',
                    //           labelStyle: TextStyle(fontSize: 14),
                    //           contentPadding: EdgeInsets.symmetric(
                    //               vertical: 0.0, horizontal: 8.0),
                    //           isDense: true,
                    //         ),
                    //         value: _selectedEmployee,
                    //         onChanged: (String? newValue) {
                    //           setState(() {
                    //             _selectedEmployee = newValue!;
                    //           });
                    //         },
                    //         items: _employeeList.map((employee) {
                    //           return DropdownMenuItem<String>(
                    //             value: employee['first_name'] +
                    //                 ' ' +
                    //                 employee['last_name'],
                    //             child: Text(
                    //               employee['first_name'] +
                    //                   ' ' +
                    //                   employee['last_name'],
                    //               overflow: TextOverflow.ellipsis,
                    //             ),
                    //           );
                    //         }).toList(),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 16.0),
                    // Entry Field
                    TextFormField(
                      controller: _entryController,
                      minLines: 5,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: 'Enter Plan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        addDailyPlan();
                      },
                      child: Text('Add Plan'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
