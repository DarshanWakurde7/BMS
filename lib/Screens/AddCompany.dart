import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCompany extends StatefulWidget {
  final VoidCallback onContactAdded;
  AddCompany({required this.onContactAdded});
  @override
  _AddCompanyState createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, String>> companyTypes = [];
  List<Map<String, String>> companyStatus = [];
  String? selectedCompanyStatus;
  String? selectedCompanyType;
  final companyNameController = TextEditingController();
  final headquartersController = TextEditingController();
  final companyEmailController = TextEditingController();
  final alternateEmailController = TextEditingController();
  final companyPhoneController = TextEditingController();
  final alternatePhoneController = TextEditingController();
  final gstNumberController = TextEditingController();
  final panNumberController = TextEditingController();
  final tanNumberController = TextEditingController();
  final websiteController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinController = TextEditingController();
  final countryController = TextEditingController();
  final gpsLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCompanyTypes();
    loadCompanyStatus();
  }

  Future<void> loadCompanyTypes() async {
    try {
      List<Map<String, String>> types = await ApiCalls.fetchCompanyTypes();
      setState(() {
        companyTypes = types;
      });
    } catch (e) {
      print('Error loading company types: $e');
    }
  }

  Future<void> loadCompanyStatus() async {
    try {
      List<Map<String, String>> status = await ApiCalls.fetchCompanyStatus();
      setState(() {
        companyStatus = status;
      });
    } catch (e) {
      print('Error loading company status: $e');
    }
  }

  Future<void> submitForm() async {
    final prefs = await SharedPreferences.getInstance();
    final createdBy = prefs.getInt('user_id') ?? '0';
    if (_formKey.currentState?.validate() ?? false) {
      final companyData = {
        "account_id": "1100",
        "company_name": companyNameController.text,
        "company_type_id": selectedCompanyType,
        "headquarters": headquartersController.text,
        "company_status_id": selectedCompanyStatus,
        "gst_number": gstNumberController.text,
        "pan_no": panNumberController.text,
        "tan_no": tanNumberController.text,
        "website": websiteController.text,
        "address_1": address1Controller.text,
        "address_2": address2Controller.text,
        "address_3": address2Controller.text,
        "city": cityController.text,
        "state": stateController.text,
        "pin": pinController.text,
        "country": countryController.text,
        "gps_location": gpsLocationController.text,
        "country_code_id_1": "91",
        "company_phone": companyPhoneController.text,
        "country_code_id_2": "91",
        "alternate_phone": alternatePhoneController.text,
        "company_email": companyEmailController.text,
        "alternate_email": alternateEmailController.text,
        "created_by": createdBy.toString()
      };

      try {
        final response = await ApiCalls.addCompany(companyData);
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Company Added successfully')),
          );
          widget.onContactAdded(); // Notify that a contact has been added
          Navigator.pop(context);
          // Optionally clear the form fields here
          _formKey.currentState?.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to add company: ${response['message']}')),
          );
        }
      } catch (e) {
        print('Error submitting form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while adding the company')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Company Form"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Company Details Section
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Company Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    TextFormField(
                      controller: companyNameController,
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Company Name is required';
                        }
                        return validateNoSpecialCharacters(value);
                      },
                    ),
                    TextFormField(
                      controller: headquartersController,
                      decoration: InputDecoration(
                        labelText: 'Headquarter',
                        border: OutlineInputBorder(),
                      ),
                      validator: validateNoSpecialCharacters,
                    ),
                    TextFormField(
                      controller: companyEmailController,
                      decoration: InputDecoration(
                        labelText: 'Company Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Company Email is required';
                        }
                        return validateEmail(value);
                      },
                    ),
                    TextFormField(
                      controller: alternateEmailController,
                      decoration: InputDecoration(
                        labelText: 'Alternate Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: validateEmail,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 50,
                          child: TextFormField(
                            initialValue: '91',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            // validator: validatePhoneNumber,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: companyPhoneController,
                            decoration: InputDecoration(
                              labelText: 'Company No.',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Company Phone is required';
                              }
                              return validatePhoneNumber(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 50,
                          child: TextFormField(
                            initialValue: '91',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            // validator: validatePhoneNumber,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: alternatePhoneController,
                            decoration: InputDecoration(
                              labelText: 'Alternate No.',
                              border: OutlineInputBorder(),
                            ),
                            // validator: validatePhoneNumber,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: gstNumberController,
                      decoration: InputDecoration(
                        labelText: 'GST No.',
                        border: OutlineInputBorder(),
                      ),
                      validator: validateNoSpecialCharacters,
                    ),
                    TextFormField(
                      controller: panNumberController,
                      decoration: InputDecoration(
                        labelText: 'PAN Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: validateNoSpecialCharacters,
                    ),
                    TextFormField(
                      controller: tanNumberController,
                      decoration: InputDecoration(
                        labelText: 'TAN Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: validateNoSpecialCharacters,
                    ),
                    TextFormField(
                      controller: websiteController,
                      decoration: InputDecoration(
                        labelText: 'Website Link',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Company Type',
                        border: OutlineInputBorder(),
                      ),
                      items: companyTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type["company_type_id"],
                          child: Text(type["company_type"]!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCompanyType = value;
                        });
                      },
                      value: selectedCompanyType,
                      // Remove validator to make this field optional
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Company Status',
                        border: OutlineInputBorder(),
                      ),
                      items: companyStatus.map((status) {
                        return DropdownMenuItem<String>(
                          value: status["company_status_id"],
                          child: Text(status["company_status"]!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCompanyStatus = value;
                        });
                      },
                      value: selectedCompanyStatus,
                      // Remove validator to make this field optional
                    ),
                    TextFormField(
                      controller: gpsLocationController,
                      decoration: InputDecoration(
                        labelText: 'GPS Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Contact Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    TextFormField(
                      controller: address1Controller,
                      decoration: InputDecoration(
                        labelText: 'Address Line 1',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: address2Controller,
                      decoration: InputDecoration(
                        labelText: 'Address Line 2',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: stateController,
                      decoration: InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: pinController,
                      decoration: InputDecoration(
                        labelText: 'PIN Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: countryController,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? validateNoSpecialCharacters(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final specialCharacterPattern = RegExp(r'^[a-zA-Z0-9\s]+$');
    if (!specialCharacterPattern.hasMatch(value)) {
      return 'No special characters allowed';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailPattern.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final phonePattern = RegExp(r'^[0-9]{10}$');
    if (!phonePattern.hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }
}
