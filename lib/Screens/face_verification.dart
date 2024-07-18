import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bms/Screens/PhotoAttendence.dart';

class FaceVerificationPage extends StatefulWidget {
  @override
  _FaceVerificationPageState createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  final _usernameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _registerFace() async {
    if (_usernameController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide username and photo.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri =
        Uri.parse('http://91.108.111.222:8000/attendance/register_employee/');

    var request = http.MultipartRequest('POST', uri);

    request.fields['username'] = _usernameController.text;
    request.files
        .add(await http.MultipartFile.fromPath('face_image', _imageFile!.path));

    try {
      var response =
          await http.Client().send(request).timeout(Duration(seconds: 60));

      var streamedResponse = await response.stream.bytesToString();
      var jsonResponse = json.decode(streamedResponse);

      if (response.statusCode == 201) {
        int employeeId = jsonResponse['employee_id'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('employee_id', employeeId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Employee registered successfully, ID: $employeeId')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CheckInPage(),
          ),
        );
      } else {
        String errorMessage =
            jsonResponse['message'] ?? 'Unknown error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $errorMessage')),
        );
      }
    } on TimeoutException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request timed out, please try again later.')),
      );
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Socket Exception: $e')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Verification'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Capture Photo:'),
                      SizedBox(height: 8.0),
                      _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              height: 300,
                              width: 300,
                              fit: BoxFit.cover,
                            )
                          : Text('No image selected.'),
                      SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _registerFace,
                              child: Text('Register Face'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
