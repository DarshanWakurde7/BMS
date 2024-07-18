class CategorysDropdown {
  int? accountId;
  int? taskCategoryId;
  dynamic? projectType;
  String? taskCategory;
  int? activeStatusId;
  int? createdBy;
  String? createdAt;
  dynamic? updatedBy;
  String? updatedAt;
  String? createdFname;
  String? createdLname;
  String? activeStatusString;

  CategorysDropdown(
      {this.accountId,
      this.taskCategoryId,
      this.projectType,
      this.taskCategory,
      this.activeStatusId,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt,
      this.createdFname,
      this.createdLname,
      this.activeStatusString});

  CategorysDropdown.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    taskCategoryId = json['task_category_id'];
    projectType = json['project_type'];
    taskCategory = json['task_category'];
    activeStatusId = json['active_status_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    createdFname = json['created_fname'];
    createdLname = json['created_lname'];
    activeStatusString = json['active_status_string'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['task_category_id'] = this.taskCategoryId;
    data['project_type'] = this.projectType;
    data['task_category'] = this.taskCategory;
    data['active_status_id'] = this.activeStatusId;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['created_fname'] = this.createdFname;
    data['created_lname'] = this.createdLname;
    data['active_status_string'] = this.activeStatusString;
    return data;
  }
}