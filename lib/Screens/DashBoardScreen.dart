import 'package:bms/Screens/AttendenceDetails.dart';
import 'package:bms/Screens/AttendenceReport.dart';
import 'package:bms/Screens/DailyTasks.dart';
import 'package:bms/Screens/LanderPage.dart';
import 'package:bms/Screens/LeaveTracker.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bussiness Management System'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
        ],
      ),
      body: Container(
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
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
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
                      title: 'Dialy Plans',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DailyTasks(
                                    title: "Daily Tasks",
                                  ))),
                    ),
                    HomeCard(
                      icon: Icons.track_changes,
                      title: 'Leave Tracking',
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
                  ],
                ),
              ),
            ],
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

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Welcome',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Resident Home'),
            onTap: () {
              Navigator.pushNamed(context, '/residentHome');
            },
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('Admin Home'),
            onTap: () {
              Navigator.pushNamed(context, '/adminHome');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Staff Home'),
            onTap: () {
              Navigator.pushNamed(context, '/staffHome');
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Assign Issue'),
            onTap: () {
              Navigator.pushNamed(context, '/assignIssue');
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Reports'),
            onTap: () {
              Navigator.pushNamed(context, '/reports');
            },
          ),
          ListTile(
            leading: Icon(Icons.create),
            title: Text('Submit Issue'),
            onTap: () {
              Navigator.pushNamed(context, '/submitIssue');
            },
          ),
        ],
      ),
    );
  }
}
