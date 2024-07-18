import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bms/ApiCalls/apiCalls.dart';

class LeaveForm extends StatefulWidget {
  @override
  _LeaveFormState createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  String _selectedLeaveType = 'Casual';
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  DateTime _returnDate = DateTime.now();
  String _reason = '';
  String _employeeName = '';
  List<String> _leaveTypes = ['Casual', 'Sick', 'Elective'];

  String? _filePath;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    try {
      print('File Path: $_filePath');

      await ApiCalls.addLeave(
        accountId: 1,
        employeeId: 1,
        requestTypeId: _selectedLeaveType == 'Casual'
            ? 2
            : _selectedLeaveType == 'Sick'
                ? 1
                : 3,
        noOfDays: _toDate.difference(_fromDate).inDays + 1,
        reason: _reason,
        dateFrom: _fromDate.toString().split(' ')[0],
        dateTo: _toDate.toString().split(' ')[0],
        returnToOffice: _returnDate.toString().split(' ')[0],
        createdBy: 1,
        attachment: _filePath ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit leave request: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      appBar: AppBar(
        title: Text('Leave Request'),
      ),
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
                    'Leave Type:',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _selectedLeaveType,
                    onChanged: (value) {
                      setState(() {
                        _selectedLeaveType = value!;
                      });
                    },
                    items: _leaveTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Date:',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(
                      height: 19.0), // Padding between label and date pickers
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
                              style: GoogleFonts.lato(),
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
                              style: GoogleFonts.lato(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 19.0),
                  Text(
                    'Date of Return to Office:',
                    style: GoogleFonts.lato(
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
                        style: GoogleFonts.lato(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Reason:',
                    style: GoogleFonts.lato(
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
                      hintText: 'Enter reason for leave',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.0),
                  if (_selectedLeaveType == 'Sick' &&
                      _toDate.difference(_fromDate).inDays > 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attach Medical Certificates/Supporting Documents:',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: Text('Attach Files'),
                        ),
                        SizedBox(height: 8.0),
                        if (_filePath != null)
                          Text('File Attached: $_filePath'),
                      ],
                    ),
                  SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitLeaveRequest,
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
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LeaveForm(),
  ));
}
