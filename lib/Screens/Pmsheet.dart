import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectManagerSheet extends StatefulWidget {
  @override
  _ProjectManagerSheetState createState() => _ProjectManagerSheetState();
}

class _ProjectManagerSheetState extends State<ProjectManagerSheet> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedEmployee;
  TextEditingController _entryController = TextEditingController();
  bool _isPlanCompleted = false;
  List<Map<String, dynamic>> _employeeList = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  void fetchEmployees() async {
    try {
      List<Map<String, dynamic>> employees =
          await ApiCalls.fetchEmployees('1100');
      setState(() {
        _employeeList = employees;
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  Future<void> addDailyPlan() async {
    if (_selectedEmployee == null || _entryController.text.isEmpty) {
      return;
    }

    final selectedEmployee = _employeeList.firstWhere((employee) =>
        employee['first_name'] + ' ' + employee['last_name'] ==
        _selectedEmployee);

    final requestBody = {
      "plan_date": _selectedDate.toIso8601String().split('T')[0],
      "user_id": selectedEmployee['user_id'].toString(),
      "user_name": _selectedEmployee,
      "plan_name": _entryController.text,
      "achievements": "",
      "comments": "",
    };

    try {
      bool success = await ApiCalls.addDailyPlan(requestBody);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data inserted successfully.')),
        );
        _entryController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to insert data.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to insert data: $e')),
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                                _selectedEmployee = newValue!;
                              });
                            },
                            items: _employeeList.map((employee) {
                              return DropdownMenuItem<String>(
                                value: employee['first_name'] +
                                    ' ' +
                                    employee['last_name'],
                                child: Text(
                                  employee['first_name'] +
                                      ' ' +
                                      employee['last_name'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
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
                      onPressed: addDailyPlan,
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
