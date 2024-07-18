class PrioritysDropdown {
  int? priorityId;
  String? priority;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  PrioritysDropdown(
      {this.priorityId,
      this.priority,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt});

  PrioritysDropdown.fromJson(Map<String, dynamic> json) {
    priorityId = json['priority_id'];
    priority = json['priority'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['priority_id'] = this.priorityId;
    data['priority'] = this.priority;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}