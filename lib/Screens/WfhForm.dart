import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
// Import your api_calls.dart file

class WorkFromHomeForm extends StatefulWidget {
  @override
  _WorkFromHomeFormState createState() => _WorkFromHomeFormState();
}

class _WorkFromHomeFormState extends State<WorkFromHomeForm> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  DateTime _returnDate = DateTime.now();
  String _reason = '';

  void _submitWorkFromHomeRequest() async {
    final noOfDays = _toDate.difference(_fromDate).inDays + 1;
    await ApiCalls.addWFH(
      accountId: "1",
      employeeId: 1,
      noOfDays: noOfDays,
      reason: _reason,
      dateFrom: '${_fromDate.year}-${_fromDate.month}-${_fromDate.day}',
      dateTo: '${_toDate.year}-${_toDate.month}-${_toDate.day}',
      returnToOffice:
          '${_returnDate.year}-${_returnDate.month}-${_returnDate.day}',
      createdBy: 1,
    );

    // Show a snackbar to indicate the request has been submitted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Work from home request submitted'),
        backgroundColor: Colors.green,
      ),
    );
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
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16.0),
                    Text(
                      'Date:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text('From'),
                            subtitle: Text(
                              '${_fromDate.year}-${_fromDate.month}-${_fromDate.day}',
                            ),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _fromDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null && picked != _fromDate)
                                setState(() {
                                  _fromDate = picked;
                                });
                            },
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: ListTile(
                            title: Text('To'),
                            subtitle: Text(
                              '${_toDate.year}-${_toDate.month}-${_toDate.day}',
                            ),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _toDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null && picked != _toDate)
                                setState(() {
                                  _toDate = picked;
                                });
                            },
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
                    ListTile(
                      title: Text(
                        '${_returnDate.year}-${_returnDate.month}-${_returnDate.day}',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _returnDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != _returnDate)
                          setState(() {
                            _returnDate = picked;
                          });
                      },
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Reason:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
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
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitWorkFromHomeRequest,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 15.0),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
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
