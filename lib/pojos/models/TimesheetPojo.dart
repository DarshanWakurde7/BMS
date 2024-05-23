class TimeSheetPojo {
  int? accountId;
  int? timesheetId;
  String? workDate;
  int? projectId;
  int? taskId;
  int? userId;
  int? taskCategoryId;
  String? startTime;
  String? endTime;
  String? external;
  String? approverComments;
  String? hours;
  int? revise;
  String? comment;
  int? approved;
  int? approveUserId;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;
  String? createdFname;
  String? createdLname;
  String? projectName;
  String? day;
  String? taskName;

  TimeSheetPojo(
      {this.accountId,
      this.timesheetId,
      this.workDate,
      this.projectId,
      this.taskId,
      this.userId,
      this.taskCategoryId,
      this.startTime,
      this.endTime,
      this.external,
      this.approverComments,
      this.hours,
      this.revise,
      this.comment,
      this.approved,
      this.approveUserId,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt,
      this.createdFname,
      this.createdLname,
      this.projectName,
      this.day,
      this.taskName});

  TimeSheetPojo.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    timesheetId = json['timesheet_id'];
    workDate = json['work_date'];
    projectId = json['project_id'];
    taskId = json['task_id'];
    userId = json['user_id'];
    taskCategoryId = json['task_category_id'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    external = json['external'];
    approverComments = json['approver_comments'];
    hours = json['hours'].toString();
    revise = json['revise'];
    comment = json['comment'];
    approved = json['approved'];
    approveUserId = json['approve_user_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    createdFname = json['created_fname'];
    createdLname = json['created_lname'];
    projectName = json['project_name'];
    day = json['day'];
    taskName = json['task_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['timesheet_id'] = this.timesheetId;
    data['work_date'] = this.workDate;
    data['project_id'] = this.projectId;
    data['task_id'] = this.taskId;
    data['user_id'] = this.userId;
    data['task_category_id'] = this.taskCategoryId;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['external'] = this.external;
    data['approver_comments'] = this.approverComments;
    data['hours'] = this.hours;
    data['revise'] = this.revise;
    data['comment'] = this.comment;
    data['approved'] = this.approved;
    data['approve_user_id'] = this.approveUserId;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['created_fname'] = this.createdFname;
    data['created_lname'] = this.createdLname;
    data['project_name'] = this.projectName;
    data['day'] = this.day;
    data['task_name'] = this.taskName;
    return data;
  }
}


//taskpojoss////////////////////////////////////////


class mytaskpojo {
  int? taskTypeId;
  String? taskType;

  mytaskpojo({this.taskTypeId, this.taskType});

  mytaskpojo.fromJson(Map<String, dynamic> json) {
    taskTypeId = json['task_type_id'];
    taskType = json['task_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['task_type_id'] = this.taskTypeId;
    data['task_type'] = this.taskType;
    return data;
  }
}