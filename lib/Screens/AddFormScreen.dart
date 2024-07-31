import 'dart:math';

import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/pojos/models/FilterDataPojo.dart';
import 'package:bms/widgets/TitleofClentinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getwidget/getwidget.dart';

class AddEnquireForm extends StatefulWidget {
  const AddEnquireForm({super.key});

  @override
  State<AddEnquireForm> createState() => __AddEnquireFormState();
}

class __AddEnquireFormState extends State<AddEnquireForm>
    with SingleTickerProviderStateMixin {
  final controller = PageController(initialPage: 0);
  late TabController tabController;

  TextEditingController lastname = TextEditingController();
  TextEditingController firstname = TextEditingController();
  TextEditingController emailaddress = TextEditingController();
  TextEditingController companyname = TextEditingController();
  TextEditingController whatsappno = TextEditingController();
  TextEditingController phoneno = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController enquireDetails = TextEditingController();
  TextEditingController enquireDate = TextEditingController();
  TextEditingController enquireClousreDate = TextEditingController();
  TextEditingController nextAppointmentDate = TextEditingController();
  TextEditingController notes = TextEditingController();

  TextEditingController amount = TextEditingController();
  TextEditingController dataSource = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController city = TextEditingController();

  EnquiryType enquiredropdown = EnquiryType(enquiryType: "Select Enquiry");
  ApplicantType applicantDropdown =
      ApplicantType(applicantType: "Applicant Type");
  EnquiryStatus enquireStatusDropdown =
      EnquiryStatus(enquiryStatus: "Enquiry Status");
  EnquirySources enquireSourceDropdown =
      EnquirySources(enquirySource: "Enquiry Source");
  LeadLevel leadLevelDropdown = LeadLevel(leadLevel: "Lead level");
  AssingedTo assingedTo = AssingedTo(firstName: "Assign", lastName: "To*");

  GetAllDropdownEnquire getAllDropDownData = GetAllDropdownEnquire();

  void _validateForm() async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Center(
              child: Lottie.network(
                  "https://lottie.host/2fcce2a4-14ea-4f92-a8f9-997c441d3043/EbknVutwPu.json",
                  width: 200),
            ),
          );
        });
    final validators = [
      MyFormValidation.validateName(lastname.text, "Last Name"),
      MyFormValidation.validateName(firstname.text, "First Name"),
      MyFormValidation.validateEmail(emailaddress.text),
      MyFormValidation.validatePhoneNumber(phoneno.text),
      MyFormValidation.validateNoSpecialCharacters(state.text, "State"),
      MyFormValidation.validateNoSpecialCharacters(city.text, "City"),
    ];
    for (var validatorMessage in validators) {
      if (validatorMessage != null) {
        MyFormValidation.showSnackBar(context, validatorMessage);

        Navigator.pop(context);
        return;
      }
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    print('userid: ${sharedPreferences.getInt('user_id')}');

    String data = await ApiCalls.addEnquireCall(
        firstname.text,
        lastname.text,
        phoneno.text,
        emailaddress.text,
        state.text,
        city.text,
        enquireDetails.text,
        whatsappno.text,
        companyname.text,
        (sharedPreferences.getInt('user_id')).toString(),
        (sharedPreferences.getInt('account_id')).toString(),
        enquireDate.text,
        dataSource.text,
        address.text,
        (enquiredropdown.enquiryTypeId == null
                ? ""
                : enquiredropdown.enquiryTypeId)
            .toString(),
        (applicantDropdown.applicantTypeId == null
                ? ""
                : applicantDropdown.applicantTypeId)
            .toString(),
        (enquireSourceDropdown.enquiryModeId == null
                ? ""
                : enquireSourceDropdown.enquiryModeId)
            .toString(),
        (leadLevelDropdown.leadLevelId == null
                ? ""
                : leadLevelDropdown.leadLevelId)
            .toString(),
        (enquireStatusDropdown.enquiryStatusId == null
                ? ""
                : enquireStatusDropdown.enquiryStatusId)
            .toString(),
        (assingedTo.userId == null ? "" : assingedTo.userId).toString(),
        enquireClousreDate.text,
        nextAppointmentDate.text,
        notes.text);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(data),
      backgroundColor: Colors.blueAccent,
      duration: Duration(milliseconds: 800),
    ));

    Navigator.pop(context);
  }

  @override
  void initState() {
    getDataofDropdownApi();
    tabController = TabController(length: 0, vsync: this, initialIndex: 0);
    // TODO: implement initState
    super.initState();
  }

  getDataofDropdownApi() async {
    getAllDropDownData = await ApiCalls.getAllDropDOwnsEnquire();
    print(getAllDropDownData.leadLevel);
    setState(() {
      getAllDropDownData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 189, 208, 240),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    "Enquiry Form ",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: MediaQuery.of(context).size.height * 0.88,
                width: MediaQuery.of(context).size.width * 0.99,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Text("Personal Information",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: firstname,
                              decoration: InputDecoration(
                                labelText: "First Name",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: lastname,
                              decoration: InputDecoration(
                                labelText: "Last Name",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: phoneno,
                              decoration: InputDecoration(
                                labelText: "Phone No.",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: whatsappno,
                              decoration: InputDecoration(
                                labelText: "WhatsApp No.",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        // child: Text("Email",
                        //     style: TextStyle(
                        //         fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          controller: emailaddress,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.email_outlined,
                                  color: Colors.grey.shade300),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.410,
                            child: TextField(
                              controller: state,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "State",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Container(
                            height: 52,
                            width: MediaQuery.of(context).size.width * 0.42,
                            child: TextField(
                              controller: city,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "City",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 47,
                            width: MediaQuery.of(context).size.width * 0.410,
                            child: TextField(
                              controller: pincode,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Pin",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 60),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: DropdownMenu(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  menuHeight: 250,
                                  hintText: enquiredropdown.enquiryType,
                                  dropdownMenuEntries:
                                      (getAllDropDownData.enquiryType ?? [])
                                          .map((item) {
                                    return DropdownMenuEntry(
                                      value: item.enquiryType,
                                      label: item.enquiryType ?? "",
                                    );
                                  }).toList(),
                                  onSelected: (item) {
                                    (getAllDropDownData.enquiryType ?? [])
                                        .forEach((element) {
                                      if (element.enquiryType == item) {
                                        setState(() {
                                          enquiredropdown = element;
                                        });
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text("Address",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                            maxLines: 2,
                            controller: address,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)))),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: DropdownMenu(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  menuHeight: 250,
                                  hintText: enquireStatusDropdown.enquiryStatus,
                                  dropdownMenuEntries:
                                      (getAllDropDownData.enquiryStatus ?? [])
                                          .map((item) {
                                    return DropdownMenuEntry(
                                      value: item.enquiryStatus,
                                      label: item.enquiryStatus ?? "",
                                    );
                                  }).toList(),
                                  onSelected: (item) {
                                    (getAllDropDownData.enquiryStatus ?? [])
                                        .forEach((element) {
                                      (element.enquiryStatus == item)
                                          ? setState(() {
                                              enquireStatusDropdown = element;
                                            })
                                          : null;
                                    });
                                  }),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: DropdownMenu(
                                  width:
                                      MediaQuery.of(context).size.width * 0.36,
                                  menuHeight: 250,
                                  hintText: leadLevelDropdown.leadLevel,
                                  dropdownMenuEntries:
                                      (getAllDropDownData.leadLevel ?? [])
                                          .map((item) {
                                    return DropdownMenuEntry(
                                      value: item.leadLevel,
                                      label: item.leadLevel ?? "",
                                    );
                                  }).toList(),
                                  onSelected: (item) {
                                    (getAllDropDownData.leadLevel ?? [])
                                        .forEach((element) {
                                      (element.leadLevel == item)
                                          ? setState(() {
                                              leadLevelDropdown = element;
                                            })
                                          : null;
                                    });
                                  }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: DropdownMenu(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  hintText: applicantDropdown.applicantType,
                                  dropdownMenuEntries:
                                      (getAllDropDownData.applicantType ?? [])
                                          .map((item) {
                                    return DropdownMenuEntry(
                                        value: item.applicantType,
                                        label: item.applicantType ?? "");
                                  }).toList(),
                                  onSelected: (item) {
                                    (getAllDropDownData.applicantType ?? [])
                                        .forEach((element) {
                                      (element.applicantType == item)
                                          ? setState(() {
                                              applicantDropdown = element;
                                            })
                                          : null;
                                    });
                                  }),
                            ),
                          ),
                          Container(
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: DropdownMenu(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  menuHeight: 250,
                                  hintText:
                                      "${assingedTo.firstName} ${assingedTo.lastName}",
                                  dropdownMenuEntries:
                                      (getAllDropDownData.assingedTo ?? [])
                                          .map((item) {
                                    return DropdownMenuEntry(
                                      value:
                                          "${item.firstName} ${item.lastName}",
                                      label:
                                          "${item.firstName} ${item.lastName}",
                                    );
                                  }).toList(),
                                  onSelected: (item) {
                                    (getAllDropDownData.assingedTo ?? [])
                                        .forEach((element) {
                                      ("${element.firstName} ${element.lastName}" ==
                                              item)
                                          ? setState(() {
                                              assingedTo = element;
                                            })
                                          : null;
                                    });
                                  }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: enquireDate,
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                      onTap: () async {
                                        DateTime? dateTime =
                                            await showDatePicker(
                                                context: context,
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2050));
                                        if (dateTime != null) {
                                          setState(() {
                                            enquireDate.text =
                                                "${dateTime.year}-${dateTime.month}-${dateTime.day}";
                                          });
                                        }
                                      },
                                      child:
                                          Icon(Icons.calendar_month_outlined)),
                                ),
                                labelText: "Enquiry date",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: enquireClousreDate,
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                      onTap: () async {
                                        DateTime? dateTime =
                                            await showDatePicker(
                                                context: context,
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2050));
                                        if (dateTime != null) {
                                          setState(() {
                                            enquireClousreDate.text =
                                                "${dateTime.year}-${dateTime.month}-${dateTime.day}";
                                          });
                                        }
                                      },
                                      child:
                                          Icon(Icons.calendar_month_outlined)),
                                ),
                                labelText: "Enquiry Closure",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text("Enquiry Details",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                            maxLines: 2,
                            controller: enquireDetails,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)))),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.83,
                            child: TextField(
                              controller: nextAppointmentDate,
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                      onTap: () async {
                                        DateTime? dateTime =
                                            await showDatePicker(
                                                context: context,
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2050));
                                        if (dateTime != null) {
                                          setState(() {
                                            nextAppointmentDate.text =
                                                "${dateTime.year}-${dateTime.month}-${dateTime.day}";
                                          });
                                        }
                                      },
                                      child:
                                          Icon(Icons.calendar_month_outlined)),
                                ),
                                labelText: "Next Appointment",
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text("Notes",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                            maxLines: 2,
                            controller: notes,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)))),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          _validateForm();
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.greenAccent.shade700,
                              borderRadius: BorderRadius.circular(11)),
                          child: Center(
                              child: Text(
                            "Add Enquiry",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          )),
                        ),
                      ),
                      SizedBox(
                        height: 70,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class MyFormValidation {
  static dynamic validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email address is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static dynamic validateDate(String value) {
    if (value.isEmpty) {
      return 'Date is required';
    } else if (!RegExp(r'^\d{4}/\d{1,2}/\d{2}$').hasMatch(value)) {
      return 'Enter a date in YYYY/MM/DD format';
    }
    return null;
  }

  static dynamic validateNotEmpty(String value, String fields) {
    if (value.isEmpty) {
      return '${fields}All Field is required';
    }
    return null;
  }

  static dynamic validateName(String value, String field) {
    if (value.isEmpty) {
      return '$field is required';
    } else if (RegExp(r'[^a-zA-Z\s]').hasMatch(value)) {
      return '$field should not contain special characters';
    }
    return null;
  }

  static dynamic validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'Phone Number is required';
    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Phone Number should be exactly 10 digits';
    }
    return null;
  }

  static dynamic validateNoSpecialCharacters(String value, String field) {
    if (value.isEmpty) {
      return '$field is required';
    } else if (RegExp(r'[^a-zA-Z\s]').hasMatch(value)) {
      return '$field should not contain special characters';
    }
    return null;
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(message),
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}
