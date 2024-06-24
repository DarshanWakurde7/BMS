import 'dart:async';
import 'dart:convert';
import 'package:bms/Screens/Activepage.dart';
import 'package:bms/Screens/Enquire.dart';
import 'package:bms/Screens/NotActive.dart';
import 'package:bms/Screens/Notification.dart';
import 'package:bms/Screens/Snooze.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/clear.dart';
import 'package:bms/Screens/complete.dart';
import 'package:bms/Screens/hold.dart';
import 'package:bms/Screens/review.dart';
import 'package:bms/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as kit;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:bms/Screens/LeaveTracker.dart';
import 'package:bms/Screens/LeaveRequest.dart';

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
  var backColor;
  late bool light;
  bool checkLocation = false;
  String punch_Status = "";
  late String urlAnime;
  String profileUrl = "";

  Future<Position> _determinePosition() async {
    List<kit.LatLng> poligonlatslongs = [
      kit.LatLng(18.5944166, 73.7917032),
      kit.LatLng(18.5942322, 73.7928545),
      kit.LatLng(18.5941796, 73.7928305),
      kit.LatLng(18.5947532, 73.7932197),
      kit.LatLng(18.5946136, 73.7935348),
      kit.LatLng(18.5941001, 73.7934851),
      kit.LatLng(18.5939405, 73.7932565),
      kit.LatLng(15.8992889, 73.835161),
      kit.LatLng(15.9029442, 73.8398846),
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

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
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

      if (!mounted) return null;
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

  String getTime(http.Response responseAttendence) {
    final data = jsonDecode(responseAttendence.body);
    final List<Map<String, dynamic>> attendanceData =
        List<Map<String, dynamic>>.from(data['data']);
    final latestAttendance = attendanceData.last;
    return latestAttendance['time'];
  }

  void getPunched() async {
    final pref = await SharedPreferences.getInstance();

    setState(() {
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
    getPunched();
    ApiCalls.getDataofCards(1.toString());

    dataOfCards;
    _determinePosition();
    tabController = TabController(length: 7, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
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

  Future<Map<String, dynamic>?> fetchAttendanceData() async {
    try {
      final pref = await SharedPreferences.getInstance();

      Uri urlfetchAttendance = Uri.parse(
          "https://portalwiz.net/laravelapi/public/api/fetch_attendance");

      var payloadForFetch = {
        "account_id": pref.getInt('account_id').toString(),
        "user_id": pref.getInt('user_id').toString(),
      };

      final responseAttendance =
          await http.post(urlfetchAttendance, body: payloadForFetch);

      if (responseAttendance.statusCode == 200) {
        var data = jsonDecode(responseAttendance.body);

        return {
          'punch_status': data['punch_status'] ?? 0,
          'time': getTime(responseAttendance) ?? 0
        };
      } else {
        throw Exception('Failed to fetch attendance data');
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Sorry, failed to fetch attendance data. Try again."),
      //   backgroundColor: Colors.redAccent,
      // ));
      return null;
    }
  }

  Future<void> handlePunchInOut() async {
    try {
      final pref = await SharedPreferences.getInstance();

      Uri url = Uri.parse(
          'https://portalwiz.net/laravelapi/public/api/add_attendance?');

      var payload = {
        "account_id": pref.getInt('account_id').toString(),
        "user_id": pref.getInt('user_id').toString(),
        "punch_status": pref.getInt('punch_Status').toString()
      };

      final response = await http.post(url, body: payload);

      var data = jsonDecode(response.body.toString());

      if (!mounted) return;

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
    } on PlatformException {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Sorry, failed to scan. Try again."),
      //   backgroundColor: Colors.redAccent,
      // ));
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
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          final status = snapshot.data != null
                              ? snapshot.data!['punch_status']
                              : 0;
                          final time = snapshot.data != null
                              ? snapshot.data!['time']
                              : null;

                          bool isNewDay = true;
                          if (time != null && time.contains(':')) {
                            // Handle the time format (HH:mm:ss)
                            try {
                              TimeOfDay parsedTime = TimeOfDay(
                                hour: int.parse(time.split(':')[0]),
                                minute: int.parse(time.split(':')[1]),
                              );
                              DateTime now = DateTime.now();
                              isNewDay = now.hour != parsedTime.hour ||
                                  now.minute != parsedTime.minute;
                            } catch (e) {
                              // Handle invalid time format
                              print("Invalid time format: $e");
                            }
                          }

                          return Column(
                            children: [
                              if (time != null)
                                Text(
                                  status != 0
                                      ? " Checked In Time: $time"
                                      : " Checked Out Time: $time",
                                  style: TextStyle(fontSize: 18),
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
                                    await handlePunchInOut();
                                    setState(() {
                                      punch_Status = punch_Status.isEmpty
                                          ? "Checked In"
                                          : "";
                                    });
                                  } else {
                                    _determinePosition();
                                    print("Sorry");
                                  }
                                },
                                child: Text(
                                  (status == 0 || isNewDay)
                                      ? "Check In"
                                      : "Check Out",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: (status == 0 || isNewDay)
                                      ? Color.fromARGB(255, 76, 175, 172)
                                      : Color.fromARGB(255, 230, 102, 102),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.5,
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
            ListTile(
              title: const Text("Gallery"),
              leading: const Icon(Icons.picture_in_picture),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Enquiries"),
              leading: const Icon(Icons.question_answer_outlined),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyEnquire()));
              },
            ),
            ListTile(
              title: const Text("Leave Tracker "),
              leading: const Icon(Icons.work),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaveTracker()));
              },
            ),
            ListTile(
              title: const Text("Leave Requests "),
              leading: const Icon(Icons.work),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaveRequest()));
              },
            ),
            ListTile(
              title: const Text("Log Out"),
              leading: const Icon(Icons.logout_outlined),
              onTap: () async {
                Navigator.pop(context);
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                await sharedPreferences.clear();

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(title: "")));
              },
            ),
            ListTile(
              title: const Text("Version 1.1.0"),
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
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              tabs: const [
                Tab(
                  text: "Not Started",
                ),
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
          Active(),
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
          // color: Colors.black.withOpacity(0.5),
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
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 34,
              ),
              backgroundColor: backColor,
              radius: 24,
            ),
          )
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
