import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectManagerSheet extends StatefulWidget {
  const ProjectManagerSheet({required this.planid});
  final int? planid;

  @override
  _ProjectManagerSheetState createState() => _ProjectManagerSheetState();
}

class _ProjectManagerSheetState extends State<ProjectManagerSheet> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedEmployee;
  TextEditingController _entryController = TextEditingController();
  bool _isPlanCompleted = false;
List<dynamic> _employeeList = [];
  List<dynamic> _teamsList = [];
  int? _selectedTeam;

  @override
  void initState() {
    super.initState();
    fetchTeams();
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
          Uri.parse('https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_signal_daily_plan'),
          body: {"plan_id": "${widget.planid}"},
        );
        print(response.body);

        if (response.statusCode == 200) {
          final List<dynamic> responseData = jsonDecode(response.body);
          if (responseData.isNotEmpty) {
            final data = responseData[0];
            bool functionData = await fetchTeamEmployees(data['team_id']);

            setState(() {
              _selectedDate = data['plan_date'] != null ? DateTime.parse(data['plan_date']) : DateTime.now();
              _entryController.text = data['plan_name'] ?? "";
              _isPlanCompleted = data['status'] == 1;
              _selectedTeam = data['team_id'];

              if (data['user_id'] != null && functionData) {
                try {
                  final selectedEmployee = _employeeList.firstWhere(
                    (employee) => employee['user_id'].toString() == data['user_id'].toString(),
                    
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
      var url = Uri.parse('https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_team_employee');

      // API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "team_id": [teamId],
          "account_id": "${prefs.getInt("account_id")}",
          "user_id":["${prefs.getInt("user_id")}"]
        }),
      );
    

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> employees = List<Map<String, dynamic>>.from(data);
        
        if (mounted) {
          setState(() {
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
          Uri.parse('https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_teams'),
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

    final selectedEmployee = _employeeList.firstWhere((employee) =>
        employee['first_name'] + ' ' + employee['last_name'] == _selectedEmployee,
      );

    if (selectedEmployee == null) {
      print('Selected employee not found');
      return;
    }

    final requestBody = {
      "user_id": selectedEmployee['user_id'].toString(),
      "plan_id": "${widget.planid}",
      "plan_name": _entryController.text,
      "plan_date": _selectedDate.toIso8601String().split('T')[0],
      "updated_by": selectedEmployee['user_id'].toString(),
      "status": _isPlanCompleted ? "1" : "0",
      "team_id": "$_selectedTeam",
    };

    try {
      bool success;
      if (widget.planid != null) {
        final updateResponse = await http.post(
          Uri.parse('https://pw-bms-dev.portalwiz.in/laravelapi/public/api/update_daily_plan'),
          body: requestBody,
        );
        success = updateResponse.statusCode == 200;
        print(updateResponse.body);
      } else {
        print(requestBody);
        success = await ApiCalls.addDailyPlan(requestBody);
      }

      if (success) {
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
                        Checkbox(
                          value: _isPlanCompleted,
                          onChanged: (bool? value) {
                            setState(() {
                              _isPlanCompleted = value ?? false;
                            });
                          },
                        ),
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
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null && pickedDate != _selectedDate)
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
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                        isDense: true,
                      ),
                      value: _selectedTeam,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedTeam = newValue;
                          if (_selectedTeam != null) {
                            fetchTeamEmployees(_selectedTeam!); // Fetch employees when team changes
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
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                        isDense: true,
                      ),
                      value: _selectedEmployee,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEmployee = newValue;
                        });
                      },
                      items: _employeeList.map<DropdownMenuItem<String>>((employee) {
                        final fullName = '${employee['first_name']} ${employee['last_name']}';
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
