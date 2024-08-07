import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkFromHomeForm extends StatefulWidget {
  @override
  _WorkFromHomeFormState createState() => _WorkFromHomeFormState();
}

class _WorkFromHomeFormState extends State<WorkFromHomeForm> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  DateTime _returnDate = DateTime.now();
  String _reason = '';
  bool _isSubmitting = false;
  Future<void> _submitWorkFromHomeRequest() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? employeeIdStr = prefs.getString('employee_id');

      if (employeeIdStr == null) {
        throw Exception(
            'Employee ID or User ID not found in SharedPreferences');
      }

      final int employeeId = int.parse(employeeIdStr);

      final noOfDays = _toDate.difference(_fromDate).inDays + 1;

      await ApiCalls.addWFH(
        accountId: "1100",
        employeeId: employeeId,
        noOfDays: noOfDays,
        reason: _reason,
        dateFrom: '${_fromDate.year}-${_fromDate.month}-${_fromDate.day}',
        dateTo: '${_toDate.year}-${_toDate.month}-${_toDate.day}',
        returnToOffice:
            '${_returnDate.year}-${_returnDate.month}-${_returnDate.day}',
        createdBy: employeeId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Work from home request submitted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error submitting work from home request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit work from home request'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blue,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: Colors.blue),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    'Date:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await _selectDate(context, _fromDate, (picked) {
                              setState(() {
                                _fromDate = picked;
                              });
                            });
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                            child: Text(
                              '${_fromDate.year}-${_fromDate.month}-${_fromDate.day}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await _selectDate(context, _toDate, (picked) {
                              setState(() {
                                _toDate = picked;
                              });
                            });
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                            child: Text(
                              '${_toDate.year}-${_toDate.month}-${_toDate.day}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Date of Return to Office:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 19.0),
                  GestureDetector(
                    onTap: () async {
                      await _selectDate(context, _returnDate, (picked) {
                        setState(() {
                          _returnDate = picked;
                        });
                      });
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Return Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      child: Text(
                        '${_returnDate.year}-${_returnDate.month}-${_returnDate.day}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Reason:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 8.0), // Padding between label and text field
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _reason = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter reason for work from home',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.0),
                  _isSubmitting
                      ? Center(child: CircularProgressIndicator())
                      : Center(
                          child: ElevatedButton(
                            onPressed: _submitWorkFromHomeRequest,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 15.0),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
