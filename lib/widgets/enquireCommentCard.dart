import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnquireComment extends StatelessWidget {
  EnquireComment({
    super.key,
    required this.name,
    required this.date,
    required this.comment,
    required this.nextfollupdate,
    required this.status,
    required this.profile,
  });

  String name, date, comment, nextfollupdate, status, profile;

  String formatdate(String datetime) {
    try {
      DateTime dateTime = DateTime.parse(datetime);
      // Format the date and time using intl package
      String formattedDateTime = DateFormat.yMd().add_Hms().format(dateTime);
      return formattedDateTime;
    } catch (e) {
      // Return the original datetime string in case of an error
      return datetime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      elevation: 3,
      color: Colors.white,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent.shade100,
                    radius: 14,
                    child: Text("${name[0]}"),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "$name on ${formatdate(date)}",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 5, 10),
                child: Text(
                  comment,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(35, 3, 5, 3),
                child: Row(
                  children: [
                    Text(
                      "Next Followup: ",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      nextfollupdate == "0000-00-00"
                          ? "N/A"
                          : formatdate(nextfollupdate).split(" ")[0],
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(35, 3, 5, 3),
                child: Row(
                  children: [
                    Text(
                      "Status: ",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      status,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
