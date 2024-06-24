class Commentpojo {
  int? taskCommentId;
  int? accountId;
  int? userId;
  int? projectId;
  int? projectTaskId;
  String? followUpDate;
  int? commentStatus;
  String? message;
  String? sendToUser;
  int? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? createdFname;
  String? createdLname;
  String? profilePath;

  Commentpojo(
      {this.taskCommentId,
      this.accountId,
      this.userId,
      this.projectId,
      this.projectTaskId,
      this.followUpDate,
      this.commentStatus,
      this.message,
      this.sendToUser,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt,
      this.createdFname,
      this.createdLname,
      this.profilePath});

  Commentpojo.fromJson(Map<String, dynamic> json) {
    taskCommentId = json['task_comment_id'];
    accountId = json['account_id'];
    userId = json['user_id'];
    projectId = json['project_id'];
    projectTaskId = json['project_task_id'];
    followUpDate = json['follow_up_date'];
    commentStatus = json['comment_status'];
    message = json['message'];
    sendToUser = json['send_to_user'];
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
    data['task_comment_id'] = this.taskCommentId;
    data['account_id'] = this.accountId;
    data['user_id'] = this.userId;
    data['project_id'] = this.projectId;
    data['project_task_id'] = this.projectTaskId;
    data['follow_up_date'] = this.followUpDate;
    data['comment_status'] = this.commentStatus;
    data['message'] = this.message;
    data['send_to_user'] = this.sendToUser;
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
