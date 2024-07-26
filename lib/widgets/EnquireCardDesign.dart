import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  CommentEnquiredata commentController = Get.put(CommentEnquiredata());
  final ImagePicker _picker = ImagePicker();
List<Map<String, dynamic>> _attachments = [];


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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                          PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) async {
                  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                  switch (value) {
                    case 'whatsapp':
                      var androidUrl = "whatsapp://send?phone=+91${widget.phone}&text=Hi";
                      if (await canLaunchUrl(Uri.parse(androidUrl))) {
                        await launchUrl(Uri.parse(androidUrl), mode: LaunchMode.externalApplication);
                      }
                      String response = await ApiCalls.postEnquireCOmments(
                        "0",
                        widget.id.toString(),
                        "",
                        "",
                        "",
                        "The customer is texted via WhatsApp",
                        (sharedPreferences.getInt("user_id")).toString(),
                        (sharedPreferences.getInt("account_id")).toString()
                      );
                      Get.showSnackbar(GetSnackBar(title: response));
                      break;
                    case 'call':
                      var dialNumber = "tel:${widget.phone}";
                      if (await canLaunch(dialNumber)) {
                        await launchUrl(Uri.parse(dialNumber), mode: LaunchMode.externalApplication);
                      }
                      String response = await ApiCalls.postEnquireCOmments(
                        "0",
                        widget.id.toString(),
                        "",
                        "",
                        "",
                        "Call has been placed to customer",
                        (sharedPreferences.getInt("user_id")).toString(),
                        (sharedPreferences.getInt("account_id")).toString()
                      );
                      break;
                    case 'email':
                      var email = 'mailto:${widget.email}';
                      if (await canLaunch(email)) {
                        await launchUrl(Uri.parse(email), mode: LaunchMode.externalApplication);
                      }
                      String response = await ApiCalls.postEnquireCOmments(
                        "0",
                        widget.id.toString(),
                        "",
                        "",
                        "",
                        "Mail sent to customer",
                        (sharedPreferences.getInt("user_id")).toString(),
                        (sharedPreferences.getInt("account_id")).toString()
                      );
                      break;
                    case 'comments':
                      getCurrentLocation();
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
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  } else if (!commentController.isLoading.value && commentController.commentsdata.isEmpty) {
                                    return Center(
                                      child: Card(
                                        color: Colors.white,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(11),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "No comments available!",
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                                            itemCount: commentController.commentsdata.length,
                                            itemBuilder: (context, index) {
                                              final comment = commentController.commentsdata[index];
                                              return EnquireComment(
                                                name: comment.createdFname ?? "",
                                                date: comment.createdAt ?? "",
                                                comment: comment.message ?? "",
                                                nextfollupdate: comment.followUpDate ?? "",
                                                status: comment.commentStatus ?? "No status",
                                                profile: comment.profilePath ?? "profilepicture/G1SMGwzAvl1eYTZhsh7YfqVFMD9m0ElikUIIQGGy.webp",
                                              );
                                            },
                                          ),
                                        ),
                                        if (_attachments.isNotEmpty)
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Attachments:",
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                ),
                                                SizedBox(height: 10),
                                                Wrap(
                                                  spacing: 8.0,
                                                  runSpacing: 4.0,
                                                  children: _attachments.map((attachment) {
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        if (attachment['type'] == 2) {
                                                          var url = "https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}";
                                                          if (await canLaunch(url)) {
                                                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                                          }
                                                        } else if (attachment['type'] == 1) {
                                                          var url = "https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}";
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return Dialog(
                                                                child: Image.network(url),
                                                              );
                                                            },
                                                          );
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
                                                            ? Image.network("https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}", fit: BoxFit.cover)
                                                            : Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                                                      ),
                                                    );
                                                  }).toList(),
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
                    backgroundImage: AssetImage("asset/image/image.png"),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _attachments.map((attachment) {
                        return GestureDetector(
                          onTap: () async {
                            if (attachment['type'] == 2) {
                              var url = "https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}";
                              if (await canLaunch(url)) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              }
                            }
                           else if (attachment['type'] == 1) {
                              var url = "https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}";

                              showDialog(context: context, builder: (context){
                                return Dialog(
                                      child: Image.network(url),
                                );
                              });
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
                                ? Image.network("https://pw-bms-dev.portalwiz.in/laravelapi/storage/app/${attachment['path']}", fit: BoxFit.cover)
                                : Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
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

  Future<void> uploadFile(File file,int docType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final uri = Uri.parse("https://pw-bms-dev.portalwiz.in/laravelapi/public/api/add_enq_docs");
    var formData = http.MultipartRequest('POST', uri);
    formData.fields.addAll({
      "created_by": sharedPreferences.getInt("user_id").toString(),
      "enquiry_id": "${widget.id}",
      "doc_type":"${docType}"
    });
    formData.files.add(await http.MultipartFile.fromPath(
      'doc_path',
      file.path,
    ));
    var response = await formData.send();
    if (response.statusCode == 200) {
      print('File uploaded successfully.');
      await fetchImagesforEnquire();
    } else {
      print('Failed to upload file. Status code: ${response.statusCode}');
    }
  }

Future<void> fetchImagesforEnquire() async {
  final response = await http.post(
    Uri.parse("https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_enq_docs"),
    body: {
      "enquiry_id": "${widget.id}"
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    setState(() {
      _attachments.clear();
      for (var doc in data) {
        _attachments.add({'path': doc['doc_path'], 'type': doc['doc_type']});
      }
    });
  } else {
    print('Failed to fetch documents. Status code: ${response.statusCode}');
  }
}

  Future<void> _pickImage(ImageSource source) async {
  final pickedFile = await _picker.pickImage(source: source);
  if (pickedFile != null) {
    setState(() {
      _attachments.add({'path': pickedFile.path, 'type': 1});
    });
    await uploadFile(File(pickedFile.path), 1);
    await fetchImagesforEnquire();
  }
}

Future<void> _pickDocument() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    File file = File(result.files.single.path!);
    setState(() {
      _attachments.add({'path': file.path, 'type': 2});
    });
    await uploadFile(file, 2);
    await fetchImagesforEnquire();
  }
}


  getCommentsData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    commentController.getEnquireComments(
      sharedPreferences.getInt("account_id") ?? 0, widget.id
    );
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];

    print('Current Location: ${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}');
  }
}
