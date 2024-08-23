import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/AddplanUser.dart';
import 'package:bms/Screens/CheckAllDailyPlans.dart';
import 'package:bms/Screens/CheckAllDailyPlans.dart';
import 'package:bms/Screens/Pmsheet.dart';
import 'package:bms/Screens/PopUpFroCopydailyPLan.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:bms/pojos/models/DailyTaskListpojo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/models/value_item.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class DailyTasks extends StatefulWidget {
  const DailyTasks({super.key, required this.title, required this.today});
  final String title;
  final bool today;

  @override
  State<DailyTasks> createState() => _DailyTasksState();
}

class _DailyTasksState extends State<DailyTasks> {
  ValueNotifier<int> _secondsElapsedNotifier = ValueNotifier<int>(0);
  final AudioRecorder _recorder = AudioRecorder();
  DateTime _selectedValue = DateTime.now();
  bool isLoading = true;
  String valueofTeam = "Select Team";
  bool openIt = false;
  String? errorMessage;
  var achievementss = TextEditingController();
  var comments = TextEditingController();
  int roleId = 0;
  TextEditingController dateTimeselect = TextEditingController();
  List<todolistpojo> listData = [];
  List<todolistpojo> filteredList = [];
  List<dynamic> _teamsList = [];
  List<dynamic> _employeeList = [];
  TextEditingController _searchController = TextEditingController();
  List<ValueItem> _selectedTeam = [];
  List<todolistpojo> _filteredListnew = [];
  List<ValueItem<dynamic>> _selectedEmployee = [];
  bool isRecordingPaused = false;
  Timer? _timer;
  int _secondsElapsed = 0;
  final searchController = TextEditingController();
  int countpendding = 0;
  bool ownTask = false;
  int countCompleted = 0;
  int notdone = 0;
  int positive = 2;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int grandTotal = 0;
  bool _isRecording = false;
  String? _filePath;

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _currentPosition = 0;
  double _totalDuration = 0;
  DatePickerController _dateController = DatePickerController();
  //  static String baseurl="https://pw-bms-dev.portalwiz.in/laravelapi/public/api/";
  static String baseurl = "https://portalwiz.net/laravelapi/public/api/";

