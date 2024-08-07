import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:flutter_quill/quill_delta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeDialog extends StatefulWidget {
  final int projectId;

  EmployeeDialog({required this.projectId});

  @override
  _EmployeeDialogState createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
  List<Map<String, dynamic>> employeesDropdown = [];
  List<Map<String, dynamic>> employeesTable = [];
  bool isLoading = true;
  List<int> selectedUserIds = [];
  int? selectedProjectId;

  @override
  void initState() {
    super.initState();
    selectedProjectId = widget.projectId;
    fetchDataForDropdown();
    fetchDataForTable();
  }

  Future<void> fetchDataForDropdown() async {
    String apiUrl =
        'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_user';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, String> body = {'account_id': '1100', 'role_id': '1'};

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> parsedData =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          employeesDropdown = parsedData;
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error state
    }
  }

  Future<void> fetchDataForTable() async {
    String apiUrl =
        'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_project_user';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      'account_id': '1100',
      'project_id': selectedProjectId
    };

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print(data);
        List<Map<String, dynamic>> parsedData =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          employeesTable = parsedData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load table data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addUsersToProject() async {
    if (selectedUserIds.isEmpty) {
      return;
    }

    String apiUrl =
        'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/add_project_team';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      'account_id': '1100',
      'project_id': selectedProjectId,
      'user_id': selectedUserIds,
      'created_by': '79'
    };

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success']) {
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Team members added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          fetchDataForTable();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to add team members: ${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add team members.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteUserFromProject(int userId) async {
    String apiUrl =
        'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/delete_project_user';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      'project_id': selectedProjectId,
      'user_id': userId
    };

    try {
      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success']) {
          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          fetchDataForTable();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to delete user: ${responseData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<int>(
                hint: Text('Select Employee'),
                menuMaxHeight: 300,
                items: employeesDropdown.map((employee) {
                  return DropdownMenuItem<int>(
                    value: employee['user_id'],
                    child: Text(
                      '${employee['full_name']}',
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (int? value) {
                  if (value != null && !selectedUserIds.contains(value)) {
                    setState(() {
                      selectedUserIds.add(value);
                    });
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                children: selectedUserIds.map((userId) {
                  var employee = employeesDropdown
                      .firstWhere((e) => e['user_id'] == userId);
                  return Chip(
                    label: Text(employee['full_name']),
                    onDeleted: () {
                      setState(() {
                        selectedUserIds.remove(userId);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Employee List:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : employeesTable.isEmpty
                    ? Center(child: Text('No employees found'))
                    : Expanded(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 100,
                          rightHandSideColumnWidth: 400,
                          isFixedHeader: true,
                          headerWidgets: _buildTableHeader(),
                          leftSideItemBuilder: _buildLeftSideItem,
                          rightSideItemBuilder: _buildRightSideItem,
                          itemCount: employeesTable.length,
                          rowSeparatorWidget: Divider(color: Colors.grey),
                        ),
                      ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addUsersToProject();
                    },
                    child: Text('Add', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTableHeader() {
    return [
      SizedBox(width: 100, child: Text('Name', style: TextStyle(fontSize: 14))),
      SizedBox(
          width: 120, child: Text('Position', style: TextStyle(fontSize: 14))),
      SizedBox(
          width: 80, child: Text('Status', style: TextStyle(fontSize: 14))),
      SizedBox(
          width: 100, child: Text('Actions', style: TextStyle(fontSize: 14))),
    ];
  }

  Widget _buildLeftSideItem(BuildContext context, int index) {
    return Container(
      height: 37,
      child: Center(
        child: Text('${employeesTable[index]['full_name']}',
            style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildRightSideItem(BuildContext context, int index) {
    return Container(
      height: 37,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '${employeesTable[index]['role_name']}',
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
              width: 80,
              child: Text('${employeesTable[index]['status']}',
                  style: TextStyle(fontSize: 14))),
          SizedBox(
            width: 100,
            child: IconButton(
              icon: Icon(Icons.delete, size: 16),
              onPressed: () {
                int userId = employeesTable[index]['user_id'];
                deleteUserFromProject(userId);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CommentDialog extends StatefulWidget {
  final int projectId;

  CommentDialog({required this.projectId});

  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> _filteredComments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _searchController.addListener(_filterComments);
  }

  void _filterComments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredComments = _comments.where((comment) {
        final message = comment['message'].toString().toLowerCase();
        final createdBy =
            (comment['created_fname'] + ' ' + comment['created_lname'])
                .toLowerCase();
        return message.contains(query) || createdBy.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchComments() async {
    final response = await http.post(
      Uri.parse(
          'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_project_comment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account_id': '1100',
        'project_id': widget.projectId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        _comments = responseData
            .map((data) => Map<String, dynamic>.from(data))
            .toList();
        _filteredComments = _comments;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch comments')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      final comment = _commentController.text;
      final response = await http.post(
        Uri.parse(
            'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/add_project_comment_log'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'account_id': '1100',
          'comment_status': '',
          'created_by': userId,
          'message': comment,
          'project_id': widget.projectId,
          'user_id': userId,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        _fetchComments();
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Comment added and notifications sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Add Comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Comments',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredComments.length,
                itemBuilder: (context, index) {
                  final comment = _filteredComments[index];
                  final createdAt = DateTime.parse(comment['created_at']);
                  final formattedDate =
                      "${createdAt.month}/${createdAt.day}/${createdAt.year}, ${createdAt.hour}:${createdAt.minute}";

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${comment['created_fname']} ${comment['created_lname']} Commented On $formattedDate",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(comment['message']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
