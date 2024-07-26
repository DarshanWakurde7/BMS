import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime currentDate = DateTime.now();

  void _previousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    });
  }

  List<AttendanceRecord> _generateAttendanceRecords(DateTime date) {
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    List<AttendanceRecord> records = [];

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime day = DateTime(date.year, date.month, i);
      String weekday = DateFormat('EEE').format(day).toUpperCase();

      records.add(AttendanceRecord(
        day: DateFormat('d').format(day),
        weekday: weekday,
        punchIn: '09:00 AM',
        punchOut: i % 6 == 0 ? '' : '06:00 PM', // No punch out for weekends
        totalHours: i % 6 == 0 ? '' : '9h 0m',
      ));
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    List<AttendanceRecord> attendanceRecords =
        _generateAttendanceRecords(currentDate);

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
            child: ListView.builder(
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
