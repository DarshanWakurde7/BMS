import 'package:flutter/material.dart';

class UpcomingLeaveRequestPage extends StatelessWidget {
  final List<Map<String, dynamic>> leaveRequests = [
    {
      'name': 'Priya Paradhi',
      'startDate': '2024 June 20',
      'endDate': '2024 June 24',
      'totalDays': '4 Days',
      'status': 'Pending',
      'note':
          "Sick Leave. I'm suffering from extreme fever and I'd not be able to come office and work for...",
      'isOverlapped': false,
      'isLongWeekend': false,
      'overlapEmployee': '',
    },
    {
      'name': 'John Doe',
      'startDate': '2024 July 1',
      'endDate': '2024 July 6',
      'totalDays': '6 Days',
      'status': 'Approved',
      'note':
          "Vacation Leave. I'm going on a vacation and will not be available.",
      'isOverlapped': true,
      'isLongWeekend': false,
      'overlapEmployee': 'John Doe',
    },
    {
      'name': 'Trupti Panse',
      'startDate': '2024 Sep 10',
      'endDate': '2024 Sep 13',
      'totalDays': '3 Days',
      'status': 'Pending',
      'note': "Medical Leave. I have a scheduled surgery and need rest.",
      'isOverlapped': false,
      'isLongWeekend': true,
      'overlapEmployee': '',
    },
    {
      'name': 'Trupti Panse',
      'startDate': '2024 Sep 10',
      'endDate': '2024 Sep 13',
      'totalDays': '3 Days',
      'status': 'Pending',
      'note': "Medical Leave. I have a scheduled surgery and need rest.",
      'isOverlapped': false,
      'isLongWeekend': true,
      'overlapEmployee': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: leaveRequests.length,
        itemBuilder: (context, index) {
          final leaveRequest = leaveRequests[index];
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
                  Row(
                    children: [
                      Text(
                        leaveRequest['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      if (leaveRequest['isOverlapped'])
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 237, 72, 72),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Overlapped Leave',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (leaveRequest['isLongWeekend'])
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Long Weekend',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Date'),
                          Text(
                            leaveRequest['startDate'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Date'),
                          Text(
                            leaveRequest['endDate'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Days'),
                          Text(
                            leaveRequest['totalDays'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Note',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    leaveRequest['note'],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UpcomingLeaveRequestPage(),
  ));
}
