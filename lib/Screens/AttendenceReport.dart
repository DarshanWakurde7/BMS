import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime currentDate = DateTime.now();
  List<AttendanceRecord> attendanceRecords = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  void _previousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
      _fetchAttendanceData();
    });
  }

  void _nextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
      _fetchAttendanceData();
    });
  }

  String _formatToIST(DateTime dateTime) {
    final istTime = dateTime.add(Duration(hours: 5, minutes: 30));
    return DateFormat('hh:mm a').format(istTime);
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      int? employeeId = prefs.getInt('employee_id');

      if (employeeId == null) {
        setState(() {
          errorMessage = 'Employee ID not found';
        });
        return;
      }

      final response = await http.post(
        Uri.parse(
            'http://91.108.111.222:8000/attendance/fetch_employee_status/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'employee_id': employeeId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List<AttendanceRecord> records =
              _processAttendanceData(data['attendance']);
          setState(() {
            attendanceRecords = records;
          });
        } else {
          setState(() {
            errorMessage = data['message'];
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<AttendanceRecord> _processAttendanceData(List<dynamic> attendanceData) {
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

    Map<int, AttendanceRecord> recordsMap = {};

    for (var record in attendanceData) {
      DateTime checkInTime = DateTime.parse(record['check_in_time']);
      DateTime? checkOutTime = record['check_out_time'] != null
          ? DateTime.parse(record['check_out_time'])
          : null;

      int day = checkInTime.day;
      double totalHours = checkOutTime != null
          ? (checkOutTime.difference(checkInTime).inMinutes / 60).toDouble()
          : 0.0;

      recordsMap[day] = AttendanceRecord(
        day: DateFormat('d').format(checkInTime),
        weekday: DateFormat('EEE').format(checkInTime).toUpperCase(),
        punchIn: _formatToIST(checkInTime),
        punchOut: checkOutTime != null ? _formatToIST(checkOutTime) : '',
        totalHours: totalHours.toStringAsFixed(2) + 'h',
      );
    }

    List<AttendanceRecord> records = [];
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      final date = DateTime(currentDate.year, currentDate.month, i);
      final weekday = DateFormat('EEE').format(date).toUpperCase();
      records.add(recordsMap[i] ??
          AttendanceRecord(
            day: DateFormat('d').format(date),
            weekday: weekday,
            punchIn: '',
            punchOut: '',
            totalHours: '',
          ));
    }

    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat.yMMM().format(currentDate),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : ListView.builder(
                        itemCount: attendanceRecords.length,
                        itemBuilder: (context, index) {
                          return AttendanceCard(attendanceRecords[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class AttendanceRecord {
  final String day;
  final String weekday;
  final String punchIn;
  final String punchOut;
  final String totalHours;

  AttendanceRecord({
    required this.day,
    required this.weekday,
    required this.punchIn,
    required this.punchOut,
    required this.totalHours,
  });
}

class AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;

  AttendanceCard(this.record);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 175, 198, 233),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${record.day} ${record.weekday}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Punch In'),
                  Text(record.punchIn, style: TextStyle(fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Punch Out'),
                  Text(record.punchOut, style: TextStyle(fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Hours'),
                  Text(record.totalHours, style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