  @override
  void initState() {
    super.initState();

    _filterList("");
    fetchTeams();
    listTodo();
    fetchTeamEmployees(null);
    fetchTeamEmployees(null);
    fetchCountfordate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Animate to the selected date after the frame is rendered
      _dateController.animateToDate(_selectedValue);
    });
  }

  Future<void> listTodo() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      setState(() {
        roleId = sharedPreferences.getInt("role_id") ?? 0;
      });

      final Map<String, dynamic> requestBody = {
        "plan_date":
            "${_selectedValue.year}-${_selectedValue.month.toString().padLeft(2, '0')}-${_selectedValue.day.toString().padLeft(2, '0')}",
        "user_id": [
          ...(_selectedEmployee == null ||
                  (_selectedEmployee.isEmpty) ||
                  (ownTask)
              ? [
                  sharedPreferences.getInt("user_id") ?? 0
                ] // Provide a default value if null
              : _selectedEmployee.map((e) => e.value).toList())
        ],
        "team_id": _selectedTeam.isEmpty
            ? null
            : _selectedTeam.map((e) {
                return e.value;
              }).toList(), // Replace with actual team IDs if needed
        "role_id": "${sharedPreferences.getInt("role_id")}",
        "status": (positive != 3) ? "$positive" : null,
        "logged_in_user_id": [sharedPreferences.getInt("user_id") ?? 0]
      };

      print(requestBody);
      // Prepare the URL
      var url = Uri.parse((ownTask)
          ? '${baseurl}fetch_owen_daily_plan'
          : '${baseurl}fetch_daily_plan');

      // Perform the POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        fetchCountfordate();
        var data = jsonDecode(response.body.toString());
        if (mounted) {
          setState(() {
            roleId = sharedPreferences.getInt("role_id") ?? 0;
            listData = List<todolistpojo>.from(
                data.map((i) => todolistpojo.fromJson(i)));
            filteredList = listData;

            isLoading = false;
          });

          _filterList("");
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = "Failed to load tasks. Please try again later.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "An error occurred: $e";
        });
      }
    }
  }

  fetchCountfordate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response =
          await http.post(Uri.parse("${baseurl}fetch_daily_plan_count"),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                "plan_date":
                    "${_selectedValue.year}-${_selectedValue.month.toString().padLeft(2, '0')}-${_selectedValue.day.toString().padLeft(2, '0')}",
                "user_id": [
                  ...(_selectedEmployee == null ||
                          (_selectedEmployee.isEmpty) ||
                          (ownTask)
                      ? [
                          prefs.getInt("user_id") ?? 0
                        ] // Provide a default value if null
                      : _selectedEmployee.map((e) => e.value).toList())
                ],
                "team_id": _selectedTeam.isEmpty
                    ? null
                    : _selectedTeam.map((e) {
                        return e.value;
                      }).toList(), // Replace with actual team IDs if needed
                "role_id": "${prefs.getInt("role_id")}",
                "logged_in_user_id": [prefs.getInt("user_id") ?? 0]
              }));

      print(response.body);
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        setState(() {
          countpendding = jsonDecode(response.body)["pending"];
          notdone = jsonDecode(response.body)["not_done"];
          countCompleted = jsonDecode(response.body)["complete"];
          grandTotal = jsonDecode(response.body)["total"];
        });
      }
    } catch (e) {
      print(e);
    }
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
    print(_filePath);

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

  // Future<void> _startRecording() async {
  //   final bool isPermissionGranted = await _recorder.hasPermission();
  //   if (!isPermissionGranted) {
  //     return;
  //   }

  //   final directory = await getApplicationDocumentsDirectory();
  //   String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  //   _filePath = '${directory.path}/$fileName';

  //   const config = RecordConfig(
  //     encoder: AudioEncoder.aacLc,
  //     sampleRate: 44100,
  //     bitRate: 128000,
  //   );

  //   await _recorder.start(config, path: _filePath!);
  //   setState(() {
  //     _isRecording = true;
  //   });
  // }

  Future<void> _stopRecording(int planId, int index, bool send) async {
    final path = await _recorder.stop();
    print(send);
    if (((path ?? "").isNotEmpty) && send) {
      await showDialogDisCription(File(path!), 3, planId, index);
    } else {
      Fluttertoast.showToast(
          msg: 'Recording Stopped and not posted',
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

  deleteDailyPlans(int plan_id) async {
    try {
      final response =
          await http.post(Uri.parse("${baseurl}delete_daily_plan"), body: {
        "plan_id": "$plan_id",
      });
      print(response.body);
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        listTodo();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> fetchTeamEmployees(List<dynamic>? teamId) async {
    setState(() {
      _employeeList.clear();
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var url = Uri.parse('${baseurl}fetch_team_employee');

      // API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "team_id": teamId,
          "account_id": "${prefs.getInt("account_id")}",
          "user_id": ["${prefs.getInt("user_id")}"]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> employees =
            List<Map<String, dynamic>>.from(data);
        setState(() {
          _employeeList.addAll(employees);
        });

        print(
            "Employee List: $_employeeList"); // Debug: Print the employee list
        return true;
      } else {
        print('Failed to fetch employees. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error fetching employees: $e');
      return false;
    }
  }

  Future<void> fetchTeams() async {
    setState(() {
      _teamsList.clear();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id') ?? 0;

    if (!(userId == null)) {
      try {
        final response = await http.post(
          Uri.parse('${baseurl}fetch_teams'),
          body: {"user_id": "$userId", "role_id": "${prefs.getInt("role_id")}"},
        );
        print({"user_id": "$userId", "role_id": "${prefs.getInt("role_id")}"});

        if (response.statusCode == 200) {
          final List<dynamic> teamsData = jsonDecode(response.body);

          if (mounted) {
            setState(() {
              _teamsList.addAll(teamsData);
            });

            print(_teamsList.length);
          }
        } else {
          print('Failed to fetch teams. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching teams: $e');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredListnew = filteredList;
      } else if (_filteredListnew.length == 0) {
        searchController.clear();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No data found!")));
        listTodo();
      } else {
        _filteredListnew = filteredList
            .where((item) =>
                item.planName!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });

    getdata();
  }

  Future<void> _pickDocument(int planId, int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      await showDialogDisCription(file, 2, planId, index);
    }
  }

  Future<void> showDialogDisCription(
      File pickedFile, int type, int planid, int index) async {
    var title = TextEditingController();
    var discription = TextEditingController();
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
                          await uploadFile(File(pickedFile.path), type,
                              title.text, discription.text, planid, index);

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

  Future<void> _pickImageFromGallery(
      int planId, ImageSource imgsoruce, int index) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: imgsoruce);
    if (pickedFile != null) {
      showDialogDisCription(File(pickedFile.path), 1, planId, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonth = DateFormat.MMMM().format(_selectedValue);

    return Scaffold(
      appBar: AppBar(
        title: Text((widget.today) ? "Daily Plans" : "Daily Plans History"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DailyTasks(
                              title: "Previous Task",
                              today: false,
                            )));
              },
              icon: Icon(Icons.last_page_sharp)),
          Visibility(
              visible: roleId == 1,
              child: IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Checkalldailyplans())),
                  icon: Icon(Icons.people))),
        ],
      ),
      body: Column(
        children: [
          Visibility(
            visible: (widget.today),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.11,
              child: DatePicker(
                height: MediaQuery.of(context).size.height * 0.06,
                DateTime.now().subtract(Duration(days: 10)),
                initialSelectedDate: _selectedValue,
                controller: _dateController,
                selectionColor: Colors.blueAccent.shade100,
                selectedTextColor: Colors.white,
                onDateChange: (date) {
                  setState(() {
                    _selectedValue = date;
                    isLoading = true;
                    errorMessage = null;
                  });
                  listTodo();
                  fetchCountfordate();
                },
              ),
            ),
          ),
          Visibility(
              visible: !(widget.today),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19.0),
                child: TextField(
                  controller: dateTimeselect,
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = DateTime.parse(value);
                      isLoading = true;
                      errorMessage = null;
                    });
                    listTodo();
                    fetchCountfordate();
                  },
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              initialDate: _selectedValue,
                            );
                            setState(() {
                              dateTimeselect.text =
                                  "${date ?? DateTime.now()}".split(" ")[0];
                              _selectedValue = date ?? DateTime.now();
                            });

                            listTodo();
                            print(dateTimeselect.text);
                          },
                          icon: Icon(Icons.calendar_month)),
                      border: OutlineInputBorder()),
                ),
              )),
          SizedBox(height: 10),
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8, left: 5, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomAnimatedToggleSwitch<int>(
                      key: Key("toggle_switch"),
                      current: positive,
                      values: [2, 0, 1, 3],
                      iconBuilder: (context, local, global) {
                        switch (local.value) {
                          case 0:
                            return Icon(Icons.clear,
                                color: Colors.red); // Not Done
                          case 2:
                            return Icon(Icons.access_time,
                                color: Colors.orange); // Pending
                          case 1:
                            return Icon(Icons.check,
                                color: Colors.green); // Done
                          case 3:
                            return Icon(Icons.all_inclusive_sharp,
                                color: Colors.black); // Done
                          default:
                            return Icon(Icons.error);
                        }
                      },
                      onChanged: (value) async {
                        setState(() {
                          positive = value;
                        });
                        listTodo();
                        // Add additional logic if needed when the value changes
                      },
                      animationDuration: const Duration(milliseconds: 500),
                      animationCurve: Curves.easeInOutCirc,
                      indicatorSize: const Size(48.0, double.infinity),
                      spacing: 2.0, // Space between icons
                      separatorBuilder: (context, separatorProps, globalProps) {
                        return Container(
                          width: 1.0,
                          color: Colors.grey[300],
                        );
                      },
                      onTap: (tapProps) async {
                        // Handle tap events if needed
                        setState(() {
                          positive = tapProps.tapped!.value;
                        });
                        listTodo();
                      },
                      fittingMode: FittingMode.preventHorizontalOverlapping,
                      wrapperBuilder: (context, globalProps, child) {
                        return Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey[200],
                          ),
                          child: child,
                        );
                      },
                      foregroundIndicatorBuilder: (context, globalProps) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: (positive == 0)
                                ? Colors.redAccent
                                : (positive == 1)
                                    ? Colors.greenAccent
                                    : (positive != 3)
                                        ? Colors.orangeAccent
                                        : Colors.blueAccent,
                          ),
                          child: Center(
                              child: Icon((positive == 0)
                                  ? Icons.cancel_outlined
                                  : (positive == 1)
                                      ? Icons.check
                                      : (positive != 3)
                                          ? Icons.access_time
                                          : Icons.all_inclusive_sharp)),
                        );
                      },
                      backgroundIndicatorBuilder: (context, globalProps) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blueAccent,
                          ),
                        );
                      },
                      indicatorAppearingBuilder:
                          (context, animationValue, child) {
                        return Opacity(
                          opacity: animationValue,
                          child: child,
                        );
                      },
                      height: 50.0,
                      iconArrangement: IconArrangement.row,
                      iconsTappable: true,
                      padding: EdgeInsets.zero,
                      minTouchTargetSize: 48.0,
                      dragStartDuration: const Duration(milliseconds: 200),
                      dragStartCurve: Curves.easeInOutCirc,

                      cursors: ToggleCursors(),
                      loading: false, // Add a loading indicator if necessary
                      loadingAnimationDuration:
                          const Duration(milliseconds: 300),
                      loadingAnimationCurve: Curves.easeInOut,
                      indicatorAppearingDuration:
                          const Duration(milliseconds: 500),
                      indicatorAppearingCurve: Curves.easeInOut,
                      allowUnlistedValues: false,
                      active: true,
                      positionListener: (positionInfo) {
                        // Optional: Listen to position changes of the indicator
                      },
                    ),
                    Visibility(
                      visible: roleId == 1,
                      child: AnimatedToggleSwitch<bool>.dual(
                        current: ownTask,
                        first: false,
                        second: true,
                        spacing: 35.0,
                        style: const ToggleStyle(
                          borderColor: Colors.transparent,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        borderWidth: 3.0,
                        height: 40,
                        onChanged: (b) {
                          setState(() {
                            ownTask = b;
                          });
                          listTodo();
                        },
                        styleBuilder: (b) => ToggleStyle(
                            indicatorColor: b
                                ? Colors.redAccent
                                : Colors.blueAccent.shade200),
                        iconBuilder: (value) =>
                            value ? Icon(Icons.person) : Icon(Icons.people),
                        textBuilder: (value) => value
                            ? Center(child: Text('Own Task'))
                            : Center(child: Text('All Task')),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, right: 195),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Text(
                            "$countpendding",
                            style: TextStyle(fontSize: 12),
                          )),
                      radius: 11,
                      backgroundColor: Colors.orangeAccent.shade100,
                    ),
                    CircleAvatar(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text("$notdone", style: TextStyle(fontSize: 12)),
                      ),
                      radius: 11,
                      backgroundColor: Colors.redAccent.shade100,
                    ),
                    CircleAvatar(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text("$countCompleted",
                            style: TextStyle(fontSize: 12)),
                      ),
                      radius: 11,
                      backgroundColor: Colors.greenAccent.shade100,
                    ),
                    CircleAvatar(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child:
                            Text("$grandTotal", style: TextStyle(fontSize: 12)),
                      ),
                      radius: 11,
                      backgroundColor: Colors.blueAccent.shade100,
                    ),
                  ],
                ),
              )
            ],
          ),
          Visibility(
            visible: ((roleId == 1) && (!(_teamsList.isEmpty))),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: MultiSelectDropDown(
                      hint: "Select Team",
                      onOptionSelected: (val) {
                        fetchTeamEmployees(val.map((e) {
                          return e.value;
                        }).toList());
                        setState(() {
                          _selectedTeam = val;
                          _employeeList;
                        });

                        listTodo();
                        // Ensure to refresh the task list
                      },
                      options: _teamsList
                          .map((e) => ValueItem(
                              label: e["team_name"], value: e["team_id"]))
                          .toList(),
                      selectedOptions: _selectedEmployee ?? [],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Visibility(
                    visible: (_employeeList.isNotEmpty && !ownTask),
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MultiSelectDropDown(
                        hint: "Select Employees",
                        onOptionSelected: (val) {
                          setState(() {
                            _selectedEmployee = val;
                          });
                          listTodo(); // Ensure to refresh the task list
                        },
                        options: _employeeList
                            .map((e) => ValueItem(
                                label: e["first_name"] + " " + e["last_name"],
                                value: e["user_id"]))
                            .toList(),
                        selectedOptions: _selectedEmployee ?? [],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onChanged: (val) {
                _filterList(val);
                print(val);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : (errorMessage != null || _filteredListnew.isEmpty)
                    ? Center(
                        child: Card(
                        elevation: 8,
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: Padding(
                          padding: EdgeInsets.all(25),
                          child: Text(
                            "No items added for you yet.\nPlan your own day by adding your tasks for today!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ))
                    : ListView.builder(
                        itemCount: _filteredListnew.length +
                            2, // +1 for the search bar
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Search bar
                            return Divider();
                          } else if (index > _filteredListnew.length) {
                            return Center(
                                child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("No More Plans"),
                            ));
                          } else {
                            // Adjust index for the search bar
                            index -= 1;

                            return Dismissible(
                              onUpdate: (DismissUpdateDetails update) {
                                listTodo();
                                setState(() {
                                  _filteredListnew;
                                });
                              },
                              confirmDismiss: (direction) async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: Text(
                                        "Are you sure you want to delete this plan? \n${_filteredListnew[index].planName}",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.white),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop(
                                                false); // Dismiss action cancelled
                                          },
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.redAccent),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop(
                                                true); // Dismiss action confirmed
                                            await deleteDailyPlans(
                                                _filteredListnew[index]
                                                        .planId ??
                                                    0);
                                            await listTodo(); // Refresh the list after deletion
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onDismissed: (DismissDirection direction) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text(
                                          "Are you Sure delete Plan? \n${_filteredListnew[index].planName}",
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.white)),
                                              onPressed: () async {
                                                await listTodo();
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.black),
                                              )),
                                          ElevatedButton(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.redAccent)),
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                await deleteDailyPlans(
                                                    _filteredListnew[index]
                                                            .planId ??
                                                        0);
                                              },
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white),
                                              )),
                                        ],
                                      );
                                    });
                              },
                              key: Key(
                                  _filteredListnew[index].planId.toString()),
                              background: Container(
                                color: Colors.redAccent,
                                child: const Icon(Icons.delete,
                                    color: Colors.grey),
                                alignment: Alignment.centerRight,
                              ),
                              direction: DismissDirection.endToStart,
                              child: Card(
                                margin: EdgeInsets.all(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (_filteredListnew[index].isManager ??
                                            false)
                                        ? Color.fromARGB(255, 235, 243, 255)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: (_filteredListnew[index].status ==
                                              0)
                                          ? Colors.redAccent
                                          : (_filteredListnew[index].status ==
                                                  1)
                                              ? Colors.greenAccent
                                              : Colors.orangeAccent,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Visibility(
                                                    visible:
                                                        _filteredListnew[index]
                                                                .isManager ??
                                                            false,
                                                    child: SizedBox(
                                                      width: 10,
                                                    )),
                                                Visibility(
                                                    visible:
                                                        _filteredListnew[index]
                                                                .isManager ??
                                                            false,
                                                    child: Icon(
                                                      Icons
                                                          .person_outline_sharp,
                                                      color: Colors.black,
                                                    )),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0),
                                                  child: Text(
                                                    () {
                                                      try {
                                                        return _teamsList.firstWhere((e) =>
                                                                    e["team_id"] ==
                                                                    _filteredListnew[
                                                                            index]
                                                                        .teamId)[
                                                                "team_name"] ??
                                                            "Admin";
                                                      } catch (e) {
                                                        return "Admin Team";
                                                      }
                                                    }(),
                                                    style: TextStyle(
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Visibility(
                                                  visible:
                                                      (_filteredListnew[index]
                                                              .status ==
                                                          1),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0,
                                                            top: 5),
                                                    child: Icon(
                                                      Icons.verified_sharp,
                                                      size: 24,
                                                      color: Colors.blueAccent,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 3),
                                                  child: Icon(
                                                    (_filteredListnew[index]
                                                                .status ==
                                                            0)
                                                        ? Icons.clear
                                                        : (_filteredListnew[
                                                                        index]
                                                                    .status ==
                                                                1)
                                                            ? Icons.check
                                                            : Icons.access_time,
                                                    color: (_filteredListnew[
                                                                    index]
                                                                .status ==
                                                            0)
                                                        ? Colors.redAccent
                                                        : (_filteredListnew[
                                                                        index]
                                                                    .status ==
                                                                1)
                                                            ? Colors.greenAccent
                                                            : Colors
                                                                .orangeAccent,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Visibility(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 0.0),
                                                    child: GestureDetector(
                                                      onTap: () => showDialog(
                                                        context: context,
                                                        builder: (cocontext) {
                                                          return Dialog(
                                                            child:
                                                                StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                                return ProjectManagerPopup(
                                                                  planid: _filteredListnew[
                                                                          index]
                                                                      .planId,
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 5.0),
                                                        child: Icon(
                                                          Icons.copy,
                                                          size: 20,
                                                          color:
                                                              Colors.blueAccent,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                GestureDetector(
                                                    onTap: () async {
                                                      updateplan(
                                                          _filteredListnew[
                                                                      index]
                                                                  .planId ??
                                                              0,
                                                          "${_selectedValue.add(Duration(days: 1)).year}-${_selectedValue.add(Duration(days: 1)).month}-${_selectedValue.add(Duration(days: 1)).day}" ??
                                                              "",
                                                          _filteredListnew[
                                                                      index]
                                                                  .planName ??
                                                              "",
                                                          achievementss.text,
                                                          _filteredListnew[
                                                                      index]
                                                                  .comments ??
                                                              comments.text,
                                                          _filteredListnew[
                                                                      index]
                                                                  .userId ??
                                                              0,
                                                          _filteredListnew[
                                                                      index]
                                                                  .teamId ??
                                                              0,
                                                          _filteredListnew[
                                                                      index]
                                                                  .status ??
                                                              0,
                                                          _filteredListnew[
                                                                      index]
                                                                  .stars ??
                                                              0);

                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Plan Updated to next day");
                                                      await listTodo();
                                                    },
                                                    child: Icon(
                                                      Icons.next_plan_outlined,
                                                      weight: 2,
                                                      color: Colors.blueAccent,
                                                      size: 26,
                                                    )),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: Text(
                                              "${_filteredListnew[index].userName}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        child: Divider(
                                          color: const Color.fromARGB(
                                              255, 203, 203, 203),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(11)),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: GestureDetector(
                                                      onLongPress: () {
                                                        if (_filteredListnew[
                                                                    index]
                                                                .planName !=
                                                            null) {
                                                          Clipboard.setData(
                                                              new ClipboardData(
                                                                  text:
                                                                      '${_filteredListnew[index].planName}'));
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Copied to Clipboard");
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Failed to Copy");
                                                        }
                                                      },
                                                      child: Text(
                                                        _filteredListnew[index]
                                                            .planName
                                                            .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        child: Divider(
                                          color: const Color.fromARGB(
                                              255, 203, 203, 203),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                            ),
                                            child: Text("Achievements",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                          Visibility(
                                              visible: (_filteredListnew[index]
                                                          .achievements ==
                                                      null ||
                                                  _filteredListnew[index]
                                                      .achievements!
                                                      .isEmpty),
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(
                                                          child: Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.4,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  "Add Achievements",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10.0,
                                                                      vertical:
                                                                          20),
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        achievementss,
                                                                    maxLines: 5,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          "Write here...",
                                                                      border: OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(15))),
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      updateplan(
                                                                          _filteredListnew[index].planId ??
                                                                              0,
                                                                          _filteredListnew[index].planDate ??
                                                                              "",
                                                                          _filteredListnew[index].planName ??
                                                                              "",
                                                                          achievementss
                                                                              .text,
                                                                          _filteredListnew[index].comments ??
                                                                              comments
                                                                                  .text,
                                                                          _filteredListnew[index].userId ??
                                                                              0,
                                                                          _filteredListnew[index].teamId ??
                                                                              0,
                                                                          _filteredListnew[index].status ??
                                                                              0,
                                                                          _filteredListnew[index].stars ??
                                                                              0);
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                      "Add Achievements",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: Visibility(
                                                    visible:
                                                        "${_selectedValue.day}-${_selectedValue.month}" ==
                                                                "${DateTime.now().day}-${DateTime.now().month}" ||
                                                            roleId == 1,
                                                    child: Icon(Icons.add,
                                                        color:
                                                            Colors.blueAccent)),
                                              ))
                                        ],
                                      ),
                                      Visibility(
                                        visible: !(_filteredListnew[index]
                                                .achievements ==
                                            null),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                              borderRadius:
                                                  BorderRadius.circular(11)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onLongPress: () {
                                                      if (_filteredListnew[
                                                                  index]
                                                              .achievements !=
                                                          null) {
                                                        Clipboard.setData(
                                                            new ClipboardData(
                                                                text:
                                                                    '${_filteredListnew[index].achievements}'));
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Copied to Clipboard");
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Failed to Copy");
                                                      }
                                                    },
                                                    child: Text(
                                                      _filteredListnew[index]
                                                              .achievements ??
                                                          " ......",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        child: Divider(
                                          color: const Color.fromARGB(
                                              255, 203, 203, 203),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 0.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0),
                                              child: Text("Comments",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                            Visibility(
                                              visible:
                                                  "${_selectedValue.day}-${_selectedValue.month}" ==
                                                          "${DateTime.now().day}-${DateTime.now().month}" ||
                                                      roleId == 1,
                                              child: GestureDetector(
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.blueAccent,
                                                ),
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(
                                                          child: Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.4,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  "Add Comments",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10.0,
                                                                      vertical:
                                                                          20),
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        comments,
                                                                    maxLines: 5,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          "Write here...",
                                                                      border: OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(15))),
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      updateplan(
                                                                          _filteredListnew[index].planId ??
                                                                              0,
                                                                          _filteredListnew[index].planDate ??
                                                                              "",
                                                                          _filteredListnew[index].planName ??
                                                                              "",
                                                                          _filteredListnew[index].achievements ??
                                                                              "",
                                                                          comments
                                                                              .text,
                                                                          _filteredListnew[index].userId ??
                                                                              0,
                                                                          _filteredListnew[index].teamId ??
                                                                              0,
                                                                          _filteredListnew[index].status ??
                                                                              0,
                                                                          _filteredListnew[index].stars ??
                                                                              0);
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                      "Add Comments",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: !(_filteredListnew[index]
                                                .comments ==
                                            null),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                              borderRadius:
                                                  BorderRadius.circular(11)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onLongPress: () {
                                                      if (_filteredListnew[
                                                                  index]
                                                              .comments !=
                                                          null) {
                                                        Clipboard.setData(
                                                            new ClipboardData(
                                                                text:
                                                                    '${_filteredListnew[index].comments}'));
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Copied to Clipboard");
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Failed to Copy");
                                                      }
                                                    },
                                                    child: Text(
                                                      _filteredListnew[index]
                                                              .comments ??
                                                          " ......",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: IgnorePointer(
                                          ignoring: roleId != 1,
                                          child: RatingStars(
                                            valueLabelVisibility: false,
                                            axis: Axis.horizontal,
                                            value: double.parse(
                                                "${_filteredListnew[index].stars ?? 0}"),
                                            onValueChanged: (v) {
                                              print(v);
                                              setState(() {
                                                _filteredListnew[index].stars =
                                                    v.toInt();
                                              });

                                              updateplan(
                                                  _filteredListnew[
                                                              index]
                                                          .planId ??
                                                      0,
                                                  "${_selectedValue.year}-${_selectedValue.month}-${_selectedValue.day}" ??
                                                      "",
                                                  _filteredListnew[
                                                              index]
                                                          .planName ??
                                                      "",
                                                  achievementss.text,
                                                  _filteredListnew[
                                                              index]
                                                          .comments ??
                                                      comments.text,
                                                  _filteredListnew[
                                                              index]
                                                          .userId ??
                                                      0,
                                                  _filteredListnew[
                                                              index]
                                                          .teamId ??
                                                      0,
                                                  _filteredListnew[index]
                                                          .status ??
                                                      0,
                                                  v.toInt());
                                            },
                                            starCount: 5,
                                            starSize: 20,
                                            valueLabelColor: Color.fromARGB(
                                                255, 115, 114, 114),
                                            valueLabelRadius: 10,
                                            maxValue: 5,
                                            starSpacing: 2,
                                            animationDuration:
                                                Duration(milliseconds: 1000),
                                            valueLabelPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 1, horizontal: 8),
                                            valueLabelMargin:
                                                const EdgeInsets.only(right: 8),
                                            starOffColor:
                                                const Color(0xffe7e8ea),
                                            starColor: Colors.red,
                                            angle: 0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        child: Divider(
                                          color: const Color.fromARGB(
                                              255, 203, 203, 203),
                                        ),
                                      ),

                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        height: _filteredListnew[index]
                                                        .attachments !=
                                                    null &&
                                                _filteredListnew[index]
                                                    .attachments!
                                                    .isNotEmpty
                                            ? 100
                                            : 0,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _filteredListnew[index]
                                                  .attachments
                                                  ?.length ??
                                              0,
                                          itemBuilder: (context, attIndex) {
                                            int count = 0;

                                            if ((_filteredListnew[index]
                                                        .attachments ??
                                                    [])[attIndex]["type"] ==
                                                1) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Tooltip(
                                                  message: _filteredListnew[
                                                                      index]
                                                                  .attachments![
                                                              attIndex]
                                                          ["doc_name"] ??
                                                      "",
                                                  child: Stack(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () => showDialog(
                                                            context: (context),
                                                            builder: (context) {
                                                              return Center(
                                                                child:
                                                                    Container(
                                                                  child: Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    children: [
                                                                      Image
                                                                          .network(
                                                                        "https://portalwiz.net/laravelapi/storage/app/${_filteredListnew[index].attachments![attIndex]["path"]}",
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),

                                                                      IconButton(
                                                                        icon: Icon(
                                                                            Icons
                                                                                .cancel,
                                                                            color:
                                                                                Colors.red),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                      ),
                                                                      // Padding(
                                                                      //   padding: EdgeInsets.only(bottom: 50),
                                                                      //   child: Align(alignment: Alignment.bottomCenter,child: Text(_filteredListnew[index].attachments![attIndex]["doc_name"]??"Portalwiz"+"\n"+_filteredListnew[index].attachments![attIndex]["description"]??"Portalwiz",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w600),),))
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                        child: Image.network(
                                                          "https://portalwiz.net/laravelapi/storage/app/${_filteredListnew[index].attachments![attIndex]["path"]}",
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        right: 0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                              Icons
                                                                  .remove_circle,
                                                              color:
                                                                  Colors.red),
                                                          onPressed: () {
                                                            deleteplan(
                                                                _filteredListnew[index]
                                                                            .attachments![
                                                                        attIndex]
                                                                    [
                                                                    "daily_plan_doc_id"],
                                                                _filteredListnew[
                                                                            index]
                                                                        .planId ??
                                                                    0,
                                                                index);
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else if ((_filteredListnew[index]
                                                        .attachments ??
                                                    [])[attIndex]["type"] ==
                                                2) {
                                              return InkWell(
                                                onTap: () async {
                                                  var url =
                                                      "https://portalwiz.net/laravelapi/storage/app/" +
                                                          _filteredListnew[
                                                                      index]
                                                                  .attachments![
                                                              attIndex]["path"];
                                                  if (await canLaunch(url)) {
                                                    await launchUrl(
                                                        Uri.parse(url),
                                                        mode: LaunchMode
                                                            .externalApplication);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Sorry Cant open this file try on web");
                                                    await launchUrl(
                                                        Uri.parse(url),
                                                        mode: LaunchMode
                                                            .externalApplication);
                                                  }
                                                },
                                                child: Stack(
                                                  children: [
                                                    Tooltip(
                                                      message: _filteredListnew[
                                                                          index]
                                                                      .attachments![
                                                                  attIndex]
                                                              ["doc_name"] ??
                                                          "",
                                                      child: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        child: Icon(
                                                          Icons
                                                              .picture_as_pdf_outlined,
                                                          color:
                                                              Colors.redAccent,
                                                          size: 86,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      child: IconButton(
                                                        icon: Icon(
                                                            Icons.remove_circle,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          deleteplan(
                                                              _filteredListnew[
                                                                              index]
                                                                          .attachments![
                                                                      attIndex][
                                                                  "daily_plan_doc_id"],
                                                              _filteredListnew[
                                                                          index]
                                                                      .planId ??
                                                                  0,
                                                              index);
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            } else if (_filteredListnew[index]
                                                        .attachments![attIndex]
                                                    ["type"] ==
                                                3) {
                                              return GestureDetector(
                                                onTap: () async {
                                                  setSongData(
                                                      "https://portalwiz.net/laravelapi/storage/app/" +
                                                          _filteredListnew[
                                                                      index]
                                                                  .attachments![
                                                              attIndex]["path"]);
                                                  showModalBottomSheet(
                                                    isDismissible:
                                                        isRecordingPaused,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return StatefulBuilder(
                                                          builder: (BuildContext
                                                                  context,
                                                              StateSetter
                                                                  setModalState) {
                                                        return Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          height: MediaQuery.of(
                                                                      context)
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
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      20.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      20.0),
                                                            ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                _filteredListnew[index]
                                                                            .attachments![attIndex]
                                                                        [
                                                                        "doc_name"] ??
                                                                    "",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      18.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              StreamBuilder<
                                                                  Duration>(
                                                                stream: _audioPlayer
                                                                    .positionStream,
                                                                builder: (context,
                                                                    snapshot) {
                                                                  final position = snapshot
                                                                          .data ??
                                                                      Duration
                                                                          .zero;
                                                                  return ProgressBar(
                                                                    progress:
                                                                        position,
                                                                    total:
                                                                        _duration,
                                                                    onSeek:
                                                                        (duration) {
                                                                      _audioPlayer
                                                                          .seek(
                                                                              duration);
                                                                      setModalState(
                                                                          () {}); // Update UI on seek
                                                                    },
                                                                    progressBarColor:
                                                                        Colors
                                                                            .blue,
                                                                    baseBarColor:
                                                                        Colors
                                                                            .white,
                                                                    thumbColor:
                                                                        Colors
                                                                            .blueAccent,
                                                                    timeLabelTextStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              Spacer(),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  IconButton(
                                                                    icon: Icon(
                                                                      _isPlaying
                                                                          ? Icons
                                                                              .pause
                                                                          : Icons
                                                                              .play_arrow,
                                                                      color: Colors
                                                                          .white,
                                                                      size:
                                                                          40.0,
                                                                    ),
                                                                    onPressed:
                                                                        () {
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

                                                  //  launchUrl(Uri.parse(_filteredListnew[index].attachments![attIndex]["doc_path"]??""));
                                                },
                                                child: Stack(
                                                  children: [
                                                    Tooltip(
                                                      message:
                                                          "${_filteredListnew[index].attachments![attIndex]["doc_path"]}",
                                                      child: Container(
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        child: Icon(
                                                          Icons.music_note,
                                                          color:
                                                              Colors.blueAccent,
                                                          size: 86,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      child: IconButton(
                                                        icon: Icon(
                                                            Icons.remove_circle,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          deleteplan(
                                                              _filteredListnew[
                                                                              index]
                                                                          .attachments![
                                                                      attIndex][
                                                                  "daily_plan_doc_id"],
                                                              _filteredListnew[
                                                                          index]
                                                                      .planId ??
                                                                  0,
                                                              index);
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return GestureDetector(
                                                onTap: () async {
                                                  launchUrl(Uri.parse(
                                                      _filteredListnew[index]
                                                                      .attachments![
                                                                  attIndex]
                                                              ["doc_path"] ??
                                                          ""));
                                                },
                                                child: Tooltip(
                                                  message:
                                                      "${_filteredListnew[index].attachments![attIndex]["doc_path"]}",
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Icon(
                                                      Icons.link,
                                                      color: Colors.blueAccent,
                                                      size: 46,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      //   child: Divider(
                                      //     color: const Color.fromARGB(255, 203, 203, 203),
                                      //   ),
                                      // ),
                                      Visibility(
                                          visible: (!(_filteredListnew[index]
                                                      .attachments ==
                                                  null) &&
                                              (_filteredListnew[index]
                                                          .attachments ??
                                                      [])
                                                  .isNotEmpty),
                                          child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 5),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _pickImageFromGallery(
                                                    _filteredListnew[index]
                                                            .planId ??
                                                        0,
                                                    ImageSource.camera,
                                                    index);
                                              },
                                              child: Container(
                                                width: 75,
                                                child: Icon(
                                                    Icons.add_a_photo_outlined,
                                                    color: Colors.blueAccent),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _pickImageFromGallery(
                                                    _filteredListnew[index]
                                                            .planId ??
                                                        0,
                                                    ImageSource.gallery,
                                                    index);
                                              },
                                              child: Container(
                                                width: 75,
                                                child: Icon(
                                                    Icons.photo_library_rounded,
                                                    color: Colors.blueAccent),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _pickDocument(
                                                    _filteredListnew[index]
                                                            .planId ??
                                                        0,
                                                    index);
                                              },
                                              child: Container(
                                                width: 75,
                                                child: Icon(Icons.edit_document,
                                                    color: Colors.blueAccent),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                TextEditingController linkadd =
                                                    TextEditingController();
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Card(
                                                          child: Container(
                                                            height: 160,
                                                            color: Colors
                                                                .transparent,
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          10),
                                                                  child: Text(
                                                                    "Add Link",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10.0,
                                                                      vertical:
                                                                          6),
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        linkadd,
                                                                    decoration: InputDecoration(
                                                                        contentPadding: EdgeInsets.only(
                                                                            left:
                                                                                5),
                                                                        border: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(11))),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        (_filteredListnew[index].attachments ??=
                                                                                [])
                                                                            .add({
                                                                          "doc_path":
                                                                              linkadd.text,
                                                                          "doc_type":
                                                                              4
                                                                        });
                                                                      });

                                                                      linkadd
                                                                          .clear();
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                        "Add")),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                width: 60,
                                                child: Icon(Icons.link,
                                                    color: Colors.blueAccent),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                bool _isRecordingStarted =
                                                    false;
                                                setState(() {
                                                  isRecordingPaused = true;
                                                });
                                                showModalBottomSheet(
                                                  isDismissible: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.15,
                                                          child: Column(
                                                            children: [
                                                              Expanded(
                                                                  child:
                                                                      Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            5.0,
                                                                        left: 5,
                                                                        top:
                                                                            10),
                                                                child: Text(_filteredListnew[
                                                                            index]
                                                                        .planName ??
                                                                    "Daily plan Empty"),
                                                              )),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20,
                                                                        vertical:
                                                                            5),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    if (_isRecordingStarted) // Show timer only after recording starts
                                                                      ValueListenableBuilder<
                                                                          int>(
                                                                        valueListenable:
                                                                            _secondsElapsedNotifier,
                                                                        builder: (context,
                                                                            value,
                                                                            child) {
                                                                          return Text(
                                                                              _formatDuration(value));
                                                                        },
                                                                      ),
                                                                    if (_isRecordingStarted)
                                                                      SizedBox(
                                                                          width:
                                                                              25), // Spacing when recording starts
                                                                    if (_isRecordingStarted) // Show Lottie animation when recording starts
                                                                      Container(
                                                                        height:
                                                                            45,
                                                                        width:
                                                                            45,
                                                                        child: LottieBuilder
                                                                            .network(
                                                                          animate:
                                                                              !isRecordingPaused,
                                                                          "https://lottie.host/307ba84b-15d1-4db7-a757-8a04c4d5d7c1/wwzT5eluFl.json",
                                                                          reverse:
                                                                              true, // Reverse if paused
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    if (_isRecordingStarted)
                                                                      SizedBox(
                                                                          width:
                                                                              5), // Spacing when recording starts
                                                                  ],
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  if (_isRecordingStarted) // Show Delete button only after recording starts
                                                                    IconButton(
                                                                      icon: Icon(
                                                                          Icons
                                                                              .delete),
                                                                      onPressed:
                                                                          () async {
                                                                        await _recorder
                                                                            .pause();
                                                                        await _recorder
                                                                            .cancel();
                                                                        setState(
                                                                            () {
                                                                          _recorder;
                                                                          Navigator.pop(
                                                                              context);
                                                                          _stopRecording(
                                                                              pid,
                                                                              index,
                                                                              false);
                                                                          _timer!
                                                                              .cancel();
                                                                        });
                                                                      },
                                                                    ),
                                                                  if (_isRecordingStarted) // Show Pause button only after recording starts
                                                                    IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        isRecordingPaused
                                                                            ? Icons.play_arrow
                                                                            : Icons.pause,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          if (!isRecordingPaused) {
                                                                            _pauseRecording(); // Pause recording
                                                                            _timer?.cancel(); // Stop the timer
                                                                            isRecordingPaused =
                                                                                true;
                                                                          } else {
                                                                            _resumeRecording(); // Resume recording
                                                                            _startTimer(); // Restart the timer
                                                                            setState(() {
                                                                              isRecordingPaused = false;
                                                                            });
                                                                          }
                                                                        });
                                                                      },
                                                                    ),
                                                                  if (_isRecordingStarted) // Show Send button only after recording starts
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          _timer
                                                                              ?.cancel();
                                                                          _isRecording =
                                                                              false;
                                                                          _secondsElapsedNotifier =
                                                                              ValueNotifier(0);
                                                                        });
                                                                        _stopRecording(
                                                                            _filteredListnew[index].planId ??
                                                                                0,
                                                                            index,
                                                                            true);
                                                                        Navigator.of(context)
                                                                            .pop(); // Close the bottom sheet
                                                                      },
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            Colors.green,
                                                                        child: Icon(
                                                                            Icons.send),
                                                                      ),
                                                                    ),
                                                                  if (!_isRecordingStarted) // Show Play button initially
                                                                    IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .play_arrow,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          _isRecordingStarted =
                                                                              true; // Start recording
                                                                          _startRecording();
                                                                          _startTimer(); // Start the timer
                                                                          isRecordingPaused =
                                                                              false;
                                                                        });
                                                                      },
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ).then((onValue) {
                                                  if (_isRecording) {
                                                    _stopRecording(
                                                        _filteredListnew[index]
                                                                .planId ??
                                                            0,
                                                        index,
                                                        false);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 60,
                                                child: Icon(Icons.mic,
                                                    color: Colors.blueAccent),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                          visible: (roleId == 1),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProjectManagerSheet(
                                                                  planid: _filteredListnew[
                                                                          index]
                                                                      .planId,
                                                                  updateList: () =>
                                                                      listTodo(),
                                                                  seletDate:
                                                                      _selectedValue,
                                                                )));
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5.0,
                                                            bottom: 3),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ))
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          foregroundColor: Colors.blueAccent.shade200,
          onPressed: () {
            (roleId == 1)
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProjectManagerSheet(
                              planid: null,
                              updateList: () => listTodo(),
                              seletDate: _selectedValue,
                            )))
                : Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddPlanUser()));
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secondsRemaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secondsRemaining.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsedNotifier.value++;
        ;
      });
    });
  }

  void deleteplan(int attachmentid, int plan_id, int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "Are you Sure delete attachment? ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            ),
            actions: [
              ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white)),
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      _selectedValue;
                    });
                    await listTodo();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.black),
                  )),
              ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.redAccent)),
                  onPressed: () async {
                    Navigator.pop(context);
                    deleteAttachment(attachmentid, plan_id, index);

                    //  await deleteDailyPlans(_filteredListnew[index].planId??0);
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.white),
                  )),
            ],
          );
        });
  }

  void updateplan(int i, String date, String plan_name, String achievements,
      String commentss, int user_id, int team_id, int status, int stars) async {
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
      "lk_feedback_id": "${stars}"
    };
    print(requestBody);

    try {
      bool success = await ApiCalls.updateDailyPlan(requestBody);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully.')),
        );
        listTodo();
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

  Future<void> deleteAttachment(int attackmentId, int planid, int index) async {
    try {
      final response =
          await http.post(Uri.parse("${baseurl}delete_daily_plan_docs"), body: {
        "daily_plan_doc_id": "$attackmentId",
      });

      if (response.statusCode == 200) {
        await fetchImagesforEnquire(planid, index);
        Fluttertoast.showToast(msg: jsonDecode(response.body)["message"]);
      } else {
        Fluttertoast.showToast(msg: jsonDecode(response.body)["message"]);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> uploadFile(File file, int docType, String title,
      String discription, int plan_id, int index) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final uri = Uri.parse("${baseurl}add_daily_plan_docs");
    var formData = http.MultipartRequest('POST', uri);
    formData.fields.addAll({
      "created_by": sharedPreferences.getInt("user_id").toString(),
      "plan_id": "${plan_id}",
      "doc_type": "${docType}",
      "link": "",
      "doc_name": "${title}",
      "description": "${discription}",
    });
    formData.files.add(await http.MultipartFile.fromPath(
      'doc_path',
      file.path,
    ));
    var response = await formData.send();
    print(formData.headers);
    print(formData.fields);

    print(await response.stream.bytesToString());
    if (response.statusCode == 200) {
      //  showCustomSnackBar(context, await );
      Fluttertoast.showToast(
          msg: "File uploaded successfully.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey.shade200.withOpacity(0.5),
          textColor: Colors.black,
          fontSize: 16.0);
      print('File uploaded successfully.');
      await fetchImagesforEnquire(plan_id, index);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          jsonDecode(await response.stream.bytesToString())["message"],
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
        ),
        backgroundColor: Color.fromARGB(0, 160, 160, 160),
      ));
      print('Failed to upload file. Status code: ${response.statusCode}');
      Fluttertoast.showToast(
          msg: 'Failed to upload file. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent.withOpacity(0.5),
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  Future<void> fetchImagesforEnquire(int planid, int index) async {
    final response = await http.post(
      Uri.parse("${baseurl}fetch_daily_plan_docs"),
      body: {"plan_id": "${planid}"},
    );

// showCustomSnackBar(context, response.body);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      setState(() {
        _filteredListnew[index].attachments = data
            .map((doc) => {
                  'path': doc['doc_path'],
                  'type': doc['doc_type'],
                  'doc_name': doc['doc_name'],
                  'description': doc['description'],
                  'daily_plan_doc_id': doc['daily_plan_doc_id']
                })
            .toList();
        _filteredListnew;
      });
    } else {
      print('Failed to fetch documents. Status code:1 ${response.statusCode}');
    }
  }

  Future<void> getdata() async {
    for (int count = 0; count < _filteredListnew.length; count++) {
      await fetchImagesforEnquire(_filteredListnew[count].planId ?? 0, count);
    }
  }
}
