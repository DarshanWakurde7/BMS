import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddContactForm extends StatefulWidget {
  final VoidCallback onContactAdded;
  AddContactForm({required this.onContactAdded});
  @override
  _AddContactFormState createState() => _AddContactFormState();
}

class _AddContactFormState extends State<AddContactForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alternatePhoneController =
      TextEditingController();
  final TextEditingController alternateEmailController =
      TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panNoController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found')),
        );
        return;
      }

      final contactData = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "alternate_phone": alternatePhoneController.text,
        "alternate_email": alternateEmailController.text,
        "gst_number": gstNumberController.text,
        "pan_no": panNoController.text,
        "designation": designationController.text,
        "display_name": displayNameController.text,
        "address_1": address1Controller.text,
        "address_2": address2Controller.text,
        "city": cityController.text,
        "state_id": stateController.text,
        "pin": pinController.text,
        "country_id": countryController.text,
        "created_by": userId.toString(), // Ensure it's a String
        "account_id": "1100",
      };

      try {
        final response = await ApiCalls.addContact(contactData);
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
          widget.onContactAdded(); // Notify that a contact has been added
          Navigator.pop(context); // Close the form
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add contact')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: firstNameController,
                              label: 'First Name',
                              icon: Icons.person,
                              isMandatory: true,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: lastNameController,
                              label: 'Last Name',
                              icon: Icons.person,
                              isMandatory: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: emailController,
                              label: 'Email Address',
                              icon: Icons.email,
                              isEmail: true,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: phoneController,
                              label: 'Phone No.',
                              icon: Icons.phone,
                              isMandatory: true,
                              isPhoneNumber: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: alternateEmailController,
                              label: 'Alternate Email',
                              icon: Icons.email,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: alternatePhoneController,
                              label: 'Alternate Phone',
                              icon: Icons.phone,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: gstNumberController,
                              label: 'GST Number',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: panNoController,
                              label: 'PAN No.',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: displayNameController,
                              label: 'Display Name',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: designationController,
                              label: 'Designation',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Address Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      _buildTextField(
                        controller: address1Controller,
                        label: 'Address 1',
                      ),
                      SizedBox(height: 8),
                      _buildTextField(
                        controller: address2Controller,
                        label: 'Address 2',
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: cityController,
                              label: 'City',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: stateController,
                              label: 'State',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: pinController,
                              label: 'PIN Code',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: countryController,
                              label: 'Country',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _saveContact,
                    child: Text('Save Contact'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isMandatory = false,
    bool isEmail = false,
    bool isPhoneNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (isMandatory && (value == null || value.isEmpty)) {
          return '$label is required';
        }
        if (isEmail &&
            value != null &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        if (isPhoneNumber &&
            value != null &&
            (value.length != 10 || !RegExp(r'^\d+$').hasMatch(value))) {
          return 'Enter a valid 10-digit phone number';
        }
        return null;
      },
    );
  }
}
