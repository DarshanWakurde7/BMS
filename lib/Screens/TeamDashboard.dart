import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/AddEmployees.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TeamDashboardPage extends StatefulWidget {
  @override
  _TeamDashboardPageState createState() => _TeamDashboardPageState();
}

class _TeamDashboardPageState extends State<TeamDashboardPage> {
  late Future<List<Map<String, dynamic>>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = ApiCalls.fetchEmployeesDropdown('1100');
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      final formatter = DateFormat('dd MM yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No employees found.'));
          }

          final teamMembers = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                final member = teamMembers[index];
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 25),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Text(
                                    member['user_name']![0],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  radius: 20,
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${member['user_name']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${member['designation'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    color: Colors.blueAccent, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    member['user_phone'] != null
                                        ? member['user_phone'].toString()
                                        : 'N/A',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.calendar_today,
                                    color: Colors.blueAccent, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Join Date: ${formatDate(member['join_date'])}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _buildDetailRow(
                                'Email:', member['user_email'] ?? 'N/A'),
                            SizedBox(height: 8),
                            _buildDetailRow('Reporting Manager:',
                                member['reporting_manager'] ?? 'N/A'),
                            SizedBox(height: 8),
                            _buildDetailRow('Created By:',
                                member['created_by_name'] ?? 'N/A'),
                            SizedBox(height: 8),
                            _buildDetailRow('Created At:',
                                formatDate(member['created_at'])),
                            SizedBox(height: 8),
                            _buildDetailRow('Updated By:',
                                member['updated_by_name'] ?? 'N/A'),
                            SizedBox(height: 8),
                            _buildDetailRow('Updated At:',
                                formatDate(member['updated_at'])),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 250, 240, 240),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              member['department_name'] ?? 'N/A',
                              style: GoogleFonts.getFont(
                                'Lato',
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 250, 240, 240),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              member['punch_status'] == 1
                                  ? 'Checked In'
                                  : 'Checked Out',
                              style: GoogleFonts.getFont(
                                'Lato',
                                textStyle: TextStyle(
                                  color: member['punch_status'] == 1
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEmployeeScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 140, 178, 215),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
