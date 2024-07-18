class Taskdropdown {
  int? taskTypeId;
  String? taskType;

  Taskdropdown({this.taskTypeId, this.taskType});

  Taskdropdown.fromJson(Map<String, dynamic> json) {
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