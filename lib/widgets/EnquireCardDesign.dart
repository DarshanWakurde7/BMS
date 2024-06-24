import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/controller/commentController.dart';
import 'package:bms/pojos/models/enquireComment.dart';
import 'package:bms/widgets/enquireCommentCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyWidget extends StatefulWidget {
  MyWidget({
    super.key,
    required this.Name,
    required this.id,
    required this.type,
    required this.created,
    required this.appointment,
    required this.require,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.dropval,
    required this.func,
  });
  final String Name, type, created, appointment, require, email, dropval;
  final int id;
  final int phone, whatsapp;
  final List<String> data = [];
  final Function func;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  CommentEnquiredata commentController = Get.put(CommentEnquiredata());

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        margin: EdgeInsets.all(7),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 220, 239, 255)),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.type}",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Created: ${widget.created}",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.22,
                    ),
                  ],
                ),

                SizedBox(
                  height: 6,
                ),

                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Text(
                      widget.Name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    )),
                  ],
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  "Details: ${widget.require}",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),

                // Text(widget.require,style:TextStyle(fontSize: 12,fontWeight: FontWeight.w400,backgroundColor: Colors.blueAccent.shade100)),

                // Container(
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(5),
                //     border: Border.all(color: Color.fromARGB(255, 203, 222, 255))
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //          Text("Requirements:",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400),),
                //          SizedBox(height: 5,),
                //         Text(widget.require,style:TextStyle(fontSize: 12,fontWeight: FontWeight.w100)),
                //       ],
                //     ),
                //   )),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 19,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "Next Appointment:${widget.appointment}",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: Container(

                //        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                //           height: MediaQuery.of(context).size.height*0.04,
                //           width: MediaQuery.of(context).size.width*0.4,
                //              decoration: BoxDecoration(

                //             borderRadius: BorderRadius.circular(15),
                //             border: Border.all(color: Colors.black54),
                //             color: Colors.white
                //           ),
                //           child: DropdownButton<String>(
                //             underline: Text(""),
                //             isExpanded: true,
                //             borderRadius: BorderRadius.circular(25),
                //             hint: Padding(
                //               padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                //               child: Text(widget.dropval,style: TextStyle(fontSize: 16,color: Colors.grey),textAlign: TextAlign.center,)),
                //             items: widget.data.map((item)=>DropdownMenuItem<String>(
                //             value: item,
                //             child: Text(item,style: TextStyle(fontSize: 14),),
                //           )).toList(), onChanged:(item){
                //             setState(() {
                //               widget.func;
                //             });
                //             print(item);
                //           } )),
                // ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: CircleAvatar(
                          radius: 13,
                          backgroundImage: AssetImage("asset/image/image.png")),
                      onTap: () async {
                        var androidUrl =
                            "whatsapp://send?phone=+91${widget.phone}&text=Hi";
                        launchUrl(Uri.parse(androidUrl),
                            mode: LaunchMode.externalApplication);
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        String response = await ApiCalls.postEnquireCOmments(
                            "0",
                            widget.id.toString(),
                            "",
                            "",
                            "",
                            "the customer is texted via whatsapp",
                            (sharedPreferences.getInt("user_id")).toString(),
                            (sharedPreferences.getInt("account_id"))
                                .toString());
                        Get.showSnackbar(GetSnackBar(
                          title: response,
                        ));
                      },
                    ),
                    GestureDetector(
                        onTap: () async {
                          var dailnumber = "tel:${widget.phone}";
                          launchUrl(Uri.parse(dailnumber),
                              mode: LaunchMode.externalApplication);
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          String response = await ApiCalls.postEnquireCOmments(
                              "0",
                              widget.id.toString(),
                              "",
                              "",
                              "",
                              "Call has placed to customer",
                              (sharedPreferences.getInt("user_id")).toString(),
                              (sharedPreferences.getInt("account_id"))
                                  .toString());
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 13,
                          child: Icon(
                            Icons.phone,
                            color: Colors.blueAccent,
                            size: 26,
                          ),
                        )),
                    GestureDetector(
                        onTap: () async {
                          var email = 'mailto:${widget.email}';
                          launchUrl(Uri.parse(email),
                              mode: LaunchMode.externalApplication);
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          String response = await ApiCalls.postEnquireCOmments(
                              "0",
                              widget.id.toString(),
                              "",
                              "",
                              "",
                              "Mail sent to Customer",
                              (sharedPreferences.getInt("user_id")).toString(),
                              (sharedPreferences.getInt("account_id"))
                                  .toString());
                        },
                        child: Icon(
                          Icons.email_outlined,
                          color: Colors.redAccent,
                          size: 26,
                        )),
                    GestureDetector(
                        onTap: () {
                          // enquireComment=    enquireComment=await ApiCalls.getEnquireComment((sharedPreferences.getInt("account_id")).toString(),widget.id.toString());
                          getCommentsData();

                          showBottomSheet(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: StatefulBuilder(
                                      builder: (context, StateSetter setter) {
                                    return Obx(() {
                                      if (commentController.isLoading.value) {
                                        return Container(
                                          height: double.infinity,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else if ((!commentController
                                              .isLoading.value) &&
                                          (commentController
                                              .commentsdata.isEmpty)) {
                                        return Center(
                                          child: Card(
                                            color: Colors.white,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          11)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Sorry no Comments yet",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return ListView.builder(
                                            itemCount: commentController
                                                .commentsdata.length,
                                            itemBuilder: (context, index) {
                                              return EnquireComment(
                                                name: commentController
                                                        .commentsdata[index]
                                                        .createdFname ??
                                                    "",
                                                date: commentController
                                                        .commentsdata[index]
                                                        .updatedAt ??
                                                    "",
                                                comment: commentController
                                                        .commentsdata[0]
                                                        .message ??
                                                    "",
                                                nextfollupdate:
                                                    commentController
                                                            .commentsdata[0]
                                                            .followUpDate ??
                                                        "",
                                                status: "followup",
                                                profile: commentController
                                                        .commentsdata[0]
                                                        .profilePath ??
                                                    "profilepicture/G1SMGwzAvl1eYTZhsh7YfqVFMD9m0ElikUIIQGGy.webp",
                                              );
                                            });
                                      }
                                    });
                                  }),
                                );
                              });
                        },
                        child: Icon(
                          Icons.comment,
                          color: Colors.black,
                        )),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  getCommentsData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    commentController.getEnquireComments(
        sharedPreferences.getInt("account_id") ?? 0, widget.id);
  }
}
