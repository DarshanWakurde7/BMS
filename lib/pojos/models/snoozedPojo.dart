import 'package:bms/pojos/models/CardPojodata.dart';

class SnozzedClassPojo {
  int? accountId;
  int? projectTaskId;
  int? projectId;
  int? phaseId;
  String? taskName;
  int? taskCategory;
  int? billable;
  int? invoiced;
  int? focus;
  String? estStartDate;
  String? estEndDate;
  String? planStartDate;
  String? planEndDate;
  String? actStartDate;
  String? actEndDate;
  int? taskStatus;
  int? priorityId;
  int? sequence;
  int? assingedTo;
  String? collaboratorsId;
  String? estEfforts;
  int? taskType;
  String? dueDate;
  String? snoozeTask;
  String? snoozeDate;
  int? extEfforts;
  int? actEfforts;
  String? editMode;
  int? createdBy;
  String? createdAt;
  int? updatedBy;
  String? updatedAt;
  int? attachment;
  String? taskDesc;
  int? refProjectTaskId;
  String? reportedDate;
  String? reportedTime;
  String? startTime;
  String? endTime;
  String? assingedName;
  String? taskStatusGroup;
  String? myEfforts;
  String? allEfforts;
  String? projectName;
  String? priorityName;
  List<Collaborators>? collaborators;
  String? status;
  int? statusGroup;

  SnozzedClassPojo(
      {this.accountId,
      this.projectTaskId,
      this.projectId,
      this.phaseId,
      this.taskName,
      this.taskCategory,
      this.billable,
      this.invoiced,
      this.focus,
      this.estStartDate,
      this.estEndDate,
      this.planStartDate,
      this.planEndDate,
      this.actStartDate,
      this.actEndDate,
      this.taskStatus,
      this.priorityId,
      this.sequence,
      this.assingedTo,
      this.collaboratorsId,
      this.estEfforts,
      this.taskType,
      this.dueDate,
      this.snoozeTask,
      this.snoozeDate,
      this.extEfforts,
      this.actEfforts,
      this.editMode,
      this.createdBy,
      this.createdAt,
      this.updatedBy,
      this.updatedAt,
      this.attachment,
      this.taskDesc,
      this.refProjectTaskId,
      this.reportedDate,
      this.reportedTime,
      this.startTime,
      this.endTime,
      this.assingedName,
      this.taskStatusGroup,
      this.myEfforts,
      this.allEfforts,
      this.projectName,
      this.priorityName,
      this.collaborators,
      this.status,
      this.statusGroup});

  SnozzedClassPojo.fromJson(Map<String, dynamic> json) {
    accountId = json['account_id'];
    projectTaskId = json['project_task_id'];
    projectId = json['project_id'];
    phaseId = json['phase_id'];
    taskName = json['task_name'];
    taskCategory = json['task_category'];
    billable = json['billable'];
    invoiced = json['invoiced'];
    focus = json['focus'];
    estStartDate = json['est_start_date'];
    estEndDate = json['est_end_date'];
    planStartDate = json['plan_start_date'];
    planEndDate = json['plan_end_date'];
    actStartDate = json['act_start_date'];
    actEndDate = json['act_end_date'];
    taskStatus = json['task_status'];
    priorityId = json['priority_id'];
    sequence = json['sequence'];
    assingedTo = json['assinged_to'];
    collaboratorsId = json['collaborators_id'];
    estEfforts = json['est_efforts'];
    taskType = json['task_type'];
    dueDate = json['due_date'];
    snoozeTask = json['snooze_task'];
    snoozeDate = json['snooze_date'];
    extEfforts = json['ext_efforts'];
    actEfforts = json['act_efforts'];
    editMode = json['edit_mode'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    attachment = json['attachment'];
    taskDesc = json['task_desc'];
    refProjectTaskId = json['ref_project_task_id'];
    reportedDate = json['reported_date'];
    reportedTime = json['reported_time'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    assingedName = json['assinged_name'];
    taskStatusGroup = json['task_status_group'];
    myEfforts = json['my_efforts'];
    allEfforts = json['all_efforts'];
    projectName = json['project_name'];
    priorityName = json['priority_name'];
    if (json['collaborators'] != null) {
      collaborators = <Collaborators>[];
      json['collaborators'].forEach((v) {
        collaborators!.add(new Collaborators.fromJson(v));
      });
    }
    status = json['status'];
    statusGroup = json['status_group'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_id'] = this.accountId;
    data['project_task_id'] = this.projectTaskId;
    data['project_id'] = this.projectId;
    data['phase_id'] = this.phaseId;
    data['task_name'] = this.taskName;
    data['task_category'] = this.taskCategory;
    data['billable'] = this.billable;
    data['invoiced'] = this.invoiced;
    data['focus'] = this.focus;
    data['est_start_date'] = this.estStartDate;
    data['est_end_date'] = this.estEndDate;
    data['plan_start_date'] = this.planStartDate;
    data['plan_end_date'] = this.planEndDate;
    data['act_start_date'] = this.actStartDate;
    data['act_end_date'] = this.actEndDate;
    data['task_status'] = this.taskStatus;
    data['priority_id'] = this.priorityId;
    data['sequence'] = this.sequence;
    data['assinged_to'] = this.assingedTo;
    data['collaborators_id'] = this.collaboratorsId;
    data['est_efforts'] = this.estEfforts;
    data['task_type'] = this.taskType;
    data['due_date'] = this.dueDate;
    data['snooze_task'] = this.snoozeTask;
    data['snooze_date'] = this.snoozeDate;
    data['ext_efforts'] = this.extEfforts;
    data['act_efforts'] = this.actEfforts;
    data['edit_mode'] = this.editMode;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['attachment'] = this.attachment;
    data['task_desc'] = this.taskDesc;
    data['ref_project_task_id'] = this.refProjectTaskId;
    data['reported_date'] = this.reportedDate;
    data['reported_time'] = this.reportedTime;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['assinged_name'] = this.assingedName;
    data['task_status_group'] = this.taskStatusGroup;
    data['my_efforts'] = this.myEfforts;
    data['all_efforts'] = this.allEfforts;
    data['project_name'] = this.projectName;
    data['priority_name'] = this.priorityName;
    if (this.collaborators != null) {
      data['collaborators'] =
          this.collaborators!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['status_group'] = this.statusGroup;
    return data;
  }
}
