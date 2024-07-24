import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List data = [];
  List<String> monthcurr = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  @override
  void initState() {
    // TODO: implement initState
    _fetchNotifications();

    super.initState();
  }





  void showLoadingDialog(){

    showDialog(context: context, builder: (context){
      return Center(child: CircularProgressIndicator(backgroundColor: Colors.transparent,color: Colors.blueAccent,),);
     
      
    });

  }

  Future<void> _fetchNotifications() async {


    SharedPreferences pref = await SharedPreferences.getInstance();
    showLoadingDialog();
    try {
      final response = await http.post(
          Uri.parse(
              "https://portalwiz.net/laravelapi/public/api/fetch_user_notifications"),
          body: {"user_id": "${pref.getInt('user_id').toString()}"});

      if (response.statusCode == 200) {
        // Process your notification data

        for (Map<String, dynamic> i in jsonDecode(response.body)) {
          data.add(i);
          print(data.length);
        }
        setState(() {
          data;
        });
        Navigator.pop(context);
      } else {
        // Handle the error
        print('Failed to load notifications');
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle any exceptions
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Notification',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            return NotificationCard(
                date: (data[index]["created_date"].split("-"))[2],
                month: monthcurr[
                    int.parse((data[index]["created_date"].split("-"))[1])],
                title: data[index]["project_name"],
                description: data[index]["notification_assign"]);
          },
          itemCount: data.length,
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String date;
  final String month;
  final String title;
  final String description;

  NotificationCard({
    required this.date,
    required this.month,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    date,
                    style: GoogleFonts.lora(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    month,
                    style: GoogleFonts.lora(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
