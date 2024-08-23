import 'dart:convert';

import 'package:bms/ApiCalls/apiCalls.dart';

import 'package:bms/widgets/searchable_dropdown.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bms/widgets/searchable_dropdown.dart';

class ViewTask extends StatefulWidget {
  ViewTask(
      {super.key,
      required this.title,
      required this.accid,
      required this.projecid});
  String title;
  int accid, projecid;

  @override
  State<StatefulWidget> createState() {
    return AddTaskState();
  }
}

class AddTaskState extends State<ViewTask> {
  bool _isLoading = false;
  DateTime esStart = DateTime(0000, 1, 1);
  DateTime esEnd = DateTime(0000, 1, 1);
  DateTime planStart = DateTime(0000, 1, 1);
  DateTime planEnd = DateTime(0000, 1, 1);
  DateTime actStart = DateTime(0000, 1, 1);
  DateTime actEnd = DateTime(0000, 1, 1);

  List<int> proid = [];
  var textTtile = TextEditingController();
  var taskArea = TextEditingController();
  var esTime = TextEditingController();
  var editingtext = QuillController.basic();
  late bool checkEdit;
  bool getbill = false;
  bool invoiced = false;
  bool focus = false;
  List<ValueItem<int>> assignedtp = [];

  String Status = "Status";
  String priority = "Priority";
  String category = "Category";
  String task = "task";
  String assigne = "Assignee";

  String collaborator = "collaborator";
  FocusNode esTimeFocusNode = FocusNode();
  int assingnid = 0;
  int categoryid = 0;
  int priorityid = 0;
  int statusid = 0;
  int taskTypeid = 0;
  List<Map<String, dynamic>> projectList = [];
  String? selectedProject;
  bool showDropdown = false;
  List<Map<String, dynamic>> filteredItems = [];
  final FocusNode taskAreaNode = FocusNode();

  @override
  void initState() {
    getApis();
    proid.add(widget.projecid);
    setState(() {
      textTtile.text = widget.title;
    });
    checkEdit = false;
    getbill = false;
    super.initState();
    fetchProjectList();
    fetchProjectList();
  }

  @override
  void dispose() {
    taskArea.dispose();
    taskAreaNode.dispose();
    super.dispose();
  }

  void getApis() async {
    await ApiCalls.gettaskByUser(widget.accid);
    await ApiCalls.getCollborators(widget.accid, widget.projecid);
    await ApiCalls.getCollborators(widget.accid, widget.projecid);
// await ApiCalls.getUsersByTask(widget.accid,proid);
    await ApiCalls.gettaskCategory(widget.accid);
    await ApiCalls.getStatus(widget.accid);
  }

  String getHtmlFromQuillController(QuillController controller) {
    final delta = controller.document.toDelta();
    return deltaToHtml(delta);
  }

