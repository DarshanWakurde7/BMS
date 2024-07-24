import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewTaskPage extends StatefulWidget {
  final int projectId;

  ViewTaskPage({required this.projectId});

  @override
  _ViewTaskPageState createState() => _ViewTaskPageState();
}

class _ViewTaskPageState extends State<ViewTaskPage> {
  String _statusGroupId = '1';
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final url =
        'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_tasks_by_project';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'account_id': '1100',
        'project_id': widget.projectId,
        'status_group_id': _statusGroupId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _tasks = json.decode(response.body);
      });
    } else {
      // Handle errors
      print('Failed to load tasks');
    }
  }

  void _onFilterChanged(String statusGroupId) {
    setState(() {
      _statusGroupId = statusGroupId;
      _fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              children: [
                _buildFilterButtons(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _tasks.isNotEmpty
                          ? _tasks
                              .map<Widget>((task) => _buildTaskCard(task))
                              .toList()
                          : [Text('No tasks available')],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFilterButton('Active', '1'),
            SizedBox(width: 8),
            _buildFilterButton('Hold', '3'),
            SizedBox(width: 8),
            _buildFilterButton('Review', '4'),
            SizedBox(width: 8),
            _buildFilterButton('Complete', '5'),
            SizedBox(width: 8),
            _buildFilterButton('Clear', '7'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String statusGroupId) {
    return ElevatedButton(
      onPressed: () => _onFilterChanged(statusGroupId),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _statusGroupId == statusGroupId ? Colors.blue : Colors.white,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Task Name', task['task_name'] ?? 'N/A'),
                _buildTwoColumnRow('Task Status', task['status'] ?? 'N/A',
                    'Task Type', task['task_type_name'] ?? 'N/A'),
                _buildTwoColumnRow(
                    'Task Category',
                    task['task_category_name'] ?? 'N/A',
                    'Assignee',
                    task['assinged_name'] ?? 'N/A'),
                _buildTwoColumnRow(
                    'Plan Start Date',
                    task['plan_start_date'] ?? 'N/A',
                    'Plan End Date',
                    task['plan_end_date'] ?? 'N/A'),
                _buildTwoColumnRow(
                    'Act Start Date',
                    task['act_start_date'] ?? 'N/A',
                    'Act End Date',
                    task['act_end_date'] ?? 'N/A'),
                _buildTwoColumnRow(
                    'Est Effort',
                    task['est_efforts']?.toString() ?? 'N/A',
                    'Act Effort',
                    task['act_efforts']?.toString() ?? 'N/A'),
                _buildDetailRow(
                    'Collaborators', task['collaborators_name'] ?? 'N/A'),
                _buildDetailRow('Last Comment', task['task_desc'] ?? 'N/A'),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Text(
              task['priority_name'] ?? 'N/A',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnRow(
      String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label1:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value1,
                    style: TextStyle(fontSize: 10.8),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label2:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value2,
                    style: TextStyle(fontSize: 10.5),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityRow(String priority) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        SizedBox(width: 8),
        Text(
          priority,
          style: TextStyle(
            fontSize: 12,
            color: Colors.redAccent, // Customize as needed
          ),
        ),
      ],
    );
  }
}
