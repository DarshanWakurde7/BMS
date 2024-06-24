class GetAllDataofEnquire {
  int? accountId;
  int? enquiryId;
  int? userId;
  int? userCreated;
  String? fname;
  String? lname;
  int? phone;
  String? email;
  String? enquiryDate;
  int? loanType;
  int? loanAmount;
  String? state;
  String? city;
  String? address;
  String? pin;
  String? dateOfBirth;
  int? leadLevelId;
  String? estimatedClosureDate;
  String? panNumber;
  String? notes;
  String? enqDetailMsg;
  String? nextAppointmentDate;
  int? enquiryModeId;
  int? enquiryTypeId;
  String? companyName;
  int? applicantTypeId;
  String? dataSource;
  String? whatsappNo;
  String? enquiryDetails;
  String? dob;
  int? enquiryStatusId;
  int? assignedTo;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;
  int? isDeleted;
  String? createdFname;
  String? createdLname;
  String? updatedFname;
  String? updatedLname;
  String? enquiryStatus;

  GetAllDataofEnquire(
      {this.accountId,
      this.enquiryId,
      this.userId,
      this.userCreated,
      this.fname,
      this.lname,
      this.phone,
      this.email,
      this.enquiryDate,
      this.loanType,
      this.loanAmount,
      this.state,
      this.city,
      this.address,
      this.pin,
      this.dateOfBirth,
      this.leadLevelId,
      this.estimatedClosureDate,
      this.panNumber,
      this.notes,
      this.enqDetailMsg,
      this.nextAppointmentDate,
      this.enquiryModeId,
      this.enquiryTypeId,
      this.companyName,
      this.applicantTypeId,
      this.dataSource,
      this.whatsappNo,
      this.enquiryDetails,
      this.dob,
      this.enquiryStatusId,
      this.assignedTo,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt,
      this.isDeleted,
      this.createdFname,
      this.createdLname,
      this.updatedFname,
      this.updatedLname,
      this.enquiryStatus});

  GetAllDataofEnquire.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    enquiryId = json['enquiry_id'];
    userId = json['user_id'];
    userCreated = json['user_created'];
    fname = json['fname'];
    lname = json['lname'];
    phone = json['phone'];
    email = json['email'];
    enquiryDate = json['enquiry_date'];
    loanType = json['loan_type'];
    loanAmount = json['loan_amount'];
    state = json['state'];
    city = json['city'];
    address = json['address'];
    pin = json['pin'];
    dateOfBirth = json['date_of_birth'];
    leadLevelId = json['lead_level_id'];
    estimatedClosureDate = json['estimated_closure_date'];
    panNumber = json['pan_number'];
    notes = json['notes'];
    enqDetailMsg = json['enq_detail_msg'];
    nextAppointmentDate = json['next_appointment_date'];
    enquiryModeId = json['enquiry_mode_id'];
    int? enquiryTypeId = int.tryParse(json['enquiry_type_id']);
    companyName = json['company_name'];
    applicantTypeId = json['applicant_type_id'];
    dataSource = json['data_source'];
    whatsappNo = json['whatsapp_no'];
    enquiryDetails = json['enquiry_details'];
    dob = json['dob'];
    enquiryStatusId = json['enquiry_status_id'];
    assignedTo = json['assigned_to'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    isDeleted = json['is_deleted'];
    createdFname = json['created_fname'];
    createdLname = json['created_lname'];
    updatedFname = json['updated_fname'];
    updatedLname = json['updated_lname'];
    enquiryStatus = json['enquiry_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['enquiry_id'] = this.enquiryId;
    data['user_id'] = this.userId;
    data['user_created'] = this.userCreated;
    data['fname'] = this.fname;
    data['lname'] = this.lname;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['enquiry_date'] = this.enquiryDate;
    data['loan_type'] = this.loanType;
    data['loan_amount'] = this.loanAmount;
    data['state'] = this.state;
    data['city'] = this.city;
    data['address'] = this.address;
    data['pin'] = this.pin;
    data['date_of_birth'] = this.dateOfBirth;
    data['lead_level_id'] = this.leadLevelId;
    data['estimated_closure_date'] = this.estimatedClosureDate;
    data['pan_number'] = this.panNumber;
    data['notes'] = this.notes;
    data['enq_detail_msg'] = this.enqDetailMsg;
    data['next_appointment_date'] = this.nextAppointmentDate;
    data['enquiry_mode_id'] = this.enquiryModeId;
    data['enquiry_type_id'] = this.enquiryTypeId;
    data['company_name'] = this.companyName;
    data['applicant_type_id'] = this.applicantTypeId;
    data['data_source'] = this.dataSource;
    data['whatsapp_no'] = this.whatsappNo;
    data['enquiry_details'] = this.enquiryDetails;
    data['dob'] = this.dob;
    data['enquiry_status_id'] = this.enquiryStatusId;
    data['assigned_to'] = this.assignedTo;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['is_deleted'] = this.isDeleted;
    data['created_fname'] = this.createdFname;
    data['created_lname'] = this.createdLname;
    data['updated_fname'] = this.updatedFname;
    data['updated_lname'] = this.updatedLname;
    data['enquiry_status'] = this.enquiryStatus;
    return data;
  }
}
