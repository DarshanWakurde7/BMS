class loginpojo {
  bool? success;
  String? message;
  List<Data>? data;

  loginpojo({this.success, this.message, this.data});

  loginpojo.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? accountId;
  int? userId;
  int? roleId;
  int? activeStatusId;
  String? firstName;
  String? lastName;
  String? companyName;
  int? countryCodeId1;
  int? userPhone;
  int? countryCodeId2;
  String? alternatePhone;
  String? userEmail;
  String? alternateEmail;
  String? username;
  String? password;
  int? otp;
  int? pin;
  String? dob;
  String? resetPasswordToken;
  bool? kycStatus;
  String? kycDate;
  String? panNumber;
  String? profilePath;
  String? city;
  String? state;
  String? country;
  String? address;
  String? addressLine1;
  String? addressLine2;
  String? addressLine3;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;
  String? accountName;
  String? accountPhone;
  String? accountDisplayName;
  String? productDisplayName;
  String? accountLogo;
  String? accountEmail;
  int? cgstRate;
  int? sgstRate;
  int? gstNo;
  String? invText1;
  String? invText2;
  String? source;
  int? defaultEnquiryStatus;

  Data(
      {this.accountId,
      this.userId,
      this.roleId,
      this.activeStatusId,
      this.firstName,
      this.lastName,
      this.companyName,
      this.countryCodeId1,
      this.userPhone,
      this.countryCodeId2,
      this.alternatePhone,
      this.userEmail,
      this.alternateEmail,
      this.username,
      this.password,
      this.otp,
      this.pin,
      this.dob,
      this.resetPasswordToken,
      this.kycStatus,
      this.kycDate,
      this.panNumber,
      this.profilePath,
      this.city,
      this.state,
      this.country,
      this.address,
      this.addressLine1,
      this.addressLine2,
      this.addressLine3,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt,
      this.accountName,
      this.accountPhone,
      this.accountDisplayName,
      this.productDisplayName,
      this.accountLogo,
      this.accountEmail,
      this.cgstRate,
      this.sgstRate,
      this.gstNo,
      this.invText1,
      this.invText2,
      this.source,
      this.defaultEnquiryStatus});

  Data.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    userId = json['user_id'];
    roleId = json['role_id'];
    activeStatusId = json['active_status_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    companyName = json['company_name'];
    countryCodeId1 = json['country_code_id_1'];
    userPhone = json['user_phone'];
    countryCodeId2 = json['country_code_id_2'];
    alternatePhone = json['alternate_phone'];
    userEmail = json['user_email'];
    alternateEmail = json['alternate_email'];
    username = json['username'];
    password = json['password'];
    otp = json['otp'];
    pin = json['pin'];
    dob = json['dob'];
    resetPasswordToken = json['reset_password_token'];
    kycStatus = json['kyc_status'];
    kycDate = json['kyc_date'];
    panNumber = json['pan_number'];
    profilePath = json['profile_path'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    address = json['address'];
    addressLine1 = json['address_line_1'];
    addressLine2 = json['address_line_2'];
    addressLine3 = json['address_line_3'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    accountName = json['account_name'];
    accountPhone = json['account_phone'];
    accountDisplayName = json['account_display_name'];
    productDisplayName = json['product_display_name'];
    accountLogo = json['account_logo'];
    accountEmail = json['account_email'];
    cgstRate = json['cgst_rate'];
    sgstRate = json['sgst_rate'];
    gstNo = json['gst_no'];
    invText1 = json['inv_text_1'];
    invText2 = json['inv_text_2'];
    source = json['source'];
    defaultEnquiryStatus = json['default_enquiry_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['user_id'] = this.userId;
    data['role_id'] = this.roleId;
    data['active_status_id'] = this.activeStatusId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['company_name'] = this.companyName;
    data['country_code_id_1'] = this.countryCodeId1;
    data['user_phone'] = this.userPhone;
    data['country_code_id_2'] = this.countryCodeId2;
    data['alternate_phone'] = this.alternatePhone;
    data['user_email'] = this.userEmail;
    data['alternate_email'] = this.alternateEmail;
    data['username'] = this.username;
    data['password'] = this.password;
    data['otp'] = this.otp;
    data['pin'] = this.pin;
    data['dob'] = this.dob;
    data['reset_password_token'] = this.resetPasswordToken;
    data['kyc_status'] = this.kycStatus;
    data['kyc_date'] = this.kycDate;
    data['pan_number'] = this.panNumber;
    data['profile_path'] = this.profilePath;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['address'] = this.address;
    data['address_line_1'] = this.addressLine1;
    data['address_line_2'] = this.addressLine2;
    data['address_line_3'] = this.addressLine3;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['account_name'] = this.accountName;
    data['account_phone'] = this.accountPhone;
    data['account_display_name'] = this.accountDisplayName;
    data['product_display_name'] = this.productDisplayName;
    data['account_logo'] = this.accountLogo;
    data['account_email'] = this.accountEmail;
    data['cgst_rate'] = this.cgstRate;
    data['sgst_rate'] = this.sgstRate;
    data['gst_no'] = this.gstNo;
    data['inv_text_1'] = this.invText1;
    data['inv_text_2'] = this.invText2;
    data['source'] = this.source;
    data['default_enquiry_status'] = this.defaultEnquiryStatus;
    return data;
  }
}
