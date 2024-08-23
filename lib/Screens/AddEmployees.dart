import 'dart:io';

import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class AddEmployeeScreen extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Updated step content with EducationDetailsStep added
  final List<Widget> _steps = [
    PersonalDetailsStep(),
    ContactDetailsStep(),
    AddressDetailsStep(),
    EducationDetailsStep(), // New step added here
    BankDetailsStep(),
    AdditionalInformationStep(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(child: _steps[_currentStep]),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey[700],
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Back'),
                          ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentStep < _steps.length - 1) {
                              setState(() {
                                _currentStep++;
                              });
                            } else {
                              if (_formKey.currentState?.validate() ?? false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Form Submitted!')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: _currentStep == _steps.length - 1
                                ? Colors.green
                                : Colors.blue,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _currentStep == _steps.length - 1
                                ? 'Submit'
                                : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            minHeight: 8.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _steps.length,
              (index) => _buildStepIndicator(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: index <= _currentStep ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
// Individual Steps

class PersonalDetailsStep extends StatefulWidget {
  @override
  _PersonalDetailsStepState createState() => _PersonalDetailsStepState();
}

class _PersonalDetailsStepState extends State<PersonalDetailsStep> {
  final _picker = ImagePicker();
  XFile? _imageFile;
  final _employeeIdController = TextEditingController();
  String? _selectedUsername;
  String? _selectedEmployeeType;
  String? _selectedDesignation;
  String? _selectedDepartment;
  String? _selectedReportingManager;
  String? _selectedStatus;
  String? _selectedGender;
  final _dobController = TextEditingController();
  DateTime? _selectedDate;
  List<String> _departments = [];
  List<String> _reportingManagers = [];
  List<String> _statuses = [];
  List<String> _genders = [];
  List<String> _employeeTypes = [];
  List<String> _usernames = [];
  List<String> _designation = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeTypes();
    _fetchUsernames();
    _fetchDesignation();
    _fetchDepartment();
    _fetchManager();
    _fetchStatus();
    _fetchGender();
  }

  Future<void> _fetchEmployeeTypes() async {
    try {
      final types = await ApiCalls.fetchEmployeeTypes();
      setState(() {
        _employeeTypes = types;
      });
    } catch (e) {
      // Handle error
      print('Error fetching employee types: $e');
    }
  }

  Future<void> _fetchUsernames() async {
    try {
      final usernames = await ApiCalls.fetchUsernames();
      setState(() {
        _usernames = usernames;
      });
    } catch (e) {
      // Handle error
      print('Error fetching usernames: $e');
    }
  }

  Future<void> _fetchDesignation() async {
    try {
      final designation = await ApiCalls.fetchDesignationDropdown();
      setState(() {
        _designation = designation;
      });
    } catch (e) {
      // Handle error
      print('Error fetching designation: $e');
    }
  }

  Future<void> _fetchDepartment() async {
    try {
      final department = await ApiCalls.fetchDepartmentDropdown();
      setState(() {
        _departments = department;
      });
    } catch (e) {
      // Handle error
      print('Error fetching department: $e');
    }
  }

  Future<void> _fetchManager() async {
    try {
      final manager = await ApiCalls.fetchManagerDropdown();
      setState(() {
        _reportingManagers = manager;
      });
    } catch (e) {
      // Handle error
      print('Error fetching manager: $e');
    }
  }

  Future<void> _fetchStatus() async {
    try {
      final status = await ApiCalls.fetchActiveStatusDropdown();
      setState(() {
        _statuses = status;
      });
    } catch (e) {
      // Handle error
      print('Error fetching manager: $e');
    }
  }

  Future<void> _fetchGender() async {
    try {
      final gender = await ApiCalls.fetchGenderDropdown();
      setState(() {
        _genders = gender;
      });
    } catch (e) {
      // Handle error
      print('Error fetching gender: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Personal Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _imageFile == null
                ? Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.grey[600]),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imageFile!.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Photo'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _employeeIdController,
              label: 'Employee ID',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your employee ID';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Username',
              items: _usernames,
              selectedValue: _selectedUsername,
              onChanged: (value) {
                setState(() {
                  _selectedUsername = value;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Employee Type',
              items: _employeeTypes,
              selectedValue: _selectedEmployeeType,
              onChanged: (value) {
                setState(() {
                  _selectedEmployeeType = value;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Designation',
              items: _designation,
              selectedValue: _selectedDesignation,
              onChanged: (value) {
                setState(() {
                  _selectedDesignation = value;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Department',
              items: _departments,
              selectedValue: _selectedDepartment,
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Reporting Manager',
              items: _reportingManagers,
              selectedValue: _selectedReportingManager,
              onChanged: (value) {
                setState(() {
                  _selectedReportingManager = value;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Status',
              items: _statuses,
              selectedValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              label: 'Gender',
              items: _genders,
              selectedValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            SizedBox(height: 20),
            _buildDatePickerField(
              controller: _dobController,
              label: 'Date of Birth',
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select $label';
        }
        return null;
      },
      isExpanded:
          false, // This helps ensure the dropdown does not take up all the height
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required Function(DateTime) onDateSelected,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          onDateSelected(pickedDate);
        }
      },
    );
  }
}

// EducationDetailsStep Widget
class EducationDetailsStep extends StatefulWidget {
  @override
  _EducationDetailsStepState createState() => _EducationDetailsStepState();
}

class _EducationDetailsStepState extends State<EducationDetailsStep> {
  String? _selectedQualification;
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Education Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        // Dropdown for Highest Qualification
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Highest Qualification',
            border: OutlineInputBorder(),
          ),
          items: [
            'High School',
            'Bachelor\'s Degree',
            'Master\'s Degree',
            'PhD'
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedQualification = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your qualification';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        // TextField for University/College
        TextFormField(
          decoration: InputDecoration(
            labelText: 'University/College',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your university/college name';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        // TextField for Year of Passing
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Year of Passing',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your year of passing';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        // TextField for Work Experience
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Work Experience (in years)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your work experience';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        // File Picker for Education Documents
        ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx'],
            );
            if (result != null) {
              setState(() {
                _selectedFile = result.files.first;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('File selected: ${_selectedFile?.name}')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Upload Education Documents'),
        ),
        if (_selectedFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Text(
                  'Selected file: ${_selectedFile?.name}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.insert_drive_file, color: Colors.blue),
                  onPressed: () async {
                    if (_selectedFile != null && _selectedFile?.path != null) {
                      final Uri fileUri = Uri.file(_selectedFile!.path!);
                      if (!await launchUrl(fileUri)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open the file')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ContactDetailsStep extends StatefulWidget {
  @override
  _ContactDetailsStepState createState() => _ContactDetailsStepState();
}

class _ContactDetailsStepState extends State<ContactDetailsStep> {
  final _phoneController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _emergencyContactPersonController = TextEditingController();
  final _emergencyContactNumberController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _officialEmailController = TextEditingController();
  final _dobController = TextEditingController();

  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Contact Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _alternatePhoneController,
              label: 'Alternate Phone',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an alternate phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _emergencyContactPersonController,
              label: 'Emergency Contact Person',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the emergency contact person\'s name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _emergencyContactNumberController,
              label: 'Emergency Contact Number',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the emergency contact number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _personalEmailController,
              label: 'Personal Email',
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid personal email address';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _officialEmailController,
              label: 'Official Email',
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid official email address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      validator: validator,
    );
  }
}

class AddressDetailsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Address Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'Permanent Address',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your permanent address';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'Current Address',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current address';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'City',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'ZIP Code',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your ZIP code';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      validator: validator,
    );
  }
}

class BankDetailsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Bank Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'Bank Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your bank name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'Branch',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your bank branch';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'IFSC Code',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the IFSC code';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'Account Number',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your account number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'Aadhaar No.',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Aadhaar number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'PAN No.',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your PAN number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      validator: validator,
    );
  }
}

class AdditionalInformationStep extends StatefulWidget {
  @override
  _AdditionalInformationStepState createState() =>
      _AdditionalInformationStepState();
}

class _AdditionalInformationStepState extends State<AdditionalInformationStep> {
  DateTime? _anniversaryDate;
  DateTime? _exitDate;
  final _qualificationController = TextEditingController();
  final _exitReasonController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _allergyController = TextEditingController();

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Additional Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildDateField(
              label: 'Anniversary Date',
              selectedDate: _anniversaryDate,
              onDateSelected: (date) {
                setState(() {
                  _anniversaryDate = date;
                });
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _qualificationController,
              label: 'Qualification',
            ),
            SizedBox(height: 20),
            _buildDateField(
              label: 'Exit Date',
              selectedDate: _exitDate,
              onDateSelected: (date) {
                setState(() {
                  _exitDate = date;
                });
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _exitReasonController,
              label: 'Exit Reason',
            ),
            SizedBox(height: 20),
            _buildDropdownField(
              label: 'Blood Group',
              items: _bloodGroups,
              controller: _bloodGroupController,
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _allergyController,
              label: 'Allergy',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate == null
            ? ''
            : DateFormat('yyyy-MM-dd').format(selectedDate),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          onDateSelected(pickedDate);
        }
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required TextEditingController controller,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
    );
  }
}
