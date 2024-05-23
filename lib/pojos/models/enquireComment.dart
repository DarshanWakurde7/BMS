class EnquiresCommentss {
  int? commentId;
  int? enquiryId;
  int? accountId;
  String? message;
  String? sendToCustomer;
  int? commentStatusId;
  String? followUpDate;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;
  String? createdFname;
  String? createdLname;
  String? profilePath;

  EnquiresCommentss(
      {this.commentId,
      this.enquiryId,
      this.accountId,
      this.message,
      this.sendToCustomer,
      this.commentStatusId,
      this.followUpDate,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt,
      this.createdFname,
      this.createdLname,
      this.profilePath});

  EnquiresCommentss.fromJson(Map<String, dynamic> json) {
    commentId = json['comment_id'];
    enquiryId = json['enquiry_id'];
    accountId = json['account_id'];
    message = json['message'];
    sendToCustomer = json['send_to_customer'];
    commentStatusId = json['comment_status_id'];
    followUpDate = json['follow_up_date'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    createdFname = json['created_fname'];
    createdLname = json['created_lname'];
    profilePath = json['profile_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment_id'] = this.commentId;
    data['enquiry_id'] = this.enquiryId;
    data['account_id'] = this.accountId;
    data['message'] = this.message;
    data['send_to_customer'] = this.sendToCustomer;
    data['comment_status_id'] = this.commentStatusId;
    data['follow_up_date'] = this.followUpDate;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['created_fname'] = this.createdFname;
    data['created_lname'] = this.createdLname;
    data['profile_path'] = this.profilePath;
    return data;
  }
}