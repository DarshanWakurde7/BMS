import 'dart:convert';

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:http/http.dart' as http;
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Checkalldailyplans extends StatefulWidget {
  const Checkalldailyplans({super.key});

  @override
  State<Checkalldailyplans> createState() => _CheckalldailyplansState();
}

class _CheckalldailyplansState extends State<Checkalldailyplans> {
  DateTime _selectedValue = DateTime.now();
  DatePickerController _dateController = DatePickerController();
  List<dynamic> _teamsList = [];
  List<dynamic> _employeeList = [];
  List<Map<String, dynamic>> _taskData = [];
  List<ValueItem> _selectedTeam = [];
  List<ValueItem<dynamic>> _selectedEmployee = [];
  int count = 0;
  //  static String baseurl="https://pw-bms-dev.portalwiz.in/laravelapi/public/api/";
  static String baseurl = "https://portalwiz.net/laravelapi/public/api/";
  int roleId = 0;
  @override
  void initState() {
    listTodo();
    fetchTeamEmployees(null);
    fetchTeams();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Animate to the selected date after the frame is rendered
      _dateController.animateToDate(_selectedValue);
    });
    // TODO: implement initState
    super.initState();
  }

  Future<bool> fetchTeamEmployees(List<dynamic>? teamId) async {
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
        List<Map<String, dynamic>> employees =
            List<Map<String, dynamic>>.from(data);
        setState(() {
          _employeeList.addAll(employees);
        });

        print(
            "Employee List: $_employeeList"); // Debug: Print the employee list
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

  Future<void> listTodo() async {
    try {
      _teamsList.clear();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      setState(() {
        roleId = sharedPreferences.getInt("role_id") ?? 0;
      });

      final Map<String, dynamic> requestBody = {
        "plan_date":
            "${_selectedValue.year}-${_selectedValue.month.toString().padLeft(2, '0')}-${_selectedValue.day.toString().padLeft(2, '0')}",
        "user_id": [
          ...(_selectedEmployee == null || (_selectedEmployee.isEmpty)
              ? [
                  sharedPreferences.getInt("user_id") ?? 0
                ] // Provide a default value if null
              : _selectedEmployee.map((e) => e.value).toList())
        ],
        "team_id": _selectedTeam.isEmpty
            ? null
            : _selectedTeam.map((e) {
                return e.value;
              }).toList(), // Replace with actual team IDs if needed
        "role_id": "${sharedPreferences.getInt("role_id")}",
        "status": "0"
      };

      print(requestBody);
      // Prepare the URL
      var url = Uri.parse('${baseurl}fetch_daily_plan_team_count');
      print("${baseurl}fetch_daily_plan_team_count");
      // Perform the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        if (mounted) {
          setState(() {
            _taskData = List<Map<String, dynamic>>.from(data);
          });
        }
      } else {
        if (mounted) {}
      }
    } catch (e) {
      if (mounted) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plan Summary"),
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
                });
                listTodo();
              },
            ),
          ),
          Visibility(
            visible: true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: MultiSelectDropDown(
                      hint: "Select Team",
                      onOptionSelected: (val) {
                        fetchTeamEmployees(val.map((e) {
                          return e.value;
                        }).toList());
                        setState(() {
                          _selectedTeam = val;
                          _employeeList;
                        });
                        listTodo();

                        // Ensure to refresh the Plan list
                      },
                      options: _teamsList
                          .map((e) => ValueItem(
                              label: e["team_name"], value: e["team_id"]))
                          .toList(),
                      selectedOptions: _selectedEmployee ?? [],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
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
                          listTodo();
                          // Ensure to refresh the Plan list
                        },
                        options: _employeeList
                            .map((e) => ValueItem(
                                label: e["first_name"] + " " + e["last_name"],
                                value: e["user_id"]))
                            .toList(),
                        selectedOptions: _selectedEmployee ?? [],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(12),
                  1: FlexColumnWidth(32),
                  2: FlexColumnWidth(16),
                  3: FlexColumnWidth(20),
                  4: FlexColumnWidth(20),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Sr No.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Emp Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Pending',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Incomplete',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Complete',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  ..._taskData.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    Map<String, dynamic> task = entry.value;
                    return TableRow(
                      decoration: BoxDecoration(
                          color: (_taskData.length == index)
                              ? Colors.blueAccent.shade100
                              : null),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${index})",
                            style: TextStyle(
                                color: (task['manager_status'])
                                    ? Colors.blueAccent
                                    : Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${task['user_name']}",
                            style: TextStyle(
                                color: (task['manager_status'])
                                    ? Colors.blueAccent
                                    : Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            task['pending_count'].toString(),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            task['incomplete_count'].toString(),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            task['complete_count'].toString(),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
