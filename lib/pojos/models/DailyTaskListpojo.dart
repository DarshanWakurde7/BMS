class todolistpojo {
  List<Map<String, dynamic>>? attachments;
  int? planId;
  int? userId;
  int? projectId;
  int? projectTaskId;
  int? stars;
  int? priority;
  String? planName;
  String? planDate;
  int? teamId;
  int? status;
  String? achievements;
  String? comments;
  int? createdBy;
  String? createdAt;
  String? updatedAt;
  dynamic? planUpdatedBy;
  dynamic? planUpdatedAt;
  dynamic? achievementsUpdatedBy;
  dynamic? achievementsUpdatedAt;
  dynamic? commentUpdatedBy;
  dynamic? commentUpdatedAt;
  String? teamName;
  String? userName;
  bool? isManager;

  todolistpojo(
      {this.planId,
      this.userId,
      this.projectId,
      this.projectTaskId,
      this.stars,
      this.priority,
      this.planName,
      this.planDate,
      this.teamId,
      this.status,
      this.achievements,
      this.comments,
      this.createdBy,
      this.createdAt,
      this.updatedAt,
      this.planUpdatedBy,
      this.planUpdatedAt,
      this.achievementsUpdatedBy,
      this.achievementsUpdatedAt,
      this.commentUpdatedBy,
      this.commentUpdatedAt,
      this.teamName,
      this.userName,
      this.isManager});

  todolistpojo.fromJson(Map<String, dynamic> json) {
    planId = json['plan_id'];
    userId = json['user_id'];
    projectId = json['project_id'];
    projectTaskId = json['project_task_id'];
    stars = json['lk_feedback_id'];
    priority = json['priority'];
    planName = json['plan_name'];
    planDate = json['plan_date'];
    teamId = json['team_id'];
    status = json['status'];
    achievements = json['achievements'];
    comments = json['comments'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    planUpdatedBy = json['plan_updated_by'];
    planUpdatedAt = json['plan_updated_at'];
    achievementsUpdatedBy = json['achievements_updated_by'];
    achievementsUpdatedAt = json['achievements_updated_at'];
    commentUpdatedBy = json['comment_updated_by'];
    commentUpdatedAt = json['comment_updated_at'];
    teamName = json['team_name'];
    userName = json['user_name'];
    isManager = json['manager_status'];
    attachments = json['attachments'] != null
        ? List<Map<String, dynamic>>.from(json['attachments'])
        : null; // Parse attachments
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plan_id'] = this.planId;
    data['user_id'] = this.userId;
    data['project_id'] = this.projectId;
    data['project_task_id'] = this.projectTaskId;
    data['lk_feedback_id'] = this.stars;
    data['priority'] = this.priority;
    data['plan_name'] = this.planName;
    data['plan_date'] = this.planDate;
    data['team_id'] = this.teamId;
    data['status'] = this.status;
    data['achievements'] = this.achievements;
    data['comments'] = this.comments;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['plan_updated_by'] = this.planUpdatedBy;
    data['plan_updated_at'] = this.planUpdatedAt;
    data['achievements_updated_by'] = this.achievementsUpdatedBy;
    data['achievements_updated_at'] = this.achievementsUpdatedAt;
    data['comment_updated_by'] = this.commentUpdatedBy;
    data['comment_updated_at'] = this.commentUpdatedAt;
    data['team_name'] = this.teamName;
    data['user_name'] = this.userName;
    data['manager_status'] = this.isManager;
    data['attachments'] = this.attachments;
    return data;
  }
}
