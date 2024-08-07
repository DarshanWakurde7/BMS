import 'package:bms/widgets/searchable_dropdown.dart';
import 'package:flutter/material.dart';

class LeaveBalancePage extends StatefulWidget {
  @override
  _LeaveBalancePageState createState() => _LeaveBalancePageState();
}

class _LeaveBalancePageState extends State<LeaveBalancePage> {
  String? selectedEmployee;
  String? selectedLeaveType;
  int balancedLeaves = 0;
  int bookedLeaves = 0;
  Map<String, LeaveDetails> leaveDetails = {
    'Casual': LeaveDetails(balanced: 10, booked: 3),
    'Sick': LeaveDetails(balanced: 8, booked: 2),
    'Annual': LeaveDetails(balanced: 15, booked: 5),
  };

  // Dummy data for dropdowns
  final List<String> employees = ['Employee 1', 'Employee 2', 'Employee 3'];
  final List<String> leaveTypes = ['Casual', 'Sick', 'Annual'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () async {
                  final selected =
                      await showEmployeeSearchDialog(context, employees);
                  if (selected != null) {
                    setState(() {
                      selectedEmployee = selected;
                    });
                    if (selectedLeaveType != null) {
                      _fetchLeaveData();
                    }
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Select Employee',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    controller: TextEditingController(
                      text: selectedEmployee,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLeaveType,
                hint: Text('Select Leave Type'),
                items: leaveTypes.map((String leaveType) {
                  return DropdownMenuItem<String>(
                    value: leaveType,
                    child: Text(leaveType),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedLeaveType = newValue;
                    if (selectedEmployee != null) {
                      _fetchLeaveData();
                    }
                  });
                },
              ),
              SizedBox(height: 32),
              Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Balanced',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$balancedLeaves',
                            style: TextStyle(fontSize: 24, color: Colors.green),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Booked',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$bookedLeaves',
                            style: TextStyle(fontSize: 24, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: leaveDetails.entries.map((entry) {
                    final leaveType = entry.key;
                    final details = entry.value;
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$leaveType Leaves',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${details.booked} / ${details.balanced}',
                              style: TextStyle(
                                color: details.booked < details.balanced
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mock fetch leave data (simulate API call)
  void _fetchLeaveData() {
    // Simulating fetching leave data
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        balancedLeaves = leaveDetails[selectedLeaveType]?.balanced ?? 0;
        bookedLeaves = leaveDetails[selectedLeaveType]?.booked ?? 0;
      });
    });
  }
}

class LeaveDetails {
  final int balanced;
  final int booked;

  LeaveDetails({required this.balanced, required this.booked});
}

// Implement your employee search dialog as needed
Future<String?> showEmployeeSearchDialog(
    BuildContext context, List<String> employees) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SearchDialog(employees: employees);
    },
  );
}
