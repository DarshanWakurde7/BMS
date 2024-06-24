import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import 'package:bms/Screens/LeaveForm.dart';
import 'package:bms/Screens/WfhForm.dart';
import 'package:bms/Screens/AttendenceReport.dart';

class LeaveTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Leave Tracker', style: GoogleFonts.lato()),
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) {
                // Handle filter selection
                print('Selected: $value');
                // Implement your filtering logic here
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'Casual Leaves',
                    child: Text('Casual Leaves'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Sick Leaves',
                    child: Text('Sick Leaves'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Elective Leaves',
                    child: Text('Elective Leaves'),
                  ),
                  PopupMenuItem<String>(
                    value: 'WFH Requests',
                    child: Text('WFH Requests'),
                  ),
                ];
              },
              icon: Icon(Icons.filter_list),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Leave'),
              Tab(text: 'WFH'),
              Tab(text: 'Holidays'),
              Tab(text: 'Attendance Report'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LeaveSection(),
            WorkFromHomeForm(),
            HolidayCalendarSection(),
            AttendanceScreen(),
          ],
        ),
      ),
    );
  }
}

class LeaveSection extends StatefulWidget {
  @override
  _LeaveSectionState createState() => _LeaveSectionState();
}

class _LeaveSectionState extends State<LeaveSection> {
  late Future<Map<String, dynamic>> futureCasualLeaves;
  late Future<Map<String, dynamic>> futureSickLeaves;
  late Future<Map<String, dynamic>> futureElectiveLeaves;

  @override
  void initState() {
    super.initState();
    futureCasualLeaves = ApiCalls.fetchCasualLeaves();
    futureSickLeaves = ApiCalls.fetchSickLeaves();
    futureElectiveLeaves = ApiCalls.fetchElectiveLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait(
          [futureCasualLeaves, futureSickLeaves, futureElectiveLeaves]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // Return an empty SizedBox to hide the CircularProgressIndicator
        }
        if (snapshot.hasData) {
          Map<String, dynamic>? casualLeaves = snapshot.data![0];
          Map<String, dynamic>? sickLeaves = snapshot.data![1];
          Map<String, dynamic>? electiveLeaves = snapshot.data![2];
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 150.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      LeaveCard(
                        title: 'Casual Leaves',
                        balancedLeaves: int.tryParse(
                                casualLeaves!['balanced_casual_leaves']
                                    .toString()
                                    .split('.')[0]) ??
                            0,
                        bookedLeaves: int.tryParse(
                                casualLeaves['booked_casual_leaves']
                                    .toString()
                                    .split('.')[0]) ??
                            0,
                      ),
                      LeaveCard(
                        title: 'Sick Leaves',
                        balancedLeaves: int.tryParse(
                                sickLeaves!['balanced_sick_leaves']
                                    .toString()
                                    .split('.')[0]) ??
                            0,
                        bookedLeaves: int.tryParse(
                                sickLeaves['booked_casual_leaves']
                                    .toString()
                                    .split('.')[0]) ??
                            0,
                      ),
                      LeaveCard(
                        title: 'Elective Leaves',
                        balancedLeaves: int.tryParse(
                                electiveLeaves!['balanced_elective_leaves']
                                    .toString()
                                    .split('.')[0]) ??
                            0,
                        bookedLeaves: int.tryParse(
                                electiveLeaves['booked_elective_leaves']
                                    .toString()
                                    .split('.')[0]) ??
                            0,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0),
                LeaveHistorySection(),
                SizedBox(height: 12.0),
                WfhHistorySection(),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return SizedBox();
      },
    );
  }
}

class HolidayCalendarSection extends StatelessWidget {
  final List<Holiday> holidays = [
    Holiday(name: 'Independence Day', date: '2024-08-15', day: 'Thursday'),
    Holiday(
        name: 'Raksha Bandhan',
        date: '2024-8-19',
        day: 'Monday',
        isElective: true),
    Holiday(name: 'Christmas Day', date: '2024-12-25', day: 'Wednesday'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children:
            holidays.map((holiday) => HolidayCard(holiday: holiday)).toList(),
      ),
    );
  }
}

class Holiday {
  final String name;
  final String date;
  final String day;
  final bool isElective;

  Holiday(
      {required this.name,
      required this.date,
      required this.day,
      this.isElective = false});
}

class HolidayCard extends StatelessWidget {
  final Holiday holiday;

