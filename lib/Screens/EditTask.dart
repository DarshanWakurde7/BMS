import 'dart:convert';

import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/pojos/models/CollaboratorsDropdown.dart';

import 'package:bms/widgets/searchable_dropdown.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditTask extends StatefulWidget {
  EditTask(
      {super.key,
      required this.title,
      required this.accid,
      required this.projecttaskid,
      required this.projecid});
  String title;
  int accid, projecid;
  int? projecttaskid;

  @override
  State<StatefulWidget> createState() {
    return AddTaskState();
  }
}

class AddTaskState extends State<EditTask> {
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

  FocusNode _unUsedFocusNode = FocusNode();

  @override
  void initState() {
    getApis();
    proid.add(widget.projecid);

    checkEdit = false;
    getbill = false;
    super.initState();
    fetchProjectList();
    fetchProjectList();
    getDataofProjectTask();
  }

  void getDataofProjectTask() async {
    if (widget.projecttaskid != null) {
      print(widget.projecid);
      Map<String, dynamic> data =
          await ApiCalls.fetchSingletask(widget.projecttaskid!);
      print("Data $data");
      setState(() {
        data;
        planStart = (data["plan_start_date"] != null)
            ? DateTime.parse("${data["plan_start_date"]}")
            : DateTime(0000, 1, 1);
        esStart = (data["est_start_date"] != null)
            ? DateTime.parse("${data["est_start_date"]}")
            : DateTime(0000, 1, 1);
        esEnd = (data["est_end_date"] != null)
            ? DateTime.parse("${data["est_end_date"]}")
            : DateTime(0000, 1, 1);
        planEnd = (data["plan_end_date"] != null)
            ? DateTime.parse("${data["plan_end_date"]}")
            : DateTime(0000, 1, 1);
        actStart = (data["act_start_date"] != null)
            ? DateTime.parse("${data["act_start_date"]}")
            : DateTime(0000, 1, 1);
        actEnd = (data["act_end_date"] != null)
            ? DateTime.parse("${data["act_end_date"]}")
            : DateTime(0000, 1, 1);
        textTtile.text = (widget.title != null) ? widget.title : "";
        taskArea.text = (data["task_name"] != null) ? data["task_name"] : "";
        categoryid = data["task_category"] ?? 0;

        category = myCategories
                .firstWhere(
                  (category) =>
                      (data["task_category"] ?? 0) ==
                      (category.taskCategoryId ?? 0),
                )
                .taskCategory ??
            "Task Category";
        priorityid = data["priority_id"] ?? 0;

        priority = (data["priority_id"] != null)
            ? myprority
                    .firstWhere(
                      (category) =>
                          (data["priority_id"] ?? 0) ==
                          (category.priorityId ?? 0),
                    )
                    .priority ??
                "Priority"
            : "Prority";

        statusid = data["task_status"] ?? 0;
        Status = (data["task_status"] != null)
            ? myStatus
                    .firstWhere(
                      (category) =>
                          (data["task_status"] ?? 0) ==
                          (category.taskStatusId ?? 0),
                    )
                    .taskStatus ??
                "Status"
            : "Status";

        taskTypeid = data["task_status"] ?? 0;

        task = (data["task_type"] != null)
            ? getTasks
                    .firstWhere(
                      (category) =>
                          (data["task_type"] ?? 0) ==
                          (category.taskTypeId ?? 0),
                    )
                    .taskType ??
                "Status"
            : "Status";
        assingnid = data["assinged_to"] ?? 0;
        //  CollaboratorsDropdown? Assignfulldata   = collboraotrs.firstWhere(
        //                                       (category) =>
        //                                           data["assinged_to"]??0 ==
        //                                           (category.userId ?? 0)??null,
        //  );

        //  assigne="${Assignfulldata.firstName} ${Assignfulldata.lastName}";
      });
    }
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
  // String getHtmlFromQuillController(QuillController controller) {
  //   final delta = controller.document.toDelta();
  //   return deltaToHtml(delta);
  // }

  // Future<void> fetchProjectList() async {
  //   final response = await http.post(
  //     Uri.parse(
  //         'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_project_list'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode({"account_id": "1100"}),
  //   );

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     setState(() {
  //       projectList = data.map((project) {
  //         return {
  //           'project_name': project['project_name'],
  //           'project_id': project['project_id'],
  //         };
  //       }).toList();
  //       // Initialize filteredItems with the full list
  //       filteredItems = List.from(projectList);
  //     });
  //   } else {
  //     throw Exception('Failed to load project list');
  //   }
  // }

  // void handleTextChange(String value) {
  //   setState(() {
  //     showDropdown = value.isNotEmpty && checkEdit;
  //     filteredItems = projectList
  //         .where((project) => project['project_name']
  //             .toLowerCase()
  //             .contains(value.toLowerCase()))
  //         .toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Task",
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
                            labelText: widget.title,
                            hintText: "Project Name",
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
                    SizedBox(height: 16),
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

  // Widget _buildCheckbox(
  //     String label, bool value, ValueChanged<bool?> onChanged) {
  //   return Row(
  //     children: [
  //       Checkbox(value: value, onChanged: onChanged),
  //       Text(
  //         label,
  //         style: TextStyle(fontSize: 14),
  //       ),
  //     ],
  //   );
  //                   // Text(editingtext.getPlainText().toString()),

  // }

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
        'https://portalwiz.net/laravelapi/public/api/update_project_tasks');

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
      "project_task_id": "${widget.projecttaskid}",
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
        print(response.body);
        // Show success snackbar
        Get.showSnackbar(
          GetSnackBar(
            title: "Task Status",
            message: "Task submitted successfully!",
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 2),
          ),
        );

        Fluttertoast.showToast(msg: "${response.body}");
      } else {
        // Show error snackbar
        Get.showSnackbar(
          GetSnackBar(
            title: "Task Status",
            message: "Failed to submit task: ${response.body}",
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 2),
          ),
        );
        Fluttertoast.showToast(msg: "Failed to submit task: ${response.body}");
        print('Server Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Show error snackbar
      Get.showSnackbar(
        GetSnackBar(
          title: "Task Status",
          message: "An error occurred: $e",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        ),
      );
      Fluttertoast.showToast(msg: "An error occurred: $e");

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
        (widget.getselectedate.year.toString() == "0")
            ? "dd-mm-yyyy"
            : widget.getselectedate.day.toString() +
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
