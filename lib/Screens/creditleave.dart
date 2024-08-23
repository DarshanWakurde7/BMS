import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';

class CreditLeaveDialog extends StatefulWidget {
  @override
  _CreditLeaveDialogState createState() => _CreditLeaveDialogState();
}

class _CreditLeaveDialogState extends State<CreditLeaveDialog> {
  String? _selectedEmployee;
  String? _selectedLeaveType;
  int _leaveCount = 0;
  int _leaveBalance = 0;

  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  List<Map<String, dynamic>> _leaveTypes = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _fetchLeaveTypes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Credit/Debit Leave'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _showEmployeeDropdown(),
              child: AbsorbPointer(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select Employee',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedEmployee != null
                        ? _employees.firstWhere(
                                (e) =>
                                    e['employee_id'].toString() ==
                                    _selectedEmployee,
                                orElse: () => {
                                      'first_name': '',
                                      'last_name': ''
                                    })['first_name'] +
                            ' ' +
                            _employees.firstWhere(
                                (e) =>
                                    e['employee_id'].toString() ==
                                    _selectedEmployee,
                                orElse: () => {
                                      'first_name': '',
                                      'last_name': ''
                                    })['last_name']
                        : 'Select Employee',
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLeaveType,
              hint: Text('Select Leave Type'),
              items: _leaveTypes.map((leaveType) {
                return DropdownMenuItem<String>(
                  value: leaveType['request_type_id'].toString(),
                  child: Text(leaveType['request_type']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLeaveType = newValue;
                });
                _fetchLeaveBalanceIfNeeded(); // Fetch leave balance if both are selected
              },
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Balanced Leaves',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: '$_leaveBalance',
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_leaveCount > 0) {
                        _leaveCount--;
                      }
                    });
                  },
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$_leaveCount',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _leaveCount++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _creditLeave();
                },
                child: Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 125, 149, 207),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchLeaveTypes() async {
    try {
      List<Map<String, dynamic>> leaveTypes = await ApiCalls.fetchLeaveTypes();
      setState(() {
        _leaveTypes = leaveTypes;
      });
    } catch (e) {
      print('Failed to fetch leave types: $e');
    }
  }

  void _showEmployeeDropdown() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String query) {
                  setState(() {
                    _searchQuery = query;
                    _filterEmployees();
                  });
                },
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredEmployees.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_filteredEmployees.isEmpty) {
                      return Center(child: Text('No results found'));
                    }
                    final employee = _filteredEmployees[index];
                    return ListTile(
                      title: Text(
                          '${employee['first_name']} ${employee['last_name']}'),
                      onTap: () {
                        setState(() {
                          _selectedEmployee =
                              employee['employee_id'].toString();
                        });
                        _fetchLeaveBalanceIfNeeded(); // Fetch leave balance if both are selected
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _fetchEmployees() async {
    try {
      List<Map<String, dynamic>> employees =
          await ApiCalls.fetchEmployeesDropdown(
              '1100'); // Replace with your account ID
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
      });
    } catch (e) {
      print('Failed to fetch employees: $e');
    }
  }

  void _filterEmployees() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = _employees.where((employee) {
          final fullName = '${employee['first_name']} ${employee['last_name']}';
          final queryLowerCase = _searchQuery.toLowerCase();
          final fullNameLowerCase = fullName.toLowerCase();
          return fullNameLowerCase.contains(queryLowerCase);
        }).toList();
      }
    });
  }

  void _fetchLeaveBalanceIfNeeded() {
    if (_selectedEmployee != null && _selectedLeaveType != null) {
      _fetchLeaveBalance(_selectedEmployee);
    }
  }

  void _fetchLeaveBalance(String? employeeId) async {
    if (employeeId == null) return;

    try {
      final response = await ApiCalls.fetchLeaveBalance(
        accountId: 1100,
        employeeId: int.parse(employeeId),
        requestTypeId: int.parse(_selectedLeaveType ??
            '1'), // Defaulting to 1 if no leave type selected
      );
      setState(() {
        _leaveBalance = response['balance_leave'].toInt();
      });
    } catch (e) {
      print('Failed to fetch leave balance: $e');
    }
  }

  void _creditLeave() {
    if (_selectedEmployee != null &&
        _selectedLeaveType != null &&
        _leaveCount > 0) {
      print('Employee ID: $_selectedEmployee');
      print('Leave Type: $_selectedLeaveType');
      print('Leave Count: $_leaveCount');

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }
}
