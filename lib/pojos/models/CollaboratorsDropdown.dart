class CollaboratorsDropdown {
  int? userId;
  String? firstName;
  String? lastName;
  int? activeStatusId;

  CollaboratorsDropdown(
      {this.userId, this.firstName, this.lastName, this.activeStatusId});

  CollaboratorsDropdown.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    activeStatusId = json['active_status_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['active_status_id'] = this.activeStatusId;
    return data;
  }
}