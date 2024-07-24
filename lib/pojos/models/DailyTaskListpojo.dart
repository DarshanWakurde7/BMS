class todolistpojo {
  int? planId;
  int? userId;
  String? planName;
  String? planDate;
  int? teamId;
  int? status;
  String? updatedAt;
  String? achievements;
  String? comments;
  dynamic? createdBy;
  String? createdAt;
  dynamic? planUpdatedBy;
  dynamic? planUpdatedAt;
  int? achievementsUpdatedBy;
  String? achievementsUpdatedAt;
  int? commentUpdatedBy;
  String? commentUpdatedAt;
  String? achievementsUpdatedName;
  String? commentUpdatedName;
  String? userName;

  todolistpojo(
      {this.planId,
      this.userId,
      this.planName,
      this.planDate,
      this.teamId,
      this.status,
      this.updatedAt,
      this.achievements,
      this.comments,
      this.createdBy,
      this.createdAt,
      this.planUpdatedBy,
      this.planUpdatedAt,
      this.achievementsUpdatedBy,
      this.achievementsUpdatedAt,
      this.commentUpdatedBy,
      this.commentUpdatedAt,
      this.achievementsUpdatedName,
      this.commentUpdatedName,
      this.userName});

  todolistpojo.fromJson(Map<String, dynamic> json) {
    planId = json['plan_id'];
    userId = json['user_id'];
    planName = json['plan_name'];
    planDate = json['plan_date'];
    teamId = json['team_id'];
    status = json['status'];
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
    achievementsUpdatedName = json['achievements_updated_name'];
    commentUpdatedName = json['comment_updated_name'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plan_id'] = this.planId;
    data['user_id'] = this.userId;
    data['plan_name'] = this.planName;
    data['plan_date'] = this.planDate;
    data['team_id'] = this.teamId;
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
    data['achievements_updated_name'] = this.achievementsUpdatedName;
    data['comment_updated_name'] = this.commentUpdatedName;
    data['user_name'] = this.userName;
    return data;
  }
}