import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/Dialogs.dart';
import 'package:bms/Screens/ViewTask.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Projects'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Add Project'),
              Tab(text: 'Show Projects'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AddProject(),
            ProjectManagementScreen(),
          ],
        ),
      ),
    );
  }
}

class AddProject extends StatefulWidget {
  @override
  _AddProjectState createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variables for dropdowns
  String? _projectType;
  String? _projectOwner;
  String? _customer;
  String? _projectStatus;
  String? _priority;
  int? userId;

  // Date variables
  DateTime esStart = DateTime.now();
  DateTime esEnd = DateTime.now();
  DateTime planStart = DateTime.now();
  DateTime planEnd = DateTime.now();
  DateTime actStart = DateTime.now();
  DateTime actEnd = DateTime.now();
  List<Map<String, dynamic>> _projectTypes = [];
  List<Map<String, dynamic>> _projectOwners = [];
  List<Map<String, dynamic>> _projectCompanies = [];
  List<Map<String, dynamic>> _projectStatuses = [];
  List<Map<String, dynamic>> _projectPriority = [];
  @override
  void initState() {
    super.initState();
    _loadProjectTypes();
    _loadProjectOwners();
    _loadProjectCompanies();
    _loadProjectStatus();
    _loadProjectPriority();
    _loadUserId();
  }

  Future<void> _loadProjectTypes() async {
    try {
      final projectTypes = await ApiCalls.fetchProjectTypes('1100');
      setState(() {
        _projectTypes = projectTypes;
      });
    } catch (e) {
      print('Error fetching project types: $e');
    }
  }

  Future<void> _loadProjectOwners() async {
    try {
      final projectOwners = await ApiCalls.fetchProjectOwners('1100');
      setState(() {
        _projectOwners = projectOwners;
      });
    } catch (e) {
      print('Error fetching project owners: $e');
    }
  }

  Future<void> _loadProjectCompanies() async {
    try {
      final projectCompanies = await ApiCalls.fetchCompanies('1100');
      setState(() {
        _projectCompanies = projectCompanies;
      });
    } catch (e) {
      print('Error fetching project companies: $e');
    }
  }

  Future<void> _loadProjectStatus() async {
    try {
      final projectStatus = await ApiCalls.fetchProjectStatus('1100');
      setState(() {
        _projectStatuses = projectStatus;
      });
    } catch (e) {
      print('Error fetching project status: $e');
    }
  }

  Future<void> _loadProjectPriority() async {
    try {
      final projectPriority = await ApiCalls.fetchPriority();
      setState(() {
        _projectPriority = projectPriority;
      });
    } catch (e) {
      print('Error fetching project priority: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final projectData = {
        'account_id': '1100',
        'act_end_date': actEnd.toIso8601String(),
        'act_start_date': actStart.toIso8601String(),
        'company_id': int.parse(_customer ?? '0'),
        'created_by': userId,
        'description': _descriptionController.text,
        'est_end_date': esEnd.toIso8601String(),
        'est_start_date': esStart.toIso8601String(),
        'final_delivery_date': '',
        'plan_end_date': planEnd.toIso8601String(),
        'plan_start_date': planStart.toIso8601String(),
        'pm_user_id': int.parse(_projectOwner ?? '0'),
        'priority_id': int.parse(_priority ?? '0'),
        'project_code': _projectCodeController.text,
        'project_name': _projectNameController.text,
        'project_status': int.parse(_projectStatus ?? '0'),
        'project_type': int.parse(_projectType ?? '0'),
        'release_id': '',
      };
      try {
        final success = await ApiCalls.addProject(projectData);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Project added successfully')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to add project')));
        }
      } catch (e) {
        print('Error submitting form: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('An error occurred')));
      }
    }
  }

  // Helper function to select date
  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) onDateSelected(picked);
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Card(
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _projectNameController,
                        decoration: InputDecoration(labelText: 'Project Name '),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter project name';
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              menuMaxHeight: 300,
                              value: _projectType,
                              decoration: InputDecoration(
                                labelText: 'Project Type',
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              items: _projectTypes.map((projectType) {
                                return DropdownMenuItem<String>(
                                  value:
                                      projectType['project_type_id'].toString(),
                                  child: Text(
                                    projectType['project_type'],
                                    overflow: TextOverflow.visible,
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _projectType = newValue;
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return _projectTypes.map((projectType) {
                                  return DropdownMenuItem<String>(
                                    value: projectType['project_type_id']
                                        .toString(),
                                    child: Text(
                                      projectType['project_type'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              menuMaxHeight: 300,
                              value: _projectOwner,
                              decoration: InputDecoration(
                                labelText: 'Project Owner',
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              items: _projectOwners.map((owner) {
                                return DropdownMenuItem<String>(
                                  value: owner['user_id'].toString(),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${owner['first_name']} ${owner['last_name']}',
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _projectOwner = newValue;
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return _projectOwners.map((owner) {
                                  return DropdownMenuItem<String>(
                                    value: owner['user_id'].toString(),
                                    child: Text(
                                      '${owner['first_name']} ${owner['last_name']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              menuMaxHeight: 300,
                              value: _customer,
                              decoration: InputDecoration(
                                labelText: 'Customer',
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              items: _projectCompanies.map((projectCompanies) {
                                return DropdownMenuItem<String>(
                                  value:
                                      projectCompanies['company_id'].toString(),
                                  child: Text(
                                    projectCompanies['company_name'] ??
                                        'Unknown Company',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _customer = newValue;
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return _projectCompanies
                                    .map((projectCompanies) {
                                  return DropdownMenuItem<String>(
                                    value: projectCompanies['company_id']
                                        .toString(),
                                    child: Text(
                                      projectCompanies['company_name'] ??
                                          'Unknown Company',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              menuMaxHeight: 300,
                              value: _projectStatus,
                              decoration: InputDecoration(
                                labelText: 'Project Status',
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                              ),
                              items: _projectStatuses.map((projectStatus) {
                                return DropdownMenuItem<String>(
                                  value: projectStatus['project_status_id']
                                      .toString(),
                                  child: Text(
                                    projectStatus['project_status'] ??
                                        'Unknown Status',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _projectStatus = newValue;
                                });
                              },
                              selectedItemBuilder: (BuildContext context) {
                                return _projectStatuses.map((projectStatus) {
                                  return DropdownMenuItem<String>(
                                    value: projectStatus['project_status_id']
                                        .toString(),
                                    child: Text(
                                      projectStatus['project_status'] ??
                                          'Unknown Status',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _priority,
                              decoration:
                                  InputDecoration(labelText: 'Priority'),
                              items: _projectPriority.map((projectPriority) {
                                return DropdownMenuItem<String>(
                                  value:
                                      projectPriority['priority_id'].toString(),
                                  child: Text(
                                    projectPriority['priority'] ??
                                        'Unknown Priority',
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _priority = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _projectCodeController,
                              decoration:
                                  InputDecoration(labelText: 'Project Code'),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: TextFormField(
                              controller: TextEditingController(),
                              decoration:
                                  InputDecoration(labelText: 'Release ID'),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Card(
                color: Colors.white,
                elevation: 14,
                child: Container(
                  margin: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Table(
                    border: const TableBorder(
                      horizontalInside: BorderSide(color: Colors.black),
                    ),
                    children: [
                      const TableRow(children: [
                        Padding(
                            padding: EdgeInsets.all(10), child: Text("Date")),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text("Start Date")),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text("End Date")),
                      ]),
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.all(5), child: Text("Est")),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GetDatePicker(
                            getselectedate: esStart,
                            getexacttime: (date) {
                              setState(() {
                                esStart = date;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GetDatePicker(
                            getselectedate: esEnd,
                            getexacttime: (date) {
                              setState(() {
                                esEnd = date;
                              });
                            },
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.all(5), child: Text("Plan")),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GetDatePicker(
                            getselectedate: planStart,
                            getexacttime: (date) {
                              setState(() {
                                planStart = date;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GetDatePicker(
                            getselectedate: planEnd,
                            getexacttime: (date) {
                              setState(() {
                                planEnd = date;
                              });
                            },
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.all(5), child: Text("Actual")),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GetDatePicker(
                            getselectedate: actStart,
                            getexacttime: (date) {
                              setState(() {
                                actStart = date;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: GetDatePicker(
                            getselectedate: actEnd,
                            getexacttime: (date) {
                              setState(() {
                                actEnd = date;
                              });
                            },
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Add'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40),
                      backgroundColor: Colors.white,
                      textStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40),
                      backgroundColor: Colors.white,
                      textStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('_projectType', _projectType));
  }
}

class GetDatePicker extends StatefulWidget {
  GetDatePicker({required this.getselectedate, required this.getexacttime});
  DateTime getselectedate;
  Function(DateTime) getexacttime;

  @override
  State<StatefulWidget> createState() {
    return GetDatePickerState();
  }
}

class GetDatePickerState extends State<GetDatePicker> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? datetime = await showDatePicker(
            context: context,
            firstDate: DateTime(1000),
            lastDate: DateTime(3000));
        setState(() {
          widget.getselectedate = datetime ?? DateTime.now();
        });
        widget.getexacttime(widget.getselectedate);
      },
      child: Text(
        widget.getselectedate.day.toString() +
            "/" +
            widget.getselectedate.month.toString() +
            "/" +
            widget.getselectedate.year.toString(),
        style:
            TextStyle(fontSize: 12, color: Color.fromARGB(255, 10, 125, 182)),
      ),
    );
  }
}

class ProjectManagementScreen extends StatefulWidget {
  @override
  _ProjectManagementScreenState createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  List<dynamic> allProjects = [];
  List<dynamic> filteredProjects = [];
  bool isLoading = false;
  int selectedStatusGroupId = 2;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProjects(selectedStatusGroupId);
    searchController.addListener(_filterProjects);
  }

  Future<void> fetchProjects(int statusGroupId) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<dynamic> data = await ApiCalls.fetchProjects(statusGroupId);
      setState(() {
        allProjects = data;
        filteredProjects = allProjects;
        selectedStatusGroupId = statusGroupId;
      });
    } catch (e) {
      print('Failed to load projects: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProjects() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProjects = allProjects.where((project) {
        return project['project_name']?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterButton(
                      label: 'Active',
                      isSelected: selectedStatusGroupId == 2,
                      onPressed: () => fetchProjects(2)),
                  FilterButton(
                      label: 'Hold',
                      isSelected: selectedStatusGroupId == 3,
                      onPressed: () => fetchProjects(3)),
                  FilterButton(
                      label: 'Review',
                      isSelected: selectedStatusGroupId == 4,
                      onPressed: () => fetchProjects(4)),
                  FilterButton(
                      label: 'Complete',
                      isSelected: selectedStatusGroupId == 5,
                      onPressed: () => fetchProjects(5)),
                  FilterButton(
                      label: 'All',
                      isSelected: selectedStatusGroupId == 7,
                      onPressed: () => fetchProjects(7)),
                ],
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      var project = filteredProjects[index];
                      return ProjectCard(
                        projectName: project['project_name'] ?? '--',
                        projectType: project['project_type'] ?? '--',
                        projectStatus: project['project_status'] ?? '--',
                        projectOwner:
                            '${project['created_fname']} ${project['created_lname']}' ??
                                '--',
                        priority: project['priority']?.toString() ?? '--',
                        estStartDate: project['est_start_date'] ?? '--',
                        estEndDate: project['est_end_date'] ?? '--',
                        planStartDate: project['plan_start_date'] ?? '--',
                        planEndDate: project['plan_end_date'] ?? '--',
                        actStartDate: project['act_start_date'] ?? '--',
                        actEndDate: project['act_end_date'] ?? '--',
                        estEffort:
                            project['total_est_efforts']?.toString() ?? '--',
                        actEffort:
                            project['total_act_efforts']?.toString() ?? '--',
                        finalDeliveryDate:
                            project['final_delivery_date'] ?? '--',
                        projectId: project['project_id'] ?? 0,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  FilterButton(
      {required this.label, required this.isSelected, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.blue,
          backgroundColor: isSelected ? Colors.blue : Colors.white,
        ),
        child: Text(label),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String projectName;
  final String projectType;
  final String projectStatus;
  final String projectOwner;
  final String priority;
  final String estStartDate;
  final String estEndDate;
  final String planStartDate;
  final String planEndDate;
  final String actStartDate;
  final String actEndDate;
  final String estEffort;
  final String actEffort;
  final String finalDeliveryDate;
  final int projectId; // Add projectId as a parameter

  ProjectCard({
    required this.projectName,
    required this.projectType,
    required this.projectStatus,
    required this.projectOwner,
    required this.priority,
    required this.estStartDate,
    required this.estEndDate,
    required this.planStartDate,
    required this.planEndDate,
    required this.actStartDate,
    required this.actEndDate,
    required this.estEffort,
    required this.actEffort,
    required this.finalDeliveryDate,
    required this.projectId, // Initialize projectId
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 206, 236, 255),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildInfoRow(Icons.code, projectType),
            _buildInfoRow(Icons.sync, projectStatus),
            _buildInfoRow(Icons.person, projectOwner),
            _buildInfoRow(Icons.priority_high, ' $priority'),
            _buildDateTable(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.hourglass_empty),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ViewTaskPage(
                          projectId: projectId,
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.people),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return EmployeeDialog(
                          projectId:
                              projectId, // Pass projectId to EmployeeDialog
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTable() {
    return Table(
      children: [
        TableRow(
          children: [
            _buildTableHeader('Date Type'),
            _buildTableHeader('Start Date'),
            _buildTableHeader('End Date'),
          ],
        ),
        _buildDateTableRow('Estimated', estStartDate, estEndDate),
        _buildDateTableRow('Planned', planStartDate, planEndDate),
        _buildDateTableRow('Actual', actStartDate, actEndDate),
      ],
    );
  }

  TableRow _buildDateTableRow(String label, String startDate, String endDate) {
    return TableRow(
      children: [
        _buildTableCell(label),
        _buildTableCell(startDate),
        _buildTableCell(endDate),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Color.fromARGB(255, 167, 200, 227),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// class EmployeeDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.9,
//         height: MediaQuery.of(context).size.height * 0.7,
//         padding: EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             DropdownButtonFormField<String>(
//               hint: Text('Select Employee'),
//               items: <String>['Employee 1', 'Employee 2', 'Employee 3']
//                   .map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value, style: TextStyle(fontSize: 14)),
//                 );
//               }).toList(),
//               onChanged: (String? value) {
//                 // Handle dropdown value change
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//               ),
//             ),
//             SizedBox(height: 10),
//             // Divider(height: 10, color: Colors.grey),
//             Text(
//               'Employee List:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: DataTable(
//                 columnSpacing: 10,
//                 headingRowHeight: 32,
//                 dataRowHeight: 32,
//                 columns: [
//                   DataColumn(
//                       label: Text('Name', style: TextStyle(fontSize: 14))),
//                   DataColumn(
//                       label: Text('Position', style: TextStyle(fontSize: 14))),
//                   DataColumn(
//                       label: Text('Status', style: TextStyle(fontSize: 14))),
//                   DataColumn(
//                       label: Text('Actions', style: TextStyle(fontSize: 14))),
//                 ],
//                 rows: [
//                   DataRow(cells: [
//                     DataCell(Text('Shreyas Kulkarni',
//                         style: TextStyle(fontSize: 12))),
//                     DataCell(Text('Software Developer',
//                         style: TextStyle(fontSize: 12))),
//                     DataCell(Text('Active', style: TextStyle(fontSize: 12))),
//                     DataCell(
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.delete, size: 16),
//                             onPressed: () {
//                               // Handle delete action
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ]),
//                   // Add more DataRow widgets as needed
//                 ],
//               ),
//             ),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle add button action
//                   },
//                   child: Text('Add', style: TextStyle(fontSize: 14)),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
