import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/TeamDashboard.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceReportPage extends StatefulWidget {
  @override
  _AttendanceReportPageState createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 20));
  List<Map<String, dynamic>> attendanceData = [];
  bool _isLoading = false;
  DatePickerController _dateController = DatePickerController();
  late TabController _tabController;
  String? _selectedUserId;
  String? _selectedTeamId;
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _teams = []; // To store fetched teams
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchEmployees();
    fetchTeams(); // Fetch teams
    fetchAttendanceData(_selectedDate, _selectedUserId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dateController.animateToDate(_selectedDate);
    });
  }

  Future<void> fetchEmployees() async {
    try {
      final employees = await ApiCalls.fetchEmployeesDropdown('1100');
      setState(() {
        _employees = employees;
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  Future<void> fetchTeams() async {
    try {
      // Retrieve user_id and role_id from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;
      int roleId = prefs.getInt('role_id') ?? 0;

      final response = await ApiCalls.fetchTeams();
      setState(() {
        _teams = response;
      });
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  Future<void> fetchAttendanceData(DateTime date, String? teamId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Map<String, dynamic>> data =
          await ApiCalls.fetchAttendance(date, teamId);
      setState(() {
        attendanceData = data;
      });
      print('Fetched Attendance Data: $attendanceData');
    } catch (e) {
      print('Failed to load attendance data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void onEmployeeSelected(String? selectedTeamId) {
    setState(() {
      _selectedTeamId = selectedTeamId;
    });

    fetchAttendanceData(_selectedDate, _selectedTeamId);
  }

  void _onDateChange(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    fetchAttendanceData(date, _selectedUserId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Attendance Report'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Attendance Log'),
              Tab(text: 'Team Dashboard'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Attendance Log Tab
            Navigator(
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) {
                    return Scaffold(
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 100,
                            margin: const EdgeInsets.symmetric(vertical: 16.0),
                            child: DatePicker(
                              _startDate,
                              initialSelectedDate: _selectedDate,
                              selectionColor: Colors.blue,
                              selectedTextColor: Colors.white,
                              daysCount: 365,
                              controller: _dateController,
                              onDateChange: (date) {
                                _onDateChange(date);
                                print('Selected date: $date');
                              },
                            ),
                          ),
                          // Team Dropdown

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: DropdownButtonFormField<String>(
                              value: _selectedTeamId,
                              hint: Text('Select Team'),
                              items: _teams.map((team) {
                                return DropdownMenuItem<String>(
                                  value: team['team_id'].toString(),
                                  child: Text(team['team_name']),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTeamId = newValue;
                                });
                                print('Selected team ID: $_selectedTeamId');

                                // Fetch attendance data for the selected team
                                fetchAttendanceData(
                                    _selectedDate, _selectedTeamId);
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.blue, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.blue, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 82, 76, 76),
                                      width: 2),
                                ),
                              ),
                            ),
                          ),

                          _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Expanded(
                                  child: attendanceData.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No data found',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black54),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.all(8.0),
                                          itemCount: attendanceData.length,
                                          itemBuilder: (context, index) {
                                            final attendance =
                                                attendanceData[index];
                                            return Card(
                                              color: Color.fromARGB(
                                                  255, 206, 236, 255),
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      attendance['username'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text('Punch In'),
                                                            Text(
                                                              attendance[
                                                                      'punchInTime'] ??
                                                                  '--',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text('Punch Out'),
                                                            Text(
                                                              attendance[
                                                                      'punchOutTime'] ??
                                                                  '--',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text('Total Hours'),
                                                            Text(
                                                              attendance[
                                                                      'totalHours'] ??
                                                                  '--',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // Team Dashboard Tab
            Navigator(
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) {
                    return TeamDashboardPage();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
