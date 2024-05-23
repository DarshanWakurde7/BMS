class GetAllDropdownEnquire {

  List<EnquiryType>? enquiryType;
  List<LeadLevel>? leadLevel;
  List<EnquiryStatus>? enquiryStatus;
  List<ApplicantType>? applicantType;
  List<EnquirySources>? enquirySources;
  List<AssingedTo>? assingedTo;
  List<CommentStatus>? commentStatus;

  GetAllDropdownEnquire(
      {this.enquiryType,
      this.leadLevel,
      this.enquiryStatus,
      this.applicantType,
      this.enquirySources,
      this.assingedTo,
      this.commentStatus});

  GetAllDropdownEnquire.fromJson(Map<String, dynamic> json) {
    if (json['enquiry_type'] != null) {
      enquiryType = <EnquiryType>[];
      json['enquiry_type'].forEach((v) {
        enquiryType!.add(new EnquiryType.fromJson(v));
      });
    }
    if (json['lead_level'] != null) {
      leadLevel = <LeadLevel>[];
      json['lead_level'].forEach((v) {
        leadLevel!.add(new LeadLevel.fromJson(v));
      });
    }
    if (json['enquiry_status'] != null) {
      enquiryStatus = <EnquiryStatus>[];
      json['enquiry_status'].forEach((v) {
        enquiryStatus!.add(new EnquiryStatus.fromJson(v));
      });
    }
    if (json['applicant_type'] != null) {
      applicantType = <ApplicantType>[];
      json['applicant_type'].forEach((v) {
        applicantType!.add(new ApplicantType.fromJson(v));
      });
    }
    if (json['enquiry_sources'] != null) {
      enquirySources = <EnquirySources>[];
      json['enquiry_sources'].forEach((v) {
        enquirySources!.add(new EnquirySources.fromJson(v));
      });
    }
    if (json['assinged_to'] != null) {
      assingedTo = <AssingedTo>[];
      json['assinged_to'].forEach((v) {
        assingedTo!.add(new AssingedTo.fromJson(v));
      });
    }
    if (json['comment_status'] != null) {
      commentStatus = <CommentStatus>[];
      json['comment_status'].forEach((v) {
        commentStatus!.add(new CommentStatus.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.enquiryType != null) {
      data['enquiry_type'] = this.enquiryType!.map((v) => v.toJson()).toList();
    }
    if (this.leadLevel != null) {
      data['lead_level'] = this.leadLevel!.map((v) => v.toJson()).toList();
    }
    if (this.enquiryStatus != null) {
      data['enquiry_status'] =
          this.enquiryStatus!.map((v) => v.toJson()).toList();
    }
    if (this.applicantType != null) {
      data['applicant_type'] =
          this.applicantType!.map((v) => v.toJson()).toList();
    }
    if (this.enquirySources != null) {
      data['enquiry_sources'] =
          this.enquirySources!.map((v) => v.toJson()).toList();
    }
    if (this.assingedTo != null) {
      data['assinged_to'] = this.assingedTo!.map((v) => v.toJson()).toList();
    }
    if (this.commentStatus != null) {
      data['comment_status'] =
          this.commentStatus!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EnquiryType {
  int? accountId;
  int? enquiryTypeId;
  String? enquiryType;
  int? activeStatusId;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;

  EnquiryType(
      {this.accountId,
      this.enquiryTypeId,
      this.enquiryType,
      this.activeStatusId,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  EnquiryType.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    enquiryTypeId = json['enquiry_type_id'];
    enquiryType = json['enquiry_type'];
    activeStatusId = json['active_status_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['enquiry_type_id'] = this.enquiryTypeId;
    data['enquiry_type'] = this.enquiryType;
    data['active_status_id'] = this.activeStatusId;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class LeadLevel {
  int? leadLevelId;
  int? accountId;
  String? leadLevel;
  int? activeStatusId;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;

  LeadLevel(
      {this.leadLevelId,
      this.accountId,
      this.leadLevel,
      this.activeStatusId,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  LeadLevel.fromJson(Map<String, dynamic> json) {
    leadLevelId = json['lead_level_id'];
    accountId = json['account_id'];
    leadLevel = json['lead_level'];
    activeStatusId = json['active_status_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lead_level_id'] = this.leadLevelId;
    data['account_id'] = this.accountId;
    data['lead_level'] = this.leadLevel;
    data['active_status_id'] = this.activeStatusId;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class EnquiryStatus {
  int? accountId;
  int? enquiryStatusId;
  String? enquiryStatus;
  int? activeStatusId;
  String? colorName;
  String? colorCode;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;

  EnquiryStatus(
      {this.accountId,
      this.enquiryStatusId,
      this.enquiryStatus,
      this.activeStatusId,
      this.colorName,
      this.colorCode,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  EnquiryStatus.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    enquiryStatusId = json['enquiry_status_id'];
    enquiryStatus = json['enquiry_status'];
    activeStatusId = json['active_status_id'];
    colorName = json['color_name'];
    colorCode = json['color_code'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['enquiry_status_id'] = this.enquiryStatusId;
    data['enquiry_status'] = this.enquiryStatus;
    data['active_status_id'] = this.activeStatusId;
    data['color_name'] = this.colorName;
    data['color_code'] = this.colorCode;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ApplicantType {
  int? applicantTypeId;
  int? accountId;
  String? applicantType;
  int? activeStatusId;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;

  ApplicantType(
      {this.applicantTypeId,
      this.accountId,
      this.applicantType,
      this.activeStatusId,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  ApplicantType.fromJson(Map<String, dynamic> json) {
    applicantTypeId = json['applicant_type_id'];
    accountId = json['account_id'];
    applicantType = json['applicant_type'];
    activeStatusId = json['active_status_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['applicant_type_id'] = this.applicantTypeId;
    data['account_id'] = this.accountId;
    data['applicant_type'] = this.applicantType;
    data['active_status_id'] = this.activeStatusId;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class EnquirySources {
  int? enquiryModeId;
  int? accountId;
  String? enquirySource;
  int? activeStatusId;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;

  EnquirySources(
      {this.enquiryModeId,
      this.accountId,
      this.enquirySource,
      this.activeStatusId,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  EnquirySources.fromJson(Map<String, dynamic> json) {
    enquiryModeId = json['enquiry_mode_id'];
    accountId = json['account_id'];
    enquirySource = json['enquiry_source'];
    activeStatusId = json['active_status_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['enquiry_mode_id'] = this.enquiryModeId;
    data['account_id'] = this.accountId;
    data['enquiry_source'] = this.enquirySource;
    data['active_status_id'] = this.activeStatusId;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class AssingedTo {
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
  String? resetPasswordToken;
  String? password;
  String? addressLine1;
  String? addressLine2;
  String? addressLine3;
  String? country;
  int? otp;
  int? pin;
  String? dob;
  String? panNumber;
  String? profilePath;
  String? city;
  String? token;
  String? state;
  String? address;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;

  AssingedTo(
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
      this.resetPasswordToken,
      this.password,
      this.addressLine1,
      this.addressLine2,
      this.addressLine3,
      this.country,
      this.otp,
      this.pin,
      this.dob,
      this.panNumber,
      this.profilePath,
      this.city,
      this.token,
      this.state,
      this.address,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  AssingedTo.fromJson(Map<String, dynamic> json) {
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
    resetPasswordToken = json['reset_password_token'];
    password = json['password'];
    addressLine1 = json['address_line_1'];
    addressLine2 = json['address_line_2'];
    addressLine3 = json['address_line_3'];
    country = json['country'];
    otp = json['otp'];
    pin = json['pin'];
    dob = json['dob'];
    panNumber = json['pan_number'];
    profilePath = json['profile_path'];
    city = json['city'];
    token = json['token'];
    state = json['state'];
    address = json['address'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
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
    data['reset_password_token'] = this.resetPasswordToken;
    data['password'] = this.password;
    data['address_line_1'] = this.addressLine1;
    data['address_line_2'] = this.addressLine2;
    data['address_line_3'] = this.addressLine3;
    data['country'] = this.country;
    data['otp'] = this.otp;
    data['pin'] = this.pin;
    data['dob'] = this.dob;
    data['pan_number'] = this.panNumber;
    data['profile_path'] = this.profilePath;
    data['city'] = this.city;
    data['token'] = this.token;
    data['state'] = this.state;
    data['address'] = this.address;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class CommentStatus {
  int? accountId;
  int? commentStatusId;
  String? commentStatus;
  int? createdBy;
  String? createdAt;
  String? updatedAt;
  int? updatedBy;

  CommentStatus(
      {this.accountId,
      this.commentStatusId,
      this.commentStatus,
      this.createdBy,
      this.createdAt,
      this.updatedAt,
      this.updatedBy});

  CommentStatus.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    commentStatusId = json['comment_status_id'];
    commentStatus = json['comment_status'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['comment_status_id'] = this.commentStatusId;
    data['comment_status'] = this.commentStatus;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}