class todolistpojo {
  int? planId;
  int? userId;
  String? planName;
  String? planDate;
  String? updatedAt;
  String? achievements;
    int? status;
  String? comments;
  int? createdBy;
  String? createdAt;
  dynamic? planUpdatedBy;
  dynamic? planUpdatedAt;
  dynamic? achievementsUpdatedBy;
  dynamic? achievementsUpdatedAt;
  dynamic? commentUpdatedBy;
  dynamic? commentUpdatedAt;
  String? createdName;
  String? createdLname;
  String? userName;

  todolistpojo(
      {this.planId,
      this.userId,
      this.planName,
      this.planDate,
      this.updatedAt,
      this.achievements,
      this.comments,
      this.createdBy,
      this.createdAt,
    this.status,
      this.planUpdatedBy,
      this.planUpdatedAt,
      this.achievementsUpdatedBy,
      this.achievementsUpdatedAt,
      this.commentUpdatedBy,
      this.commentUpdatedAt,
      this.createdName,
      this.createdLname,
      this.userName});

  todolistpojo.fromJson(Map<String, dynamic> json) {
    planId = json['plan_id'];
    userId = json['user_id'];
    planName = json['plan_name'];
    status = json['status'];
    planDate = json['plan_date'];
    updatedAt = json['updated_at'];
    achievements = json['achievements'];
    comments = json['comments'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    planUpdatedBy = json['plan_updated_by'];
    planUpdatedAt = json['plan_updated_at'];
    achievementsUpdatedBy = json['achievements_updated_by'];
    achievementsUpdatedAt = json['achievements_updated_at'];
    commentUpdatedBy = json['comment_updated_by'];
    commentUpdatedAt = json['comment_updated_at'];
    createdName = json['created_name'];
    createdLname = json['created_lname'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plan_id'] = this.planId;
    data['user_id'] = this.userId;
    data['plan_name'] = this.planName;
    data['plan_date'] = this.planDate;
    data['status'] = this.status;
    data['updated_at'] = this.updatedAt;
    data['achievements'] = this.achievements;
    data['comments'] = this.comments;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['plan_updated_by'] = this.planUpdatedBy;
    data['plan_updated_at'] = this.planUpdatedAt;
    data['achievements_updated_by'] = this.achievementsUpdatedBy;
    data['achievements_updated_at'] = this.achievementsUpdatedAt;
    data['comment_updated_by'] = this.commentUpdatedBy;
    data['comment_updated_at'] = this.commentUpdatedAt;
    data['created_name'] = this.createdName;
    data['created_lname'] = this.createdLname;
    data['user_name'] = this.userName;
    return data;
  }
}