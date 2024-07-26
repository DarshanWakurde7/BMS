import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class AttendanceReportPage extends StatefulWidget {
  @override
  _AttendanceReportPageState createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 20));
  List<Map<String, dynamic>> attendanceData = [];
  bool _isLoading = false;
  DatePickerController _dateController = DatePickerController();

  @override
  void initState() {
    super.initState();
    fetchAttendanceData(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure _dateController is attached before animating to the selected date
      if (_dateController != null) {
        _dateController.animateToDate(_selectedDate);
      }
    });
  }

  Future<void> fetchAttendanceData(DateTime date) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Map<String, dynamic>> data = await ApiCalls.fetchAttendance(date);
      setState(() {
        attendanceData = data;
      });
    } catch (e) {
      // Handle error
      print('Failed to load attendance data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDateChange(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    fetchAttendanceData(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Report'),
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            child: DatePicker(
              _startDate,
              initialSelectedDate: _selectedDate,
              selectionColor: Colors.blue,
              selectedTextColor: Colors.white,
              daysCount: 365,
              controller: _dateController, // Attach the controller here
              onDateChange: (date) {
                _onDateChange(date);
                print('Selected date: $date');
              },
            ),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: attendanceData.isEmpty
                      ? Center(
                          child: Text(
                            'No data found',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: attendanceData.length,
                          itemBuilder: (context, index) {
                            final attendance = attendanceData[index];
                            return Card(
                              color: Color.fromARGB(255, 206, 236, 255),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attendance['username'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Punch Status'),
                                            Text(
                                              attendance['punchStatus'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Punch Time'),
                                            Text(
                                              attendance['punchTime'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AttendanceReportPage(),
  ));
}
