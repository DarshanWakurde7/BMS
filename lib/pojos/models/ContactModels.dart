import 'package:intl/intl.dart';

class Contact {
  final String firstName;
  final String lastName;
  final String phone;
  final String alternatePhone;
  final String email;
  final String alternateEmail;
  final String gstNumber;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String pin;
  final String country;
  final String designation;
  final String createdBy;
  final String createdAt;
  final String updatedBy;
  final String displayName;

  Contact({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.alternatePhone,
    required this.email,
    required this.alternateEmail,
    required this.gstNumber,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.pin,
    required this.country,
    required this.designation,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.displayName,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    String formatDate(String dateStr) {
      final DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    }

    return Contact(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone']?.toString() ?? '',
      alternatePhone: json['alternate_phone']?.toString() ?? '',
      email: json['email'] ?? '',
      alternateEmail: json['alternate_email'] ?? '',
      gstNumber: json['gst_number']?.toString() ?? '',
      address1: json['address_1'] ?? '',
      address2: json['address_2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pin: json['pin']?.toString() ?? '',
      country: json['country'] ?? '',
      designation: json['designation'] ?? '',
      createdBy: json['created_by_string']?.toString() ?? '',
      createdAt: formatDate(json['created_at']),
      updatedBy: json['updated_by']?.toString() ?? '',
      displayName: json['display_name'] ?? '',
    );
  }
}
