import 'dart:async';

import 'dart:convert';
import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bms/widgets/CustormSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/controller/commentController.dart';
import 'package:bms/pojos/models/enquireComment.dart';
import 'package:bms/widgets/enquireCommentCard.dart';

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
    required this.data,
  });

  final String Name, type, created, appointment, require, email, dropval;
  final int id;
  final int phone, whatsapp;
  final List<String> data;
  final Function func;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _currentPosition = 0;
  double _totalDuration = 0;
  Timer? _timer;
  bool _isRecording = false;
  final AudioRecorder _recorder = AudioRecorder();
  CommentEnquiredata commentController = Get.put(CommentEnquiredata());
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _attachments = [];
  String? _filePath;
  bool isRecordingPaused = false;
  ValueNotifier<int> _secondsElapsedNotifier = ValueNotifier<int>(0);
  String lat = "";
  String longi = "";
  var title = TextEditingController();
  var discription = TextEditingController();

  // static String baseurl="https://pw-bms-dev.portalwiz.in/laravelapi/public/api/";
  static String baseurl = "https://portalwiz.net/laravelapi/public/api/";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchImagesforEnquire();
  }

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
                widget.type,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Created: ${widget.created}",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.22),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.blueAccent),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.Name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Text(
                "Details: ${widget.require}",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 19),
                  SizedBox(width: 3),
                  Text(
                    "Next Appointment: ${widget.appointment}",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.green),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo_library, color: Colors.blue),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () => _pickDocument(),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (await getCurrentLocation()) {
                        setState(() {
                          isRecordingPaused = false;
                          _startTimer();
                        });

                        _startRecording();
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                // Track the recording state

                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ValueListenableBuilder<int>(
                                              valueListenable:
                                                  _secondsElapsedNotifier,
                                              builder: (context, value, child) {
                                                return Text(
                                                    _formatDuration(value));
                                              },
                                            ),
                                            SizedBox(width: 25),
                                            Container(
                                              height: 45,
                                              width: 45,
                                              child: LottieBuilder.network(
                                                "https://lottie.host/307ba84b-15d1-4db7-a757-8a04c4d5d7c1/wwzT5eluFl.json",
                                                reverse:
                                                    !isRecordingPaused, // Reverse if paused
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () async {
                                              await _recorder.pause();
                                              await _recorder.cancel();
                                              setState(() {
                                                _recorder;

                                                Navigator.pop(context);
                                                _stopRecording(false);
                                                _timer!.cancel();
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isRecordingPaused
                                                  ? Icons.play_arrow
                                                  : Icons.pause,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (isRecordingPaused) {
                                                  _resumeRecording(); // Resume recording
                                                  _startTimer(); // Restart the timer
                                                  setState(() {
                                                    isRecordingPaused = false;
                                                  });
                                                } else {
                                                  _pauseRecording(); // Pause recording
                                                  _timer
                                                      ?.cancel(); // Stop the timer
                                                  setState(() {
                                                    isRecordingPaused = true;
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _timer?.cancel();
                                                _secondsElapsedNotifier =
                                                    ValueNotifier(0);
                                              });
                                              _stopRecording(true);
                                              Navigator.of(context)
                                                  .pop(); // Close the bottom sheet
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: Colors.green,
                                              child: Icon(Icons.send),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                        _stopRecording(false);
                      } else {
                        showCustomSnackBar(
                            context, "Please Turn your location ON !");
                      }
                    },
                    icon: Icon(Icons.mic, color: Colors.blueAccent),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) async {
                      SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      switch (value) {
                        case 'whatsapp':
                          var androidUrl =
                              "whatsapp://send?phone=+91${widget.phone}&text=Hi";
                          if (await canLaunchUrl(Uri.parse(androidUrl))) {
                            await launchUrl(Uri.parse(androidUrl),
                                mode: LaunchMode.externalApplication);
                          }
                          String response = await ApiCalls.postEnquireCOmments(
                              "0",
                              widget.id.toString(),
                              "",
                              "",
                              "",
                              "The customer is texted via WhatsApp",
                              (sharedPreferences.getInt("user_id")).toString(),
                              (sharedPreferences.getInt("account_id"))
                                  .toString());
                          Get.showSnackbar(GetSnackBar(title: response));
                          break;
                        case 'call':
                          var dialNumber = "tel:${widget.phone}";
                          if (await canLaunch(dialNumber)) {
                            await launchUrl(Uri.parse(dialNumber),
                                mode: LaunchMode.externalApplication);
                          }
                          String response = await ApiCalls.postEnquireCOmments(
                              "0",
                              widget.id.toString(),
                              "",
                              "",
                              "",
                              "Call has been placed to customer",
                              (sharedPreferences.getInt("user_id")).toString(),
                              (sharedPreferences.getInt("account_id"))
                                  .toString());
                          break;
                        case 'email':
                          var email = 'mailto:${widget.email}';
                          if (await canLaunch(email)) {
                            await launchUrl(Uri.parse(email),
                                mode: LaunchMode.externalApplication);
                          }
                          String response = await ApiCalls.postEnquireCOmments(
                              "0",
                              widget.id.toString(),
                              "",
                              "",
                              "",
                              "Mail sent to customer",
                              (sharedPreferences.getInt("user_id")).toString(),
                              (sharedPreferences.getInt("account_id"))
                                  .toString());
                          break;
                        case 'comments':
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
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      } else if (!commentController
                                              .isLoading.value &&
                                          commentController
                                              .commentsdata.isEmpty) {
                                        return Center(
                                          child: Card(
                                            color: Colors.white,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "No comments available!",
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
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: commentController
                                                    .commentsdata.length,
                                                itemBuilder: (context, index) {
                                                  final comment =
                                                      commentController
                                                          .commentsdata[index];
                                                  return EnquireComment(
                                                    name:
                                                        comment.createdFname ??
                                                            "",
                                                    date:
                                                        comment.createdAt ?? "",
                                                    comment:
                                                        comment.message ?? "",
                                                    nextfollupdate:
                                                        comment.followUpDate ??
                                                            "",
                                                    status:
                                                        comment.commentStatus ??
                                                            "No status",
                                                    profile: comment
                                                            .profilePath ??
                                                        "profilepicture/G1SMGwzAvl1eYTZhsh7YfqVFMD9m0ElikUIIQGGy.webp",
                                                  );
                                                },
                                              ),
                                            ),
                                            if (_attachments.isNotEmpty)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Attachments:",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Wrap(
                                                      spacing: 8.0,
                                                      runSpacing: 4.0,
                                                      children: _attachments
                                                          .map((attachment) {
                                                        return GestureDetector(
                                                          onTap: () async {
                                                            var url =
                                                                "https://portalwiz.net/laravelapi/storage/app/${attachment['path']}";

                                                            if (attachment[
                                                                    'type'] ==
                                                                2) {
                                                              if (await canLaunch(
                                                                  url)) {
                                                                await launch(
                                                                    url);
                                                              } else {
                                                                throw 'Could not launch $url';
                                                              }
                                                            } else if (attachment[
                                                                    'type'] ==
                                                                1) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Dialog(
                                                                    child: Image
                                                                        .network(
                                                                            url),
                                                                  );
                                                                },
                                                              );
                                                            } else if (attachment[
                                                                    'type'] ==
                                                                3) {
                                                              // Your custom action for type == 3
                                                              setSongData(
                                                                  "https://portalwiz.net/laravelapi/storage/app/" +
                                                                      attachment[
                                                                          'path']);
                                                              showModalBottomSheet(
                                                                isDismissible:
                                                                    isRecordingPaused,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return StatefulBuilder(builder: (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setModalState) {
                                                                    return Container(
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.2,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10.0),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[900],
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(20.0),
                                                                          topRight:
                                                                              Radius.circular(20.0),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            "Attachment Name",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 18.0,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          Spacer(),
                                                                          StreamBuilder<
                                                                              Duration>(
                                                                            stream:
                                                                                _audioPlayer.positionStream,
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              final position = snapshot.data ?? Duration.zero;
                                                                              return ProgressBar(
                                                                                progress: position,
                                                                                total: _duration,
                                                                                onSeek: (duration) {
                                                                                  _audioPlayer.seek(duration);
                                                                                  setModalState(() {}); // Update UI on seek
                                                                                },
                                                                                progressBarColor: Colors.blue,
                                                                                baseBarColor: Colors.white,
                                                                                thumbColor: Colors.blueAccent,
                                                                                timeLabelTextStyle: TextStyle(
                                                                                  color: Colors.white,
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                          Spacer(),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              IconButton(
                                                                                icon: Icon(
                                                                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                                                                  color: Colors.white,
                                                                                  size: 40.0,
                                                                                ),
                                                                                onPressed: () {
                                                                                  _togglePlayPause();
                                                                                  setModalState(() {}); // Update UI on play/pause
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  });
                                                                },
                                                              );
                                                              // You can add more functionality here if needed
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 80,
                                                            height: 80,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: attachment[
                                                                        'type'] ==
                                                                    1
                                                                ? Image.network(
                                                                    "https://portalwiz.net/laravelapi/storage/app/${attachment['path']}",
                                                                    fit: BoxFit
                                                                        .cover)
                                                                : attachment['type'] ==
                                                                        2
                                                                    ? Icon(
                                                                        Icons
                                                                            .picture_as_pdf,
                                                                        size:
                                                                            50,
                                                                        color: Colors
                                                                            .red)
                                                                    : Icon(
                                                                        Icons
                                                                            .music_note,
                                                                        size:
                                                                            50,
                                                                        color: Colors
                                                                            .blue), // Icon for type == 3
                                                          ),
                                                        );
                                                      }).toList(),

                                                      // children: _attachments.map((attachment) {
                                                      //   return GestureDetector(
                                                      //     onTap: () async {
                                                      //       if (attachment['type'] == 2) {
                                                      //         var url = "https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}";
                                                      //         if (await canLaunch(url)) {
                                                      //           await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                                      //         }
                                                      //       } else if (attachment['type'] == 1) {
                                                      //         var url = "https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}";
                                                      //         showDialog(
                                                      //           context: context,
                                                      //           builder: (context) {
                                                      //             return Dialog(
                                                      //               child: Image.network(url),
                                                      //             );
                                                      //           },
                                                      //         );
                                                      //       }
                                                      //       else if(attachment['type']==3){}
                                                      //     },
                                                      //     child: Container(
                                                      //       width: 80,
                                                      //       height: 80,
                                                      //       decoration: BoxDecoration(
                                                      //         border: Border.all(color: Colors.grey),
                                                      //         borderRadius: BorderRadius.circular(5),
                                                      //       ),
                                                      //       child: attachment['type'] == 1
                                                      //           ? Image.network("https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}", fit: BoxFit.cover)
                                                      //           : Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                                                      //     ),
                                                      //   );
                                                      // }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        );
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'whatsapp',
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundImage:
                                  AssetImage("asset/image/image.png"),
                            ),
                            SizedBox(width: 8),
                            Text('WhatsApp')
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'call',
                        child: Row(
                          children: [
                            Icon(Icons.phone, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text('Call')
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'email',
                        child: Row(
                          children: [
                            Icon(Icons.email, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text('Email')
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'comments',
                        child: Row(
                          children: [
                            Icon(Icons.comment, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('Comments')
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_attachments.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Attachments:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _attachments.map((attachment) {
                          return GestureDetector(
                            onTap: () async {
                              if (attachment['type'] == 2) {
                                if (await canLaunch(
                                    "https://portalwiz.net/laravelapi/storage/app/${attachment['path']}")) {
                                  await launchUrl(
                                      Uri.parse(
                                          "https://portalwiz.net/laravelapi/storage/app/${attachment['path']}"),
                                      mode: LaunchMode.externalApplication);
                                }
                              } else if (attachment['type'] == 1) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: Image.network(
                                          "https://portalwiz.net/laravelapi/storage/app/" +
                                              attachment["path"]),
                                    );
                                  },
                                );
                              } else if (attachment['type'] == 3) {
                                // Your custom action for type == 3

                                setSongData(
                                    "https://portalwiz.net/laravelapi/storage/app/" +
                                        attachment["path"]);
                                showModalBottomSheet(
                                  isDismissible: isRecordingPaused,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setModalState) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              attachment["path"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            StreamBuilder<Duration>(
                                              stream:
                                                  _audioPlayer.positionStream,
                                              builder: (context, snapshot) {
                                                final position =
                                                    snapshot.data ??
                                                        Duration.zero;
                                                return ProgressBar(
                                                  progress: position,
                                                  total: _duration,
                                                  onSeek: (duration) {
                                                    _audioPlayer.seek(duration);
                                                    setModalState(
                                                        () {}); // Update UI on seek
                                                  },
                                                  progressBarColor: Colors.blue,
                                                  baseBarColor: Colors.white,
                                                  thumbColor: Colors.blueAccent,
                                                  timeLabelTextStyle: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                            ),
                                            Spacer(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    _isPlaying
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 40.0,
                                                  ),
                                                  onPressed: () {
                                                    _togglePlayPause();
                                                    setModalState(
                                                        () {}); // Update UI on play/pause
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  },
                                );

                                // You can add more functionality here if needed
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: attachment['type'] == 1
                                  ? Image.network(
                                      "https://portalwiz.net/laravelapi/storage/app/" +
                                          attachment["path"],
                                      fit: BoxFit.cover)
                                  : attachment['type'] == 2
                                      ? Icon(Icons.picture_as_pdf,
                                          size: 50, color: Colors.red)
                                      : Icon(Icons.music_note,
                                          size: 50,
                                          color: Colors
                                              .blue), // Icon for type == 3
                            ),
                          );
                        }).toList(),
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

  Future<void> _startRecording() async {
    final bool isPermissionGranted = await _recorder.hasPermission();
    if (!isPermissionGranted) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    // Generate a unique file name using the current timestamp
    String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _filePath = '${directory.path}/$fileName';

    // Define the configuration for the recording
    const config = RecordConfig(
      // Specify the format, encoder, sample rate, etc., as needed
      encoder: AudioEncoder.aacLc, // For example, using AAC codec
      sampleRate: 44100, // Sample rate
      bitRate: 128000, // Bit rate
    );

    // Start recording to file with the specified configuration
    await _recorder.start(config, path: _filePath!);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording(bool send) async {
    final path = await _recorder.stop();
    print(path);
    if (send) {
      print("okk");
      showDialogDisCription(
        File(path!),
        3,
      );
    } else {
      Fluttertoast.showToast(
          msg: 'Recording Stopped an not posted',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent.withOpacity(0.5),
          textColor: Colors.black,
          fontSize: 16.0);
    }

    setState(() {
      _isRecording = false;
      _secondsElapsedNotifier = ValueNotifier<int>(0);
      _timer!.cancel();
    });
  }

  void _resumeRecording() async {
    print("okkk1");
    await _recorder.resume();
    setState(() {
      _recorder;
    });
  }

  void _pauseRecording() async {
    print("okk2");
    await _recorder.pause();
    setState(() {
      _recorder;
    });
  }

  String _formatDuration(int seconds) {
    print(seconds);
    final minutes = seconds ~/ 60;
    final secondsRemaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secondsRemaining.toString().padLeft(2, '0')}';
  }

  Future<void> uploadFile(File file, int docType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final uri = Uri.parse("${baseurl}add_enq_docs");
    var formData = http.MultipartRequest('POST', uri);
    formData.fields.addAll({
      "created_by": sharedPreferences.getInt("user_id").toString(),
      "enquiry_id": "${widget.id}",
      "doc_type": "${docType}",
      "link": "",
      "latitude": lat,
      "longitude": longi,
      "doc_name": "${title.text}",
      "description": "${discription.text}",
    });
    formData.files.add(await http.MultipartFile.fromPath(
      'doc_path',
      file.path,
    ));
    var response = await formData.send();

    if (response.statusCode == 200) {
      //  showCustomSnackBar(context, await response.stream.bytesToString());
      print('File uploaded successfully.');
      await fetchImagesforEnquire();
    } else {
      print(await response.stream.bytesToString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          jsonDecode(await response.stream.bytesToString())["message"],
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
        ),
        backgroundColor: Color.fromARGB(0, 160, 160, 160),
      ));
      print('Failed to upload file. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchImagesforEnquire() async {
    final response = await http.post(
      Uri.parse("${baseurl}fetch_enq_docs"),
      body: {"enquiry_id": "${widget.id}"},
    );
// showCustomSnackBar(context, response.body);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      setState(() {
        _attachments.clear();
        for (var doc in data) {
          print(doc);
          _attachments.add({
            'path': doc['doc_path'],
            'type': doc['doc_type'],
            "doc_name": doc["doc_name"],
            "description": doc["description"]
          });
        }
      });
    } else {
      print('Failed to fetch documents. Status code: ${response.statusCode}');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      print("okkkkk");

      if (await getCurrentLocation()) {
        showDialogDisCription(File(pickedFile.path), 1);
      } else {
        showCustomSnackBar(context, "Please Turn your location ON !");
      }
    }
  }

  void setSongData(String data) async {
    try {
      print(data);
      // Set the audio URL
      final duration = await _audioPlayer.setUrl(data);
      setState(() {
        _duration = duration ?? Duration.zero;
      });

      // Listen to position stream and update UI
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });

      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
        });
      });
    } catch (e) {
      // Handle any errors that occur
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
    });
  }

  void showCustomSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: CustomSnackBar(message: message),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void showDialogDisCription(File pickedFile, int type) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 5),
                    child: Text(
                      "Add Title",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 0),
                    child: TextField(
                      controller: title,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 5),
                    child: Text(
                      "Add Discription",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 0),
                    child: TextField(
                      controller: discription,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                        onPressed: () async {
                          await uploadFile(File(pickedFile.path), type);

                          await fetchImagesforEnquire();
                          title.clear();
                          discription.clear();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Attach",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                        )),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      if (await getCurrentLocation()) {
        showDialogDisCription(file, 2);
      } else {
        showCustomSnackBar(context, "Please Turn your location ON !");
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsedNotifier.value++;
        ;
      });
    });
  }

  getCommentsData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    commentController.getEnquireComments(
        sharedPreferences.getInt("account_id") ?? 0, widget.id);
  }

  Future<bool> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lat = "${position.latitude}";
      longi = "${position.longitude}";
    });

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    print(
        'Current Location: ${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}');
    return true;
  }
}
