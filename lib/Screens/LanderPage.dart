import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bms/Screens/Activepage.dart';
import 'package:bms/Screens/AddProject.dart';
import 'package:bms/Screens/AttendenceReport.dart';

import 'package:bms/Screens/DailyTasks.dart';
import 'package:bms/Screens/DashBoardScreen.dart';
import 'package:bms/Screens/Enquire.dart';
import 'package:bms/Screens/NotActive.dart';

import 'package:bms/Screens/QrCode.dart';
import 'package:bms/Screens/Snooze.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/clear.dart';
import 'package:bms/Screens/complete.dart';

import 'package:bms/Screens/hold.dart';
import 'package:bms/Screens/review.dart';
import 'package:bms/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as kit;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:bms/Screens/LeaveTracker.dart';
import 'package:bms/Screens/LeaveRequest.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:bms/Screens/PhotoAttendence.dart';
import 'package:intl/intl.dart';

List<String> fieldsNames = [
  'Not Started',
  'Active',
  'Hold',
  'Review',
  'Complete',
  'Snoozed',
  'Clear'
];

class LanderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LanderPageState();
  }
}

class LanderPageState extends State<LanderPage>
    with SingleTickerProviderStateMixin {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) {
      final displayTime =
          StopWatchTimer.getDisplayTime(value, milliSecond: false);
      // print('Display Time: $displayTime');
    },
  );

  var backColor;
  late bool light;
  bool checkLocation = false;
  String punch_Status = "";
  late String urlAnime;
  String profileUrl = "";
  Stopwatch _stopwatch = Stopwatch();
  String _elapsedTime = '';
  int roleId = 0;
  bool _isCheckingIn = true;
  bool isLoading = false;
  bool _isCheckingLocation = false;

  Future<Position> _determinePosition() async {
    setState(() {
      _isCheckingLocation = true; // Show Lottie animation
    });

    List<kit.LatLng> poligonlatslongs = [
      kit.LatLng(18.5944166, 73.7917032),
      kit.LatLng(18.5942322, 73.7928545),
      kit.LatLng(18.5941796, 73.7928305),
      kit.LatLng(18.5947532, 73.7932197),
      kit.LatLng(18.5946136, 73.7935348),
      kit.LatLng(18.5941001, 73.7934851),
      kit.LatLng(18.5939405, 73.7932565),
    ];

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Turn On Location"),
        backgroundColor: Colors.red,
      ));

      setState(() {
        _isCheckingLocation = false; // Hide Lottie animation
      });

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isCheckingLocation = false; // Hide Lottie animation
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isCheckingLocation = false; // Hide Lottie animation
      });
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final position = await Geolocator.getCurrentPosition();
    print(position.latitude);
    print(position.longitude);

    setState(() {
      checkLocation = kit.PolygonUtil.containsLocation(
          kit.LatLng(position.latitude, position.longitude),
          poligonlatslongs,
          false);
      _isCheckingLocation = false;
    });

    if (!checkLocation) {
      _showOutOfBoundsDialog();
    }

    print(checkLocation);
    return position;
  }

  void _showOutOfBoundsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Outside Premises"),
          content: Text("You are not within the designated premises."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> openscanner() async {
    try {
      final pref = await SharedPreferences.getInstance();

      Uri url = Uri.parse(
          'https://portalwiz.net/laravelapi/public/api/add_attendance?');
      Uri urlfetchAttendance = Uri.parse(
          "https://portalwiz.net/laravelapi/public/api/fetch_attendance?");

      var payload = {
        "account_id": pref.getInt('account_id').toString(),
        "user_id": pref.getInt('user_id').toString(),
        "punch_status": pref.getInt('punch_Status').toString()
      };

      var payloadForFetch = {
        "account_id": pref.getInt('account_id').toString(),
        "user_id": pref.getInt('user_id').toString(),
      };

      final response = await http.post(url, body: payload);

      final responseAttendence =
          await http.post(urlfetchAttendance, body: payloadForFetch);

      print(jsonDecode(responseAttendence.body)["data"]);

      var data = jsonDecode(response.body.toString());

      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              pref.getInt('punch_Status') == 1 ? "Have a Great Day" : "Bye!!"),
          backgroundColor: pref.getInt('punch_Status') == 1
              ? Colors.greenAccent
              : Colors.blueAccent,
        ));
        pref.setInt('punch_Status', pref.getInt('punch_Status') == 1 ? 0 : 1);
      }

      return {
        'punch_status': data['punch_status'],
        'time': getTime(responseAttendence)
      };
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Sorry failed to scan Try Again"),
        backgroundColor: Colors.redAccent,
      ));
      return null;
    }
  }

  String? timedata;
  String getTime(http.Response responseAttendence) {
    final data = jsonDecode(responseAttendence.body);
    final List<Map<String, dynamic>> attendanceData =
        List<Map<String, dynamic>>.from(data['data']);
    final latestAttendance = attendanceData.last;
    timedata = latestAttendance['time'];
    return latestAttendance['time'];
  }

  void getPunched() async {
    final pref = await SharedPreferences.getInstance();
    await ApiCalls.getStatus(pref.getInt('account_id') ?? 0);
    setState(() {
      roleId = pref.getInt("role_id") ?? 0;
      profileUrl = pref.getString('profile_path') ?? "";
      if (pref.getInt('punch_Status') == 1) {
        backColor = Colors.greenAccent;
        light = false;
        urlAnime = "asset/animation/Animation - 1706007149763.json";
      } else {
        backColor = Colors.redAccent;

        light = true;

        urlAnime = "asset/animation/Animation - 1706007655831.json";
      }
    });
  }

  late TabController tabController;
  @override
  void initState() {
    fetchAttendanceData();

    getPunched();
    ApiCalls.getDataofCards(1.toString(), [], [], [], [], [], [], []);
    dataOfCards;
    _determinePosition();
    tabController = TabController(length: 6, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  void termsAndCondition() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.64,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Portalwiz BMS Privacy Disclosure",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Portalwiz technologies values your privacy and transparency. To ensure the best user experience, we want to inform you of the following:",
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Background Location:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "This app utilizes background location services to accurately track employee attendance and improve operational efficiency. Rest assured, your location data is used solely for this purpose and is handled securely.",
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Email Address and Password:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "Your email address and password are collected solely for authentication purposes. They are securely stored and encrypted to safeguard your account information. By using Portalwiz BMS, you consent to the collection and processing of this data. \n\nWe are committed to protecting your privacy and maintaining the confidentiality of your information.\n\nFor more details on how we handle your data, please refer to our Privacy Policy.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.white),
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                      ),
                      onPressed: () async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setBool("privacy_Terms", true);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Agree and Continue",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> clearUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();

    await sharedPref.remove("session_id");
    await sharedPref.remove("user_id");
    await sharedPref.remove("punch_Status");
    await sharedPref.remove("account_id");
    await sharedPref.remove("role_id");
    await sharedPref.remove("user_email");
    await sharedPref.remove("username");
    await sharedPref.remove("user_full_name");
    await sharedPref.remove("account_display_name");
    await sharedPref.remove("profile_path");
    await sharedPref.remove("product_display_name");
    await sharedPref.remove("privacy Terms");
    print("cleared");
  }

  Future<Map<String, dynamic>?> fetchAttendanceData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      Uri urlfetchAttendance = Uri.parse(
          "https://portalwiz.net/laravelapi/public/api/fetch_attendance");

      var payloadForFetch = {
        "account_id": pref.getInt('account_id')?.toString() ?? '',
        "user_id": pref.getInt('user_id')?.toString() ?? '',
      };

      final responseAttendance =
          await http.post(urlfetchAttendance, body: payloadForFetch);

      if (responseAttendance.statusCode == 200) {
        var data = jsonDecode(responseAttendance.body);
        var latestRecord = data.first;
        if (data.isNotEmpty) {
          // Get the latest record (assuming the first one is the latest)

          int attendanceId = latestRecord['attendance_id'];
          await pref.setInt('attendance_id', attendanceId);
          print('Stored attendance_id: $attendanceId');
          print('Stored data: $data');

          String? inTimeStr = latestRecord['in_time'];
          String? dateStr = latestRecord['date'];
          String? outTime = latestRecord['out_time'];

          if (((inTimeStr != null) || (dateStr != null) || (outTime != null)) &&
              ("${latestRecord['punch_status']}"
                  .toLowerCase()
                  .contains('in'))) {
            DateTime checkinDateTime = DateTime.parse('$dateStr $inTimeStr');

            DateTime currentDate = DateTime.now();

            // Calculate the difference in time
            if (currentDate.isAfter(checkinDateTime)) {
              Duration timeDifference = currentDate.difference(checkinDateTime);

              // Use the time difference for setting the timer
              _stopWatchTimer.clearPresetTime();
              _stopWatchTimer.setPresetHoursTime(timeDifference.inHours);
              _stopWatchTimer
                  .setPresetMinuteTime(timeDifference.inMinutes.remainder(60));
              _stopWatchTimer
                  .setPresetSecondTime(timeDifference.inSeconds.remainder(60));
              _stopWatchTimer.onStartTimer();
            } else {
              _stopWatchTimer.clearPresetTime();
              _stopWatchTimer.setPresetHoursTime(0);
              _stopWatchTimer.setPresetMinuteTime(0);
              _stopWatchTimer.setPresetSecondTime(0);
              _stopWatchTimer.onStartTimer();
            }

            return {
              'punch_status':
                  "${latestRecord['punch_status']}".toLowerCase().contains('in')
                      ? 0
                      : 1,
              'time':
                  "${latestRecord['punch_status']}".toLowerCase().contains('in')
                      ? latestRecord['in_time']
                      : latestRecord['out_time'],
              'created_at': latestRecord['created_at'],
            };
          } else {
            _stopWatchTimer.onStopTimer();

            return {
              'punch_status':
                  "${latestRecord['punch_status']}".toLowerCase().contains('in')
                      ? 0
                      : 1,
              'time': latestRecord['punch_status'].contains('in')
                  ? latestRecord['in_time']
                  : latestRecord['out_time'],
              'created_at': latestRecord['created_at'],
            };
          }
        } else {
          throw Exception('No attendance data available');
        }
      } else {
        throw Exception('Failed to fetch attendance data');
      }
    } catch (e) {
      print("Exception $e");
      return null;
    }
  }

  Future<int?> handlePunchInOut(int status) async {
    print(status);
    try {
      final pref = await SharedPreferences.getInstance();

      Uri url = Uri.parse((status == 1)
          ? 'https://portalwiz.net/laravelapi/public/api/add_attendance'
          : 'https://portalwiz.net/laravelapi/public/api/edit_attendance');

      print(url.path);

      var punchStatus = status;
      print('Initial Punch Status: $punchStatus');

      var payload = {
        "attendance_id":
            (status == 0) ? "${pref.getInt('attendance_id')}" : null,
        "account_id": pref.getInt('account_id')?.toString() ?? '',
        "user_id": pref.getInt('user_id')?.toString() ?? '',
        "punch_status": (punchStatus == 0) ? "1" : "0",
      };
      if (punchStatus == 1) {
        payload["in_time"] =
            "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
      }
      if (punchStatus == 0) {
        payload["out_time"] =
            "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
      }

      print('Request Payload: $payload');
      final response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      var data = jsonDecode(response.body.toString());

      if (data['success']) {
        if (punchStatus == 0) {
          _stopWatchTimer.onResetTimer();
          _stopWatchTimer.onStartTimer();
        } else {
          _stopWatchTimer.onStopTimer();
          final workTime = StopWatchTimer.getDisplayTime(
              _stopWatchTimer.rawTime.value,
              milliSecond: false);
          print('Total Work Time: $workTime');
        }

        punchStatus = punchStatus == 0 ? 1 : 0;
        pref.setInt('punch_Status', punchStatus);
        print('Updated Punch Status: $punchStatus');

        return punchStatus;
      } else {
        return null;
      }
    } on PlatformException {
      return null;
    }
  }

  void _showAlertDialog(bool visi) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isCheckingLocation)
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Lottie.asset('asset/animation/empty.json'),
                      ),
                    Text(
                      "Attendance",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: fetchAttendanceData(),
                      builder: (context, snapshot) {
                        print("Data55  $snapshot");
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                          // } else if (!snapshot.hasData || snapshot.data == null) {
                          //   return Text("No attendance data available.");
                        } else {
                          var data = snapshot?.data;
                          var punchStatus = data?['punch_status'] ?? 1;
                          var time = data?['time'];
                          var createdAt = data?['created_at'];

                          DateTime? createdDateTime;
                          String formattedDate = '';

                          if (createdAt != null) {
                            createdDateTime = DateTime.parse(createdAt);
                            formattedDate = DateFormat('dd-MM-yyyy')
                                .format(createdDateTime);
                          }

                          String displayTime = '';
                          if (punchStatus == 0) {
                            displayTime = time != null
                                ? "Checked In Time: $time\n($formattedDate)"
                                : "Not Checked In Yet";
                          } else {
                            displayTime = time != null
                                ? "Checked Out Time: $time\n($formattedDate)"
                                : "Not Checked Out Yet";
                          }

                          return Column(
                            children: [
                              Text(
                                displayTime,
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Total in hours",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              StreamBuilder<int>(
                                stream: _stopWatchTimer.rawTime,
                                initialData: _stopWatchTimer.rawTime.value,
                                builder: (context, snap) {
                                  final value = snap.data!;
                                  final displayTime =
                                      StopWatchTimer.getDisplayTime(value,
                                          milliSecond: false);
                                  return Text(
                                    displayTime,
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences preferences =
                                      await SharedPreferences.getInstance();

                                  if (!(preferences.getBool("privacy_Terms") ??
                                      false)) {
                                    termsAndCondition();
                                  }

                                  if (checkLocation) {
                                    Map<String, dynamic>? datanew =
                                        await fetchAttendanceData();

                                    int? punchStatus = await handlePunchInOut(
                                        datanew?['punch_status'] ?? 1);
                                    if (punchStatus != null) {
                                      Navigator.of(dialogContext).pop();
                                      showLottieAnimation(
                                          punchStatus); // Replace with your Lottie animation method
                                    } else {
                                      print("Punch in/out failed");
                                    }
                                  } else {
                                    _determinePosition();
                                    print("Sorry");
                                  }
                                },
                                child: Text(
                                  punchStatus == 0 ? "Check out" : "Check In",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 35, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: punchStatus == 0
                                      ? Color.fromARGB(255, 230, 102, 102)
                                      : Color.fromARGB(255, 76, 175, 172),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showLottieAnimation(int punchStatus) {
    String animationPath = punchStatus == 1
        ? 'asset/animation/Animation - 1706007655831.json'
        : 'asset/animation/check_in.json';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Lottie.asset(
            animationPath,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(Duration(seconds: composition.duration.inSeconds),
                  () {
                Navigator.of(context).pop();
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.2,
            ),
            CircleAvatar(
              radius: 38,
              backgroundColor: Colors.transparent,
              child: profileUrl.isNotEmpty
                  ? ClipOval(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/default_avatar.png',
                        image:
                            "https://portalwiz.net/laravelapi/storage/app/$profileUrl",
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.account_circle,
                              size: 76, color: Colors.grey);
                        },
                        fit: BoxFit.cover,
                        width: 76,
                        height: 76,
                      ),
                    )
                  : Icon(Icons.account_circle, size: 76, color: Colors.grey),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.1,
            ),
            ListTile(
              title: const Text("Home"),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // Visibility(
            //   visible: roleId == 1,
            //   child:
            // ListTile(
            //   title: const Text("Projects"),
            //   leading: const Icon(Icons.add_box),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ProjectManagementScreen(),
            //       ),
            //     );
            //   },
            // ),

            ListTile(
              title: const Text("Attendence"),
              leading: const Icon(Icons.edit_document),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AttendanceReportPage()));
              },
            ),
            // Visibility(
            //   visible: (roleId==1),
            //   child: ListTile(
            //     title: const Text("PM Sheet"),
            //     leading: const Icon(Icons.manage_search),
            //     onTap: () {
            //       Navigator.pop(context);
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => ProjectManagerSheet(planid: null,)));
            //     },
            //   ),
            // ),
            ListTile(
              title: const Text("Daily plans"),
              leading: const Icon(Icons.manage_search),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DailyTasks(
                              title: "Daily PLans",
                              today: true,
                            )));
              },
            ),
            // ListTile(
            //   title: const Text("Face verification"),
            //   leading: const Icon(Icons.face),
            //   onTap: () async {
            //     Navigator.pop(context);
            //     SharedPreferences prefs = await SharedPreferences.getInstance();
            //     int? employeeId = prefs.getInt('employee_id');

            //     if (employeeId == null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => FaceVerificationPage()),
            //       );
            //     } else {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(builder: (context) => CheckInPage()),
            //       );
            //     }
            //   },
            // ),
            ListTile(
              title: const Text("Enquiries"),
              leading: const Icon(Icons.question_answer_outlined),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyEnquire()));
              },
            ),

            // Visibility(
            //   visible: roleId == 1,
            //   child:
            ListTile(
              title: const Text("My Leaves "),
              leading: const Icon(Icons.work),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaveTracker()));
              },
            ),

            Visibility(
              visible: roleId == 1,
              child: ListTile(
                title: const Text("Leave Management "),
                leading: const Icon(Icons.work),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LeaveRequest()));
                },
              ),
            ),
            ListTile(
              title: const Text("Log Out"),
              leading: const Icon(Icons.logout_outlined),
              onTap: () async {
                Navigator.pop(context);

                try {
                  // Clear user data
                  await clearUserData();

                  // Clear all cache
                  final directory = await getTemporaryDirectory();
                  final cacheDir = Directory(directory.path);
                  if (cacheDir.existsSync()) {
                    cacheDir.deleteSync(recursive: true);
                  }
                } catch (e) {
                  print(e);
                }

                // Dispose controllers and other resources if needed
                // _yourController.dispose();

                // Navigate to login screen and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(title: "")),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            ListTile(
              title: const Text("Version 1.1.0(91)"),
              leading: const Icon(Icons.mobile_friendly),
              onTap: () async {
                showAboutDialog(context: context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          title: Row(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.09),
                width: MediaQuery.of(context).size.height * 0.15,
                child: Image.asset('asset/image/portalwiz.png'),
              ),
              Spacer(),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(
                    "https://portalwiz.net/laravelapi/storage/app/" +
                        profileUrl),
              ),
              // Visibility(
              //   visible: roleId == 1,
              //   child:
              IconButton(
                icon: Icon(Icons.add_task),
                tooltip: 'Add New Task',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectManagementScreen(),
                    ),
                  );
                },
              ),
              //  ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              tabs: const [
                // Tab(
                //   text: "Not Started",
                // ),
                Tab(
                  text: "Active",
                ),
                Tab(
                  text: "Hold",
                ),
                Tab(
                  text: "Review",
                ),
                Tab(
                  text: "Complete",
                ),
                Tab(
                  text: "Snoozed",
                ),
                Tab(
                  text: "Clear",
                ),
              ],
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              isScrollable: true,
              controller: tabController,
            ),
          )),
      body: TabBarView(
        controller: tabController,
        children: [
          NotActive(),
          //Active(),
          Hold(),
          Review(),
          Complete(),
          Snoozed(),
          Clear(),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        overlayStyle: ExpandableFabOverlayStyle(
          blur: 5,
        ),
        children: [
          InkWell(
            onTap: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              if (!(preferences.getBool("privacy_Terms") ?? false)) {
                termsAndCondition();
              }
              if (checkLocation) {
                _showAlertDialog(false);
              } else {
                _determinePosition();
                print("Sorry");
              }
            },
            child: CircleAvatar(
              child: Icon(Icons.calendar_month_outlined,
                  size: 30, color: Colors.white),
              backgroundColor: Color.fromRGBO(0, 220, 35, 1.0),
              radius: 30,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckInPage()),
              );
            },
            child: CircleAvatar(
              child: Icon(
                Icons.face,
                size: 30,
                color: Colors.white,
              ),
              backgroundColor: Color.fromRGBO(79, 199, 222, 1),
              radius: 30,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRViewExample()),
              );
            },
            child: CircleAvatar(
              child: Icon(Icons.qr_code, size: 30, color: Colors.white),
              backgroundColor: Color.fromRGBO(10, 86, 118, 1),
              radius: 30,
            ),
          ),
        ],
      ),
    );
  }

  Container getAnime() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.12,
        child: Lottie.asset(urlAnime));
  }

  void showToast({
    required BuildContext context,
  }) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(builder: (context) => getAnime());
    Overlay.of(context).insert(overlayEntry);
    Timer(Duration(seconds: 3), () => overlayEntry.remove());
  }

  Switch punchinOrout(BuildContext dialogContex) {
    return Switch(
      // This bool value toggles th
      //e switch.
      value: light,
      activeColor: Colors.greenAccent,
      inactiveThumbColor: Colors.redAccent,
      inactiveTrackColor: Color.fromARGB(255, 255, 180, 180),
      onChanged: (bool value) {
        showToast(context: context);

        openscanner();

        setState(() {
          light = value;
          urlAnime;
        });
        getAnime();
        Navigator.pop(dialogContex);
        _showAlertDialog(false);
      },
    );
  }
}
