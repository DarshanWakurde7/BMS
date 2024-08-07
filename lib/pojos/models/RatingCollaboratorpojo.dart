class collaboratorsList {
  String? name;
  int? projectTaskId;
  int? projectId;
  int? assigneeId;
  int? collaboratorId;
  String? displayName;
  int? lkFeedbackId;
  int? smileyId;
  String? comment;
  String? fieldName;

  collaboratorsList(
      {this.name,
      this.projectTaskId,
      this.projectId,
      this.assigneeId,
      this.collaboratorId,
      this.displayName,
      this.lkFeedbackId,
      this.smileyId,
      this.comment,
      this.fieldName});

  collaboratorsList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    projectTaskId = json['project_task_id'];
    projectId = json['project_id'];
    assigneeId = json['assignee_id'];
    collaboratorId = json['collaborator_id'];
    displayName = json['display_name'];
    lkFeedbackId = json['lk_feedback_id'];
    smileyId = json['smiley_id'];
    comment = json['comment'];
    fieldName = json['field_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['project_task_id'] = this.projectTaskId;
    data['project_id'] = this.projectId;
    data['assignee_id'] = this.assigneeId;
    data['collaborator_id'] = this.collaboratorId;
    data['display_name'] = this.displayName;
    data['lk_feedback_id'] = this.lkFeedbackId;
    data['smiley_id'] = this.smileyId;
    data['comment'] = this.comment;
    data['field_name'] = this.fieldName;
    return data;
  }
}
