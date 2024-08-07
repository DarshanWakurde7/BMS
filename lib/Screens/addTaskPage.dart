import 'dart:convert';

import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/widgets/searchable_dropdown.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddTask extends StatefulWidget {
  AddTask(
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

class AddTaskState extends State<AddTask> {
  bool _isLoading = false;
  DateTime esStart = DateTime.now();
  DateTime esEnd = DateTime.now();
  DateTime planStart = DateTime.now();
  DateTime planEnd = DateTime.now();
  DateTime actStart = DateTime.now();
  DateTime actEnd = DateTime.now();
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
  FocusNode _unUsedFocusNode = FocusNode();

  @override
  void initState() {
    getApis();
    proid.add(widget.projecid);

    checkEdit = false;
    getbill = false;
    super.initState();
    fetchProjectList();
  }

  void getApis() async {
    await ApiCalls.gettaskByUser(widget.accid);
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
            "Add Task",
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
                    Stack(
                      children: [
                        TextField(
                          controller: textTtile,
                          decoration: InputDecoration(
                            labelText: "Task Title",
                            hintText: widget.title,
                            hintStyle: TextStyle(fontSize: 18),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 12.0),
                          ),
                          enabled: checkEdit,
                          style: TextStyle(fontSize: 18),
                          onChanged: handleTextChange,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                                checkEdit ? Icons.check_circle : Icons.edit),
                            onPressed: () {
                              setState(() {
                                checkEdit = !checkEdit;
                                showDropdown = false;
                                if (!checkEdit) {
                                  textTtile.text = widget.title;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (showDropdown && checkEdit)
                      Container(
                        height: 300,
                        child: CustomSearchDropdown(
                          items: filteredItems,
                          selectedItem: selectedProject,
                          onChanged: (value) {
                            setState(() {
                              selectedProject = value;
                              textTtile.text = value!;
                              showDropdown = false;
                              checkEdit = false;
                            });
                          },
                        ),
                      ),
                    SizedBox(height: 16),
                    Stack(
                      children: [
                        TextField(
                          controller: taskArea,
                          decoration: InputDecoration(
                            labelText: "Enter Task Description",
                            border: OutlineInputBorder(),
                            hintText: "Enter Task Description",
                          ),
                          maxLines: 3,
                          readOnly: false,
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
                          BoxShadow(color: Colors.black26, blurRadius: 4)
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
                                        fontWeight: FontWeight.bold),
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
                                    fontSize: 16, fontWeight: FontWeight.bold),
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

                    // SizedBox(height: 16),

                    // // Quill Editor
                    // Container(
                    //   padding: const EdgeInsets.all(16.0),
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.grey[300]!),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: QuillEditor.basic(
                    //     configurations: QuillEditorConfigurations(
                    //       placeholder: "Enter Task Here...",
                    //       showCursor: true,
                    //       controller: editingtext,
                    //       sharedConfigurations: const QuillSharedConfigurations(
                    //         locale: Locale('de'),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // SizedBox(height: 10),

                    // Center(
                    //   child: TextButton(
                    //     style: TextButton.styleFrom(
                    //       foregroundColor: Colors.black,
                    //       padding: EdgeInsets.symmetric(
                    //           vertical: 5.0, horizontal: 40.0),
                    //       backgroundColor: Color.fromARGB(255, 69, 73, 76),
                    //       minimumSize: Size(100, 40),
                    //     ),
                    //     onPressed: () {
                    //       showDialog(
                    //         context: context,
                    //         builder: (context) {
                    //           return Dialog(
                    //             child: Container(
                    //               padding: EdgeInsets.all(16.0),
                    //               child: QuillToolbar.simple(
                    //                 configurations:
                    //                     QuillSimpleToolbarConfigurations(
                    //                   controller: editingtext,
                    //                   showFontFamily: false,
                    //                   showUndo: false,
                    //                   showRedo: false,
                    //                   showSearchButton: false,
                    //                   showHeaderStyle: false,
                    //                   showBackgroundColorButton: false,
                    //                   showColorButton: false,
                    //                   showSubscript: false,
                    //                   showSuperscript: false,
                    //                   sharedConfigurations:
                    //                       const QuillSharedConfigurations(
                    //                     locale: Locale('de'),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //       );
                    //     },
                    //     child: Text(
                    //       "Edit Text",
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.w400,
                    //           fontSize: 16,
                    //           color: Colors.white), // Increased font size
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(5), // Reduced margin
                            //  padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 7),
                                labelText: "Category",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              child: DropdownButton<String>(
                                underline: SizedBox.shrink(),
                                menuMaxHeight: 150,
                                isExpanded: true,
                                hint: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                items: myCategories
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item.taskCategory ?? "",
                                          child: Text(
                                            item.taskCategory ?? "",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (item) {
                                  setState(() {
                                    category = item ?? '';
                                    categoryid = myCategories
                                            .firstWhere(
                                              (category) =>
                                                  item ==
                                                  (category.taskCategory ?? ""),
                                            )
                                            .taskCategoryId ??
                                        0;
                                  });
                                  print(item);
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 7),
                                labelText: "Priority",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              child: DropdownButton<String>(
                                underline: SizedBox.shrink(),
                                menuMaxHeight: 150,
                                isExpanded: true,
                                hint: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    priority,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                items: myprority
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item.priority,
                                          child: Text(
                                            item.priority ?? "",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (item) {
                                  setState(() {
                                    priority = item ?? '';
                                    priorityid = myprority
                                            .firstWhere(
                                              (priority) =>
                                                  item ==
                                                  (priority.priority ?? ""),
                                            )
                                            .priorityId ??
                                        0;
                                  });
                                  print(item);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 7),
                                labelText: "Assign To",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              child: DropdownButton<String>(
                                underline: SizedBox.shrink(),
                                menuMaxHeight: 150,
                                isExpanded: true,
                                hint: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    assigne,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                items: collboraotrs
                                    .map((item) => DropdownMenuItem<String>(
                                          value:
                                              "${item.firstName ?? ""} ${item.lastName ?? ""}",
                                          child: Text(
                                            "${item.firstName ?? ""} ${item.lastName ?? ""}",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (item) {
                                  setState(() {
                                    assigne = item ?? '';
                                    assingnid = collboraotrs
                                            .firstWhere(
                                              (assignee) =>
                                                  item ==
                                                  ("${assignee.firstName ?? ""} ${assignee.lastName ?? ""}"),
                                            )
                                            .userId ??
                                        0;
                                  });
                                  print(item);
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 7),
                                labelText: "Status",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              child: DropdownButton<String>(
                                underline: SizedBox.shrink(),
                                menuMaxHeight: 150,
                                isExpanded: true,
                                hint: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    Status,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                items: myStatus
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item.taskStatus ?? "",
                                          child: Text(
                                            item.taskStatus ?? "New Status",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (item) {
                                  setState(() {
                                    Status = item ?? '';
                                    statusid = myStatus
                                            .firstWhere(
                                              (status) =>
                                                  item ==
                                                  (status.taskStatus ?? ""),
                                            )
                                            .taskStatusId ??
                                        0;
                                  });
                                  print(item);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 7),
                                labelText: "Task Type",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              child: DropdownButton<String>(
                                underline: SizedBox.shrink(),
                                menuMaxHeight: 150,
                                isExpanded: true,
                                hint: Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Text(
                                    task,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                items: getTasks
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item.taskType,
                                          child: Text(
                                            item.taskType ?? "",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (item) {
                                  setState(() {
                                    task = item ?? '';
                                    taskTypeid = getTasks
                                            .firstWhere(
                                              (taskType) =>
                                                  item ==
                                                  (taskType.taskType ?? ""),
                                            )
                                            .taskTypeId ??
                                        0;
                                  });
                                  print(item);
                                },
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
                                    getexacttime: (date) {},
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
                                    getexacttime: (date) {},
                                  )),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GetDatePicker(
                                    getselectedate: planEnd,
                                    getexacttime: (date) {},
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
                                    getexacttime: (date) {},
                                  )),
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GetDatePicker(
                                    getselectedate: actEnd,
                                    getexacttime: (date) {},
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
      "act_start_date": "",
      "act_end_date": "",
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
        Get.showSnackbar(GetSnackBar(
          title: "Task Status",
          message: response.body,
        ));
      } else {
        print('Server Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
