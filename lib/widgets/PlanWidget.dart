import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/Pmsheet.dart';
import 'package:bms/Screens/PopUpFroCopydailyPLan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PLanCardWidget extends StatefulWidget {
  PLanCardWidget({
    super.key,
    required this.planid,
    required this.planDate,
    required this.planName,
    required this.achivments,
    required this.comment,
    required this.userid,
    required this.teamId,
    required this.Status,
    required this.roleid,
    required this.callback,
    required this.teamsList,
  });
  final int planid;
  final String planName;
  String? username;
  final String? achivments;
  final String? comment;
  final int userid;
  final int teamId;
  final String planDate;
  final int Status;
  final int roleid;
  final Function callback;
  final List<dynamic> teamsList;
  @override
  State<PLanCardWidget> createState() => _PLanCardWidgetState();
}

class _PLanCardWidgetState extends State<PLanCardWidget> {
  var achievementss = TextEditingController();
  var comments = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("${widget.planid}"),
      background: Container(
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.grey),
        alignment: Alignment.centerRight,
      ),
      direction: DismissDirection.endToStart,
      child: Card(
        margin: EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color:
                  (widget.Status == 0) ? Colors.redAccent : Colors.greenAccent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        widget.teamsList.firstWhere(
                            (e) => e["team_id"] == widget.planid)["team_name"],
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    Visibility(
                      visible: (widget.Status == 1),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0, top: 5),
                        child: Icon(
                          Icons.verified_sharp,
                          size: 24,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "${widget.username}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Visibility(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 0.0),
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (cocontext) {
                            return Dialog(
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return ProjectManagerPopup(
                                    planid: widget.planid,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        child: Icon(
                          Icons.copy,
                          size: 20,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Divider(
                  color: const Color.fromARGB(255, 203, 203, 203),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(11)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        widget.planName,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Divider(
                  color: const Color.fromARGB(255, 203, 203, 203),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text("Achievements",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600)),
                  ),
                  Visibility(
                      visible: (widget.achivments == null ||
                          (widget.achivments ?? "").isEmpty),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Add Achievements",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 20),
                                          child: TextField(
                                            controller: achievementss,
                                            maxLines: 5,
                                            decoration: InputDecoration(
                                              hintText: "Write here...",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              updateplan(
                                                widget.planid,
                                                widget.planDate,
                                                widget.planName,
                                                achievementss.text,
                                                widget.comment ?? comments.text,
                                                widget.userid ?? 0,
                                                widget.teamId ?? 0,
                                                widget.Status ?? 0,
                                              );
                                            },
                                            child: Text(
                                              "Add Achievements",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ))
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Icon(Icons.add, color: Colors.blueAccent),
                      ))
                ],
              ),
              Visibility(
                visible: !(widget.achivments.isNull),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(11)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.achivments ?? " ......",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Divider(
                  color: const Color.fromARGB(255, 203, 203, 203),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      child: Text("Comments:",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                    ),
                    (widget.comment == null || widget.comment!.isEmpty)
                        ? GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Add Comment",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 20),
                                              child: TextField(
                                                controller: comments,
                                                maxLines: 5,
                                                decoration: InputDecoration(
                                                  hintText: "Write here...",
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15))),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  updateplan(
                                                    widget.planid,
                                                    widget.planDate,
                                                    widget.planName,
                                                    achievementss.text,
                                                    widget.comment ??
                                                        comments.text,
                                                    widget.userid ?? 0,
                                                    widget.teamId ?? 0,
                                                    widget.Status ?? 0,
                                                  );
                                                },
                                                child: Text(
                                                  "Add Comment",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Icon(Icons.add, color: Colors.blueAccent),
                          )
                        : Expanded(child: Text("${widget.comment}")),
                  ],
                ),
              ),
              Visibility(
                visible: (widget.roleid == 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(
                    color: const Color.fromARGB(255, 203, 203, 203),
                  ),
                ),
              ),
              Visibility(
                visible: (widget.roleid == 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, bottom: 5),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectManagerSheet(
                                  seletDate: DateTime.now(),
                                  planid: widget.planid,
                                  updateList: () => widget.callback,
                                ),
                              ));
                        },
                        child: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                      ),
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

  void updateplan(int i, String date, String plan_name, String achievements,
      String commentss, int user_id, int team_id, int status) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final requestBody = {
      "user_id": "${user_id}",
      "plan_name": "${plan_name}",
      "achievements": "${achievements}",
      "comments": "${commentss}",
      "plan_id": "${i}",
      "plan_date": "${date}",
      "updated_by": "${sharedPreferences.getInt("user_id")}",
      "team_id": "${team_id}",
      "status": "${status}",
    };
    print(requestBody);

    try {
      bool success = await ApiCalls.updateDailyPlan(requestBody);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully.')),
        );

        Navigator.pop(context);
        achievementss.clear();
        comments.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update data.')),
        );
      }
      print(success);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data: $e')),
      );
    }
  }
}