  Future<void> fetchProjectList() async {
    final response = await http.post(
      Uri.parse(
          'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_project_list'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"account_id": "1100"}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        projectList = data.map((project) {
          return {
            'project_name': project['project_name'],
            'project_id': project['project_id'],
          };
        }).toList();
        // Initialize filteredItems with the full list
        filteredItems = List.from(projectList);
        print(filteredItems);
      });
    } else {
      throw Exception('Failed to load project list');
    }
  }

  void handleTextChange(String value) {
    setState(() {
      showDropdown = value.isNotEmpty && checkEdit;
      filteredItems = projectList
          .where((project) => project['project_name']
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "View Task",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                        controller: textTtile,
                        decoration: InputDecoration(
                          hintText: widget.title,
                          hintStyle: TextStyle(fontSize: 18),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12.0),
                        ),
                        enabled: false,
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Stack(
                      children: [
                        QuillEditor.basic(
                          configurations: QuillEditorConfigurations(
                              controller: editingtext),
                          focusNode: FocusNode(),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      child: QuillToolbar.simple(
                                        configurations:
                                            QuillSimpleToolbarConfigurations(
                                          controller: editingtext,
                                          showFontFamily: false,
                                          showUndo: false,
                                          showRedo: false,
                                          showSearchButton: false,
                                          showHeaderStyle: false,
                                          showBackgroundColorButton: false,
                                          showColorButton: false,
                                          showSubscript: false,
                                          showSuperscript: false,
                                          sharedConfigurations:
                                              const QuillSharedConfigurations(
                                            locale: Locale('de'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 206, 236, 255),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Est. Effort: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      focusNode: esTimeFocusNode,
                                      keyboardType: TextInputType.number,
                                      controller: esTime,
                                      decoration: InputDecoration(
                                        hintText: "0",
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 8.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Actual Effort: 00",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              _buildCheckbox("Billable", getbill, (val) {
                                setState(() {
                                  getbill = val ?? false;
                                });
                              }),
                              _buildCheckbox("Invoiced", invoiced, (val) {
                                setState(() {
                                  invoiced = val ?? false;
                                });
                              }),
                              _buildCheckbox("Focus", focus, (val) {
                                setState(() {
                                  focus = val ?? false;
                                });
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SearchableDropdown(
                              hint: "Category",
                              items: myCategories
                                  .map((item) => item.taskCategory ?? "")
                                  .toList(),
                              selectedItem: category,
                              onChanged: (selectedCategory) {
                                setState(() {
                                  category = selectedCategory;
                                  categoryid = myCategories
                                          .firstWhere(
                                            (category) =>
                                                selectedCategory ==
                                                (category.taskCategory ?? ""),
                                          )
                                          .taskCategoryId ??
                                      0;
                                });
                                print(selectedCategory);
                              },
                              itemBuilder: (context, item) =>
                                  DropdownMenuItem<String>(
                                value: item,
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SearchableDropdown(
                              hint: "Priority",
                              items: myprority
                                  .map((item) => item.priority ?? "")
                                  .toList(),
                              selectedItem: priority,
                              onChanged: (selectedPriority) {
                                setState(() {
                                  priority = selectedPriority;
                                  priorityid = myprority
                                          .firstWhere(
                                            (priority) =>
                                                selectedPriority ==
                                                (priority.priority ?? ""),
                                          )
                                          .priorityId ??
                                      0;
                                });
                                print(selectedPriority);
                              },
                              itemBuilder: (context, item) =>
                                  DropdownMenuItem<String>(
                                value: item,
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SearchableDropdown(
                              hint: "Assign To",
                              items: collboraotrs
                                  .map((item) =>
                                      "${item.firstName ?? ""} ${item.lastName ?? ""}")
                                  .toList(),
                              selectedItem: assigne,
                              onChanged: (selectedAssignee) {
                                setState(() {
                                  assigne = selectedAssignee;
                                  assingnid = collboraotrs
                                          .firstWhere(
                                            (assignee) =>
                                                selectedAssignee ==
                                                ("${assignee.firstName ?? ""} ${assignee.lastName ?? ""}"),
                                          )
                                          .userId ??
                                      0;
                                });
                                print(selectedAssignee);
                              },
                              itemBuilder: (context, item) =>
                                  DropdownMenuItem<String>(
                                value: item,
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SearchableDropdown(
                              hint: "Status",
                              items: myStatus
                                  .map((item) => item.taskStatus ?? "")
                                  .toList(),
                              selectedItem: Status,
                              onChanged: (selectedStatus) {
                                setState(() {
                                  Status = selectedStatus;
                                  statusid = myStatus
                                          .firstWhere(
                                            (status) =>
                                                selectedStatus ==
                                                (status.taskStatus ?? ""),
                                          )
                                          .taskStatusId ??
                                      0;
                                });
                                print(selectedStatus);
                              },
                              itemBuilder: (context, item) =>
                                  DropdownMenuItem<String>(
                                value: item,
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SearchableDropdown(
                              hint: "Task Type",
                              items: getTasks
                                  .map((item) => item.taskType ?? "")
                                  .toList(),
                              selectedItem: task,
                              onChanged: (selectedTask) {
                                setState(() {
                                  task = selectedTask;
                                  taskTypeid = getTasks
                                          .firstWhere(
                                            (taskType) =>
                                                selectedTask ==
                                                (taskType.taskType ?? ""),
                                          )
                                          .taskTypeId ??
                                      0;
                                });
                                print(selectedTask);
                              },
                              itemBuilder: (context, item) =>
                                  DropdownMenuItem<String>(
                                value: item,
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            //color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: MultiSelectDropDown(
                            searchEnabled: true,
                            padding: EdgeInsets.all(10),
                            onOptionSelected: (value) {
                              setState(() {
                                assignedtp = value;
                              });
                            },
                            options: collboraotrs
                                .map((e) => ValueItem(
                                      label:
                                          "${e.firstName ?? ""} ${e.lastName ?? ""}",
                                      value: e.userId,
                                    ))
                                .toList(),
                          ),
                        )),
                      ],
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 14,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Table(
                          border: const TableBorder(
                              horizontalInside:
                                  BorderSide(color: Colors.black)),
                          children: [
                            const TableRow(children: [
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("Date")),
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("Start Date")),
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("End Date")),
                            ]),
                            TableRow(children: [
                              const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text("Est")),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GetDatePicker(
                                    getselectedate: esStart,
                                    getexacttime: (date) {
                                      setState(() {
                                        esStart = date;
                                      });
                                    },
                                  )),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GetDatePicker(
                                    getselectedate: esEnd,
                                    getexacttime: (date) {
                                      setState(() {
                                        esEnd = date;
                                      });
                                    },
                                  )),
                            ]),
                            TableRow(children: [
                              const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text("Plan")),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GetDatePicker(
                                    getselectedate: planStart,
                                    getexacttime: (date) {
                                      setState(() {
                                        planStart = date;
                                      });
                                    },
                                  )),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GetDatePicker(
                                    getselectedate: planEnd,
                                    getexacttime: (date) {
                                      setState(() {
                                        planEnd = date;
                                      });
                                    },
                                  )),
                            ]),
                            TableRow(children: [
                              const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text("Actual")),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GetDatePicker(
                                    getselectedate: actStart,
                                    getexacttime: (date) {
                                      setState(() {
                                        actStart = date;
                                      });
                                    },
                                  )),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GetDatePicker(
                                    getselectedate: actEnd,
                                    getexacttime: (date) {
                                      setState(() {
                                        actEnd = date;
                                      });
                                    },
                                  )),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        OutlinedButton(
                          onPressed: _isLoading ? null : _submitTask,
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.black),
                                ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),

                    //------
                    //------

                    // Text(editingtext.getPlainText().toString()),
                  ]),
            )));
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Future<void> _submitTask() async {
    // Input validation
    if (textTtile.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Task title cannot be empty.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    print(editingtext.plainTextEditingValue.text);
    if (editingtext.plainTextEditingValue.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Task description cannot be empty.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    print(esStart);
    if (esStart == DateTime.parse("0000-01-01 00:00:00.000") ||
        esEnd == DateTime.parse("0000-01-01 00:00:00.000") ||
        planStart == DateTime.parse("0000-01-01 00:00:00.000") ||
        planEnd == DateTime.parse("0000-01-01 00:00:00.000")) {
      Fluttertoast.showToast(
        msg: "Start and end dates must be selected.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Additional check for actual dates if needed
    if (actStart == null || actEnd == null) {
      // You might choose to include this validation or handle it differently
      // depending on whether actual dates are mandatory for submission.
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final url = Uri.parse(
        'https://portalwiz.net/laravelapi/public/api/add_project_tasks');

    var requestBody = {
      "account_id": "${widget.accid}",
      "project_id": "${widget.projecid}",
      "task_name": taskArea.text.toString(),
      "sequence": "",
      "assinged_to": "${assingnid}",
      "priority_id": "${priorityid}",
      "est_start_date": "${esStart.year}-${esStart.month}-${esStart.day}",
      "est_end_date": "${esEnd.year}-${esEnd.month}-${esEnd.day}",
      "task_status": "${statusid}",
      "plan_start_date":
          "${planStart.year}-${planStart.month}-${planStart.day}",
      "plan_end_date": "${planEnd.year}-${planEnd.month}-${planEnd.day}",
      "act_start_date": actStart != null
          ? "${actStart.year}-${actStart.month}-${actStart.day}"
          : "",
      "act_end_date":
          actEnd != null ? "${actEnd.year}-${actEnd.month}-${actEnd.day}" : "",
      "act_efforts": "",
      "collaborators_id": assignedtp.map((e) => e.value).toList(),
      "created_by": "${sharedPreferences.getInt("user_id")}",
      "est_efforts": "${esTime.text}",
      "task_desc": getHtmlFromQuillController(editingtext),
      "task_category": "${categoryid}",
      "task_type": "${taskTypeid}",
      "focus": false,
      "billable": false,
      "invoiced": true
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Task has been submitted successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        print('Server Error: ${response.statusCode} - ${response.body}');

        Fluttertoast.showToast(
          msg: "Failed to submit task. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print('Exception: $e');

      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class GetDatePicker extends StatefulWidget {
  GetDatePicker({
    required this.getselectedate,
    required this.getexacttime,
  });

  DateTime getselectedate;
  final Function(DateTime) getexacttime;

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
        // Ensure the initialDate is within the valid range
        DateTime initialDate = widget.getselectedate.year < 1000
            ? DateTime.now()
            : widget.getselectedate;

        DateTime? datetime = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(1000),
          lastDate: DateTime(3000),
        );

        if (datetime != null) {
          setState(() {
            widget.getselectedate = datetime;
          });
          widget.getexacttime(datetime);
        }
      },
      child: Text(
        widget.getselectedate.year < 1000
            ? "dd-mm-yyyy"
            : "${widget.getselectedate.day}/${widget.getselectedate.month}/${widget.getselectedate.year}",
        style: TextStyle(
          fontSize: 12,
          color: Color.fromARGB(255, 10, 125, 182),
        ),
      ),
    );
  }
}

String deltaToHtml(Delta delta) {
  final buffer = StringBuffer();

  for (var op in delta.toList()) {
    if (op.isInsert) {
      final insert = op.data;
      if (insert is String) {
        buffer.write(insert); // Plain text
      } else if (insert is Map) {
        // Handle embedded objects like images or custom embeds
        if (insert.containsKey('image')) {
          buffer.write('<img src="${insert['image']}" />');
        }
      }
    } else if (op.isDelete) {
      // Handle delete operations if needed
    } else if (op.isRetain) {
      // Handle retain operations if needed
    }
  }

  return buffer.toString();
}
