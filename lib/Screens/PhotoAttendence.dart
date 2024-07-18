import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:bms/Screens/face_verification.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage>
    with SingleTickerProviderStateMixin {
  File? _imageFile;
  bool isCheckedIn = false;
  bool isVerifying = false;
  bool showBlur = false;
  int? _employeeId;
  late AnimationController _controller;
  late Animation<double> _animation;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsedDuration = Duration.zero;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _initializeUser();
    _loadState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final employeeId = await _getEmployeeId();
    setState(() {
      _employeeId = employeeId;
    });
  }

  Future<int?> _getEmployeeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getInt('employee_id');
      return employeeId;
    } catch (e) {
      print('Error retrieving employee ID: $e');
      return null;
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isCheckedIn = prefs.getBool('isCheckedIn') ?? false;

      try {
        final checkInTimeString = prefs.getString('checkInTime');
        checkInTime = checkInTimeString != null && checkInTimeString.isNotEmpty
            ? DateTime.parse(checkInTimeString)
            : null;
      } catch (e) {
        print('Error parsing check-in time: $e');
        checkInTime = null;
      }

      try {
        final checkOutTimeString = prefs.getString('checkOutTime');
        checkOutTime =
            checkOutTimeString != null && checkOutTimeString.isNotEmpty
                ? DateTime.parse(checkOutTimeString)
                : null;
      } catch (e) {
        print('Error parsing check-out time: $e');
        checkOutTime = null;
      }

      if (isCheckedIn && checkInTime != null) {
        _elapsedDuration = DateTime.now().difference(checkInTime!);
        _stopwatch.start();
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            _elapsedDuration = DateTime.now().difference(checkInTime!);
          });
        });
      }
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckedIn', isCheckedIn);
    await prefs.setString('checkInTime', checkInTime?.toIso8601String() ?? '');
    await prefs.setString(
        'checkOutTime', checkOutTime?.toIso8601String() ?? '');
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _verifyFace();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _verifyFace() async {
    if (_imageFile == null || _employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please capture a photo for verification.')),
      );
      return;
    }

    setState(() {
      isVerifying = true;
      showBlur = true;
    });

    final uri = Uri.parse(
        'http://91.108.111.222:8000/attendance/${isCheckedIn ? 'check_out' : 'check_in'}/');
    var request = http.MultipartRequest('POST', uri)
      ..fields['employee_id'] = _employeeId.toString()
      ..files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      var response = await request.send().timeout(Duration(seconds: 60));

      var streamedResponse = await response.stream.bytesToString();
      var jsonResponse = json.decode(streamedResponse);

      setState(() {
        isVerifying = false;
        showBlur = false;
      });

      if (response.statusCode == 200) {
        if (jsonResponse['status'] == 'success') {
          setState(() {
            if (isCheckedIn) {
              // Check-out successful
              print('Check-out successful');
              checkOutTime = DateTime.parse(jsonResponse['check_out_time']);
              _stopwatch.stop();
              _timer?.cancel();
              isCheckedIn = false;
            } else {
              // Check-in successful
              print('Check-in successful');
              isCheckedIn = true;
              checkInTime = DateTime.parse(jsonResponse['check_in_time']);
              _elapsedDuration = Duration.zero;
              _stopwatch.start();
              checkOutTime = null;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${isCheckedIn ? 'Check-in' : 'Check-out'} successful',
              ),
            ),
          );
          _saveState();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'] ?? 'Unknown error')),
          );
        }
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? 'Bad request')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final istTime = dateTime.toLocal();
    return '${_formatTime(istTime)} ${istTime.day}/${istTime.month}/${istTime.year} ';
  }

  String _formatTime(DateTime dateTime) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(dateTime.hour);
    String minutes = twoDigits(dateTime.minute);
    String seconds = twoDigits(dateTime.second);
    return '$hours:$minutes:$seconds';
  }

  Future<void> _checkAndShowDialog() async {
    if (_employeeId == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('User Not Registered'),
            content: Text('You are not registered. Please register first.'),
            actions: <Widget>[
              TextButton(
                child: Text('Register'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaceVerificationPage(),
                    ),
                  ).then((_) => _initializeUser());
                },
              ),
            ],
          );
        },
      );
    } else {
      _pickImage(ImageSource.camera);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check In/Out'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedSize(
            duration: Duration(milliseconds: 300),
            child: Card(
              elevation: 4.0,
              child: Container(
                color: Color.fromARGB(255, 206, 236, 255),
                padding: const EdgeInsets.all(32.0),
                constraints: BoxConstraints(
                  minHeight: _imageFile == null ? 200 : 200,
                  minWidth: 300,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Welcome, ${'User'}!'),
                    SizedBox(height: 16.0),
                    Text(isCheckedIn
                        ? 'You are currently checked in.'
                        : 'You are currently checked out.'),
                    if (isCheckedIn) ...[
                      SizedBox(height: 16.0),
                      Text(
                        'Checked in at: ${_formatDateTime(checkInTime)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Elapsed time: ${_formatDuration(_elapsedDuration)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                    if (!isCheckedIn && checkOutTime != null) ...[
                      SizedBox(height: 16.0),
                      Text(
                        'Checked out at: ${_formatDateTime(checkOutTime)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Total time: ${_formatDuration(checkOutTime!.difference(checkInTime!))}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                    SizedBox(height: 16.0),
                    _imageFile != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.file(
                                _imageFile!,
                                height: 350,
                                width: 350,
                                fit: BoxFit.cover,
                              ),
                              if (isVerifying)
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: Container(
                                      color: Colors.black,
                                      child: CustomPaint(
                                        painter: ScanningPainter(
                                            animation: _animation),
                                      ),
                                    ),
                                  ),
                                ),
                              if (!isVerifying && showBlur)
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Center(
                                      child: Container(
                                        height: 250,
                                        width: 300,
                                        child: Lottie.asset(
                                          isCheckedIn
                                              ? 'assets/animation/check_in.json'
                                              : 'assets/animation/Animation - 1706007655831.json',
                                          repeat: false,
                                          onLoaded: (composition) {
                                            Timer(
                                              composition.duration,
                                              () {
                                                if (mounted) {
                                                  setState(() {
                                                    showBlur = false;
                                                  });
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: _checkAndShowDialog,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      label: Text(isCheckedIn ? 'Check Out' : 'Check In',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: isCheckedIn
                            ? Color.fromARGB(255, 230, 102, 102)
                            : Color.fromARGB(255, 76, 175, 172),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScanningPainter extends CustomPainter {
  final Animation<double> animation;

  ScanningPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final double scanY = size.height * animation.value;

    canvas.drawLine(
      Offset(0, scanY),
      Offset(size.width, scanY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
