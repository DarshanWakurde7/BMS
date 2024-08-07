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

  final List<String> _employees = ['Employee 1', 'Employee 2', 'Employee 3'];
  final List<String> _leaveTypes = [
    'Sick Leave',
    'Casual Leave',
    'Elective Leave'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Credit/Debit Leave'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedEmployee,
              hint: Text('Select Employee'),
              items: _employees.map((String employee) {
                return DropdownMenuItem<String>(
                  value: employee,
                  child: Text(employee),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEmployee = newValue;
                  _fetchLeaveBalance(newValue);
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLeaveType,
              hint: Text('Select Leave Type'),
              items: _leaveTypes.map((String leaveType) {
                return DropdownMenuItem<String>(
                  value: leaveType,
                  child: Text(leaveType),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLeaveType = newValue;
                });
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

  void _fetchLeaveBalance(String? employee) {
    // Simulating an API call to fetch leave balance for the selected employee
    // Replace this with actual API call
    setState(() {
      _leaveBalance = 10; // Example balance
    });
  }

  void _creditLeave() {
    if (_selectedEmployee != null &&
        _selectedLeaveType != null &&
        _leaveCount > 0) {
      print('Employee: $_selectedEmployee');
      print('Leave Type: _selectedLeaveType');
      print('Leave Count: $_leaveCount');

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }
}
