class TaskStatusDropdown {
  int? accountId;
  int? taskStatusId;
  String? taskStatus;
  int? taskGroup;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;

  TaskStatusDropdown(
      {this.accountId,
      this.taskStatusId,
      this.taskStatus,
      this.taskGroup,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  TaskStatusDropdown.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    taskStatusId = json['task_status_id'];
    taskStatus = json['task_status'];
    taskGroup = json['task_group'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['task_status_id'] = this.taskStatusId;
    data['task_status'] = this.taskStatus;
    data['task_group'] = this.taskGroup;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}