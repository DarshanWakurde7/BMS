import 'dart:math';
import 'package:bms/Screens/AttendenceReport.dart';
import 'package:bms/Screens/DailyTasks.dart';
import 'package:bms/Screens/Enquire.dart';
import 'package:bms/Screens/LanderPage.dart';
import 'package:bms/Screens/LeaveRequest.dart';
import 'package:bms/Screens/LeaveTracker.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  List<Map<String, dynamic>> dashboardData = [
    {"Name": "Todays Task", "Count": 3},
    {"Name": "Open Plans", "Count": 8},
    {"Name": "Closed Plan", "Count": 5},
    {"Name": "Punch Status", "Count": 0}
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Management System'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to the Bms',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    HomeCard(
                      icon: Icons.task_sharp,
                      title: 'Tasks',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LanderPage())),
                    ),
                    HomeCard(
                      icon: Icons.person,
                      title: 'Daily Plans',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DailyTasks(
                                    title: "Daily Tasks",
                                    today: true,
                                  ))),
                    ),
                    HomeCard(
                      icon: Icons.track_changes,
                      title: 'Leave Tracker',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LeaveTracker())),
                    ),
                    HomeCard(
                      icon: Icons.people,
                      title: 'Attendance',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AttendanceReportPage())),
                    ),
                    HomeCard(
                      icon: Icons.people,
                      title: 'Enquiries',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyEnquire())),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.smart_button_outlined,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Todays Smart Views",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    color: Colors.grey.shade100,
                    elevation: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: dashboardData.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, ind) {
                            if (ind == 0) {
                              return Column(
                                children: [
                                  // Padding(
                                  //   padding: const EdgeInsets.all(10.0),
                                  //   child: Row(
                                  //     children: [
                                  //       Icon(Icons.smart_button_outlined,color: Colors.blueAccent,),
                                  //       SizedBox(width: 10,),
                                  //       Text("Smart Views",style: TextStyle(fontSize: 16,color: Colors.blueAccent,),),
                                  //     ],
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 6,
                                              backgroundColor: Colors.primaries[
                                                  Random().nextInt(
                                                      Colors.primaries.length)],
                                            ),
                                            SizedBox(width: 15),
                                            Text(
                                              "${dashboardData[ind]["Name"]}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${dashboardData[ind]["Count"]}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 6,
                                          backgroundColor: Colors.primaries[
                                              Random().nextInt(
                                                  Colors.primaries.length)],
                                        ),
                                        SizedBox(width: 15),
                                        Text(
                                          "${dashboardData[ind]["Name"]}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${dashboardData[ind]["Count"]}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  HomeCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
