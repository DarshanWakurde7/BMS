class Company {
  final String companyName;
  final String companyStatus;
  final String companyType;
  final String headquarter;
  final String companyPhone;
  final String alternatePhone;
  final String companyEmail;
  final String alternateEmail;
  final String gstNumber;
  final String panNo;
  final String tanNo;
  final String website;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String pin;
  final String country;
  final String gpsLocation;

  Company({
    required this.companyName,
    required this.companyStatus,
    required this.companyType,
    required this.headquarter,
    required this.companyPhone,
    required this.alternatePhone,
    required this.companyEmail,
    required this.alternateEmail,
    required this.gstNumber,
    required this.panNo,
    required this.tanNo,
    required this.website,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.pin,
    required this.country,
    required this.gpsLocation,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyName: json['company_name']?.toString() ?? 'N/A',
      companyStatus: json['company_status_id']?.toString() ?? 'N/A',
      companyType: json['company_type_id']?.toString() ?? 'N/A',
      headquarter: json['headquarters']?.toString() ?? 'N/A',
      companyPhone: json['company_phone']?.toString() ?? 'N/A',
      alternatePhone: json['alternate_phone']?.toString() ?? 'N/A',
      companyEmail: json['company_email']?.toString() ?? 'N/A',
      alternateEmail: json['alternate_email']?.toString() ?? 'N/A',
      gstNumber: json['gst_number']?.toString() ?? 'N/A',
      panNo: json['pan_no']?.toString() ?? 'N/A',
      tanNo: json['tan_no']?.toString() ?? 'N/A',
      website: json['website']?.toString() ?? 'N/A',
      address1: json['address_1']?.toString() ?? 'N/A',
      address2: json['address_2']?.toString() ?? 'N/A',
      city: json['city']?.toString() ?? 'N/A',
      state: json['state']?.toString() ?? 'N/A',
      pin: json['pin']?.toString() ?? 'N/A',
      country: json['country']?.toString() ?? 'N/A',
      gpsLocation: json['gps_location']?.toString() ?? 'N/A',
    );
  }
}