  const HolidayCard({Key? key, required this.holiday}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String initials = '';
    holiday.name.split(' ').forEach((word) {
      initials += word[0].toUpperCase();
    });

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          width: 300.0,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  initials,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holiday.name,
                      style: GoogleFonts.lato(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0),
                    Text('Date: ${holiday.date}', style: GoogleFonts.lato()),
                    Text('Day: ${holiday.day}', style: GoogleFonts.lato()),
                  ],
                ),
              ),
              if (holiday.isElective)
                Text(
                  '(Elective)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaveCard extends StatelessWidget {
  final String title;
  final int balancedLeaves;
  final int bookedLeaves;

  const LeaveCard({
    Key? key,
    required this.title,
    required this.balancedLeaves,
    required this.bookedLeaves,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => LeaveForm()),
      //   );
      // },
      child: Container(
        width: 300,
        height: 200, // Increase the height parameter as needed
        child: Card(
          margin: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_note, color: Colors.blue),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.lato(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Balanced',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(fontSize: 16.0),
                            ),
                            Text(
                              '$balancedLeaves',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                color: Colors.green,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Booked',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(fontSize: 16.0),
                            ),
                            Text(
                              '$bookedLeaves',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                color: Colors.red,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.0),
                  Center(
                    child: SizedBox(
                      width: 100.0,
                      height: 30.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LeaveForm()),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: Text(
                          'Apply',
                          style: TextStyle(fontSize: 12.0),
                        ),
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

class LeaveHistorySection extends StatefulWidget {
  @override
  _LeaveHistorySectionState createState() => _LeaveHistorySectionState();
}

class _LeaveHistorySectionState extends State<LeaveHistorySection> {
  late Future<List<LeaveHistory>> futureLeaveHistory;

  @override
  void initState() {
    super.initState();
    futureLeaveHistory = ApiCalls.fetchSingleEmployeeLeave();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaveHistory>>(
      future: futureLeaveHistory,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<LeaveHistory>? leaveHistory = snapshot.data;
          return Column(
            children: leaveHistory!
                .map((leave) => LeaveHistoryCard(leave: leave))
                .toList(),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container();
      },
    );
  }
}

class LeaveHistory {
  final int leaveId;
  final String leaveName;
  final String dateFrom;
  final String dateTo;
  final double noOfDays;
  final String status;
  //final String comment;

  LeaveHistory({
    required this.leaveId,
    required this.leaveName,
    required this.dateFrom,
    required this.dateTo,
    required this.noOfDays,
    required this.status,
    // required this.comment,
  });

  factory LeaveHistory.fromJson(Map<String, dynamic> json) {
    return LeaveHistory(
      leaveId: json['leave_id'],
      leaveName: json['request_type'],
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      noOfDays: double.parse(json['no_of_days']),
      status: json['status'] ?? 'Pending',
      //comment: json['comment'],
    );
  }
}

class LeaveHistoryCard extends StatelessWidget {
  final LeaveHistory leave;

  const LeaveHistoryCard({Key? key, required this.leave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          width: 300.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leave.leaveName,
                style: GoogleFonts.lato(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text('Date: ${leave.dateFrom} - ${leave.dateTo}',
                  style: GoogleFonts.lato()),
              Text('Days: ${leave.noOfDays.toStringAsFixed(1)}',
                  style: GoogleFonts.lato()),
              Text(
                'Status: ${leave.status}',
                style: GoogleFonts.lato(
                  color: leave.status == 'Approved'
                      ? const Color.fromARGB(255, 76, 175, 172)
                      : const Color.fromARGB(255, 214, 122, 122),
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Text(
              //   'Reason:${leave.comment}',
              //   style: GoogleFonts.lato(),
              //   textAlign: TextAlign.justify,
              //   maxLines:
              //       3, // Set max lines to 3 or remove this line for unlimited lines
              //   overflow: TextOverflow.ellipsis,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class WfhHistorySection extends StatefulWidget {
  @override
  _WfhHistorySectionState createState() => _WfhHistorySectionState();
}

class _WfhHistorySectionState extends State<WfhHistorySection> {
  late Future<List<WfhHistory>> futureWfhHistory;

  @override
  void initState() {
    super.initState();
    futureWfhHistory = ApiCalls.fetchSingleEmployeeWFH();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WfhHistory>>(
      future: futureWfhHistory,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<WfhHistory>? wfhHistory = snapshot.data;
          return Column(
            children:
                wfhHistory!.map((wfh) => WfhHistoryCard(wfh: wfh)).toList(),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class WfhHistory {
  final int wfhId;
  final double noOfDays;
  final String dateFrom;
  final String dateTo;
  final int wfhStatus;
  final String? comment;
  final String createdAt;
  final String status;

  WfhHistory({
    required this.wfhId,
    required this.noOfDays,
    required this.dateFrom,
    required this.dateTo,
    required this.wfhStatus,
    required this.comment,
    required this.createdAt,
    required this.status,
  });

  factory WfhHistory.fromJson(Map<String, dynamic> json) {
    return WfhHistory(
      wfhId: json['wfh_id'],
      noOfDays: double.parse(json['no_of_days']),
      dateFrom: json['date_from'],
      dateTo: json['date_to'],
      wfhStatus: json['wfh_status'],
      comment: json['comment'],
      createdAt: json['created_at'],
      status: json['status'] ?? 'Pending',
    );
  }
}

class WfhHistoryCard extends StatelessWidget {
  final WfhHistory wfh;

  const WfhHistoryCard({Key? key, required this.wfh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          width: 300.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WFH Request',
                style: GoogleFonts.lato(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text('Date: ${wfh.dateFrom} - ${wfh.dateTo}',
                  style: GoogleFonts.lato()),
              Text('Days: ${wfh.noOfDays.toStringAsFixed(1)}',
                  style: GoogleFonts.lato()),
              Text(
                'Reason:${wfh.comment}',
                style: GoogleFonts.lato(),
                textAlign: TextAlign.justify,
                maxLines:
                    3, // Set max lines to 3 or remove this line for unlimited lines
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Status: ${wfh.status}',
                style: GoogleFonts.lato(
                  color: wfh.status == 'Approved'
                      ? const Color.fromARGB(255, 76, 175, 172)
                      : const Color.fromARGB(255, 214, 122, 122),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
