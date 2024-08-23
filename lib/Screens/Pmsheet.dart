import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectManagerSheet extends StatefulWidget {
  ProjectManagerSheet(
      {required this.planid,
      required this.updateList,
      required this.seletDate});
  final int? planid;
  Function updateList;
  DateTime seletDate;

  @override
  _ProjectManagerSheetState createState() => _ProjectManagerSheetState();
}

class _ProjectManagerSheetState extends State<ProjectManagerSheet> {
  String? _selectedEmployee;
  TextEditingController _entryController = TextEditingController();
  int _isPlanCompleted = 2;
  List<dynamic> _employeeList = [];
  List<dynamic> _teamsList = [];
  int? _selectedTeam;
  int? projectid, projectTaskid;
  int? starint = 0;
  String? achivments, comments;
  // static String baseurl="https://pw-bms-dev.portalwiz.in/laravelapi/public/api";
  static String baseurl = "https://portalwiz.net/laravelapi/public/api";
  @override
  void initState() {
    super.initState();
    fetchTeams();
    fetchPlan();
    // fetchEmployees();
  }

  // void fetchEmployees() async {
  //   try {
  //     List<Map<String, dynamic>> employees = await ApiCalls.fetchEmployees('1100');
  //     setState(() {
  //       _employeeList = employees;
  //       // Fetch the plan after fetching employees
  //       fetchPlan();
  //     });
  //   } catch (e) {
  //     print('Error fetching employees: $e');
  //   }
  // }
  Future<void> fetchPlan() async {
    if (widget.planid != null) {
      try {
        final response = await http.post(
          Uri.parse(
              'https://portalwiz.net/laravelapi/public/api/fetch_single_daily_plan'),
          body: {"plan_id": "${widget.planid}"},
        );

        print(response.body + " new Responseee....");

        if (response.statusCode == 200) {
          final List<dynamic> responseData = jsonDecode(response.body);
          if (responseData.isNotEmpty) {
            final data = responseData[0];
            bool functionData = await fetchTeamEmployees(data['team_id']);
            print(data);
            setState(() {
              widget.seletDate = data['plan_date'] != null
                  ? DateTime.parse(data['plan_date'])
                  : DateTime.now();
              _entryController.text = data['plan_name'] ?? "";
              _isPlanCompleted = data['status'];
              _selectedTeam = data['team_id'];
              achivments = data["achievements"];
              comments = data["comments"];
              starint = data["lk_feedback_id"];
              projectid = data["project_id"];
              projectTaskid = data["project_task_id"];

              if (data['user_id'] != null && functionData) {
                try {
                  final selectedEmployee = _employeeList.firstWhere(
                    (employee) =>
                        employee['user_id'].toString() ==
                        data['user_id'].toString(),
                    orElse: () => null,
                  );
                  _selectedEmployee = selectedEmployee != null
                      ? '${selectedEmployee['first_name']} ${selectedEmployee['last_name']}'
                      : null;
                } catch (e) {
                  print('Employee not found: $e');
                  _selectedEmployee = null;
                }
              }
            });
          } else {
            print('No data found.');
          }
        } else {
          print('Failed to fetch plan. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching plan: $e');
      }
    } else {
      print('Plan ID is null');
    }
  }

  Future<bool> fetchTeamEmployees(int teamId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var url = Uri.parse('${baseurl}/fetch_team_employee');

      // API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "team_id": [teamId],
          "account_id": "${prefs.getInt("account_id")}",
          "user_id": ["${prefs.getInt("user_id")}"]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> employees =
            List<Map<String, dynamic>>.from(data);

        if (mounted) {
          setState(() {
            addOrUpdateDailyPlan();
            _employeeList = jsonDecode(response.body);
          });
        }
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id') ?? 0;

    if (userId != null) {
      try {
        final response = await http.post(
          Uri.parse('${baseurl}/fetch_teams'),
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

  Future<void> addOrUpdateDailyPlan() async {
    if (_selectedEmployee == null || _entryController.text.isEmpty) {
      return;
    }

    final selectedEmployee = _employeeList.firstWhere(
      (employee) =>
          employee['first_name'] + ' ' + employee['last_name'] ==
          _selectedEmployee,
    );

    if (selectedEmployee == null) {
      print('Selected employee not found');
      return;
    }

    final Map<String, dynamic> requestBody = {
      "user_id": selectedEmployee['user_id'].toString(),
      "plan_id": "${widget.planid}",
      "plan_name": _entryController.text,
      "plan_date": widget.seletDate.toIso8601String().split('T')[0],
      "plan_date": widget.seletDate.toIso8601String().split('T')[0],
      "updated_by": selectedEmployee['user_id'].toString(),
      "status": "$_isPlanCompleted",
      "team_id": "$_selectedTeam",
      "achievements": (achivments.isNull) ? null : achivments,
      "comments": (comments.isNull) ? null : comments,
      "project_id": (projectid.isNull) ? null : projectid,
      "project_task_id": (projectTaskid.isNull) ? null : achivments,
    };

    print(requestBody);
    try {
      bool success;
      if (widget.planid != null) {
        final updateResponse = await http.post(
          headers: {
            'Content-Type': 'application/json',
          },
          Uri.parse('${baseurl}/update_daily_plan'),
          body: jsonEncode(requestBody),
        );
        success = updateResponse.statusCode == 200;
        print(updateResponse.body);
      } else {
        print(requestBody);
        success = await ApiCalls.addDailyPlan(requestBody);
      }

      if (success) {
        widget.updateList();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data submitted successfully.')),
        );
        _entryController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit data.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit data: $e')),
      );
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
        title: Text('Project Manager Sheet'),
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
                            print(tapProps.tapped!.value);
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
                              initialDate: widget.seletDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null &&
                                pickedDate != widget.seletDate)
                              setState(() {
                                widget.seletDate = pickedDate;
                                widget.seletDate = pickedDate;
                              });
                          },
                          child: Text(
                            "${widget.seletDate.toLocal()}".split(' ')[0],
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        IconButton(
                          icon: Icon(Icons.copy, color: Colors.blue),
                          onPressed: () {},
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
                    // New Dropdown for Teams
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
                            fetchTeamEmployees(
                                _selectedTeam!); // Fetch employees when team changes
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
                    SizedBox(height: 16.0),
                    // Dropdown for Employees
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Employee',
                        labelStyle: TextStyle(fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 8.0),
                        isDense: true,
                      ),
                      value: _selectedEmployee,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEmployee = newValue;
                        });
                      },
                      items: _employeeList
                          .map<DropdownMenuItem<String>>((employee) {
                        final fullName =
                            '${employee['first_name']} ${employee['last_name']}';
                        return DropdownMenuItem<String>(
                          value: fullName,
                          child: Text(
                            fullName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),
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
                      onPressed: addOrUpdateDailyPlan,
                      child: Text('Submit Plan'),
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
