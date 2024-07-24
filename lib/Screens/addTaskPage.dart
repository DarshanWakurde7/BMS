import 'dart:convert';

import 'package:bms/ApiCalls/apiCalls.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  String assigne = "Assigne";
  String collaborator = "collaborator";
  FocusNode esTimeFocusNode = FocusNode();
  int assingnid=0;
  int categoryid=0;
  int priorityid=0;
  int statusid=0;
  int taskTypeid=0;


  FocusNode _unUsedFocusNode = FocusNode();

  @override
  void initState() {
    getApis();
    proid.add(widget.projecid);

    checkEdit = false;
    getbill = false;
    super.initState();
  }

  void getApis() async {
    await ApiCalls.gettaskByUser(widget.accid);
    await ApiCalls.getCollborators(widget.accid,widget.projecid);
// await ApiCalls.getUsersByTask(widget.accid,proid);
    await ApiCalls.gettaskCategory(widget.accid);
    await ApiCalls.getStatus(widget.accid);
  }


    String getHtmlFromQuillController(QuillController controller) {
  final delta = controller.document.toDelta();
  return deltaToHtml(delta);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add Task",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          scrollDirection: Axis.vertical,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // SizedBox(height: MediaQuery.of(context).size.height*0.04,),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: TextField(
                      controller: textTtile,
                      decoration: InputDecoration(
                        hintText: widget.title,
                      ),
                      onTapOutside: (PointerDownEvent event) {
                        FocusScope.of(context).requestFocus(_unUsedFocusNode);
                      },
                      enabled: checkEdit,
                      style: TextStyle(fontSize: 20),
                    )),
                    InkWell(
                        onTap: () {
                          setState(() {
                            checkEdit = !checkEdit;
                          });
                        },
                        child: const Icon(Icons.edit)),
                  ]),
            ),

            Container(
              decoration: BoxDecoration(),
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: TextField(
                      style: TextStyle(fontSize: 15),
                      controller: taskArea,
                      decoration: InputDecoration(
                        labelText: "Enter Task",
                        labelStyle: TextStyle(fontSize: 15),
                        hintText: "Enter  Task",
                        hintStyle: TextStyle(fontSize: 15),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(7)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(7)),
                      ),
                      onTapOutside: (PointerDownEvent event) {
                        FocusScope.of(context).requestFocus(_unUsedFocusNode);
                      },
                    )),
                  ]),
            ),

            Card(
              margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Est. Effort-",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        Expanded(
                          child: TextField(
  focusNode: esTimeFocusNode,
  style: TextStyle(fontSize: 13),
  keyboardType: TextInputType.number,
  controller: esTime,
  decoration: InputDecoration(
    isDense: true,
    hintText: "0",
    hintStyle: TextStyle(fontSize: 13),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
      borderRadius: BorderRadius.circular(7)
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueAccent),
      borderRadius: BorderRadius.circular(7)
    ),
  ),
),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                        ),
                        Text(
                          "Actual Effort-" + "00",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: getbill,
                            onChanged: (val) {
                              setState(() {
                                getbill = val ?? false;
                              });
                            }),
                        Text(
                          "Billable",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w300),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        Checkbox(
                            value: invoiced,
                            onChanged: (val) {
                              setState(() {
                                invoiced = val ?? false;
                              });
                            }),
                        Text(
                          "Invoiced",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w300),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        Checkbox(
                            value: focus,
                            onChanged: (val) {
                              setState(() {
                                focus = val ?? false;
                              });
                            }),
                        Text(
                          "Focus",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //---------------------------------

            TextButton(
                style: ButtonStyle(
                    fixedSize: MaterialStatePropertyAll(Size(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height * 0.025)),
                    backgroundColor: MaterialStatePropertyAll(
                        Color.fromARGB(255, 240, 240, 240))),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: QuillToolbar.simple(
                              configurations: QuillSimpleToolbarConfigurations(
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
                      });
                },
                child: Text(
                  "Edit Text ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w400),
                )),

            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 131, 130, 130))),
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(children: [
                Expanded(
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      placeholder: "Enter Task Here...",
                      showCursor: true,
                      controller: editingtext,
                      // readOnly: false,
                      sharedConfigurations: const QuillSharedConfigurations(
                        locale: Locale('de'),
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(

                    // borderRadius: BorderRadius.circular(),
                    color: Colors.white),
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      )),
                  child: DropdownButton<String>(
                      underline: Text(""),
                      menuMaxHeight: 150,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(25),
                      hint: Padding(
                          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Text(
                            category,
                            style: TextStyle(fontSize: 10, color: Colors.black),
                            textAlign: TextAlign.center,
                          )),
                      items: myCategories
                          .map((item) => DropdownMenuItem<String>(
                                value: item.taskCategory??"",
                                child: Text(
                                  item.taskCategory??"",
                                  style: TextStyle(fontSize: 9),
                                ),
                              ))
                          .toList(),
                      onChanged: (item) {
                        setState(() {
                          category = item.toString();
                           categoryid = myCategories.firstWhere(
                (employee) => item == (employee.taskCategory??""),
                
              ).taskCategoryId??0;
                        });
                        print(item);
                      }),
                )),

            Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(

                    // borderRadius: BorderRadius.circular(),
                    color: Colors.white),
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      )),
                  child: DropdownButton<String>(
                      underline: Text(""),
                      menuMaxHeight: 150,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(25),
                      hint: Padding(
                          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Text(
                            priority,
                            style: TextStyle(fontSize: 10, color: Colors.black),
                            textAlign: TextAlign.center,
                          )),
                      items: myprority
                          .map((item) => DropdownMenuItem<String>(
                                value: item.priority,
                                child: Text(
                                  item.priority??"",
                                  style: TextStyle(fontSize: 9),
                                ),
                              ))
                          .toList(),
                      onChanged: (item) {
                        setState(() {
                          priority = item.toString();
                                     priorityid = myprority.firstWhere(
                (employee) => item == (employee.priority??""),
                
              ).priorityId??0;
                        });
                        print(item);
                      }),
                )),

            Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(

                    // borderRadius: BorderRadius.circular(),
                    color: Colors.white),
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: "Assign To",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      )),
                  child: DropdownButton<String>(
                      underline: Text(""),
                      menuMaxHeight: 150,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(25),
                      hint: Padding(
                          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Text(
                            assigne,
                            style: TextStyle(fontSize: 10, color: Colors.black),
                            textAlign: TextAlign.center,
                          )),
                      items: collboraotrs
                          .map((item) => DropdownMenuItem<String>(
                                value:"${ item.firstName??""} ${item.lastName??""}",
                                child: Text(
                                  "${ item.firstName??""} ${item.lastName??""}",
                                  style: TextStyle(fontSize: 9),
                                ),
                              ))
                          .toList(),
                      onChanged: (item) {
                        setState(() {
                          assigne = item.toString();
                                     assingnid = collboraotrs.firstWhere(
                (employee) => item == ("${ employee.firstName??""} ${employee.lastName??""}"),
                
              ).userId??0;
                        });
                        print(item);
                      }),
                )),

            Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(),
                    color: Colors.white),
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      )),
                  child: DropdownButton<String>(
                      underline: Text(""),
                      menuMaxHeight: 150,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(25),
                      hint: Padding(
                          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Text(
                            Status,
                            style: TextStyle(fontSize: 10, color: Colors.black),
                            textAlign: TextAlign.center,
                          )),
                      items: myStatus
                          .map((item) => DropdownMenuItem<String>(
                                value: item.taskStatus??"",
                                child: Text(
                                  item.taskStatus??"New Status",
                                  style: TextStyle(fontSize: 9),
                                ),
                              ))
                          .toList(),
                      onChanged: (item) {
                        setState(() {
                          Status = item.toString();
                                 statusid = myStatus.firstWhere(
                (employee) => item == (employee.taskStatus??""),
                
              ).taskStatusId??0;
                        });
                        print(item);
                      }),
                )),
            Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(

                    // borderRadius: BorderRadius.circular(),
                    color: Colors.white),
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: "Task Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      )),
                  child: DropdownButton<String>(
                      underline: Text(""),
                      menuMaxHeight: 150,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(25),
                      hint: Padding(
                          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Text(
                            task,
                            style: TextStyle(fontSize: 10, color: Colors.black),
                            textAlign: TextAlign.center,
                          )),
                      items: getTasks
                          .map((item) => DropdownMenuItem<String>(
                                value: item.taskType,
                                child: Text(
                                  item.taskType??"",
                                  style: TextStyle(fontSize: 9),
                                ),
                              ))
                          .toList(),
                      onChanged: (item) {
                        setState(() {
                          task = item.toString();
                                 taskTypeid = getTasks.firstWhere(
                (employee) => item == (employee.taskType??""),
                
              ).taskTypeId??0;
                        });
                        print(item);
                      }),
                )),
            Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(

                    // borderRadius: BorderRadius.circular(),
                    color: Colors.white),
                child:MultiSelectDropDown(
                      searchEnabled: true,
                      padding: EdgeInsets.all(5),
                      onOptionSelected: (value) {
                        setState(() {
                          assignedtp = value;
                        });
                      },
                      options: 
                          collboraotrs.map((e) => ValueItem(
                              label: (e.firstName ?? "") +
                                  " " +
                                  (e.lastName ?? ""),
                              value: e.userId))
                          .toList()),),

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
                      horizontalInside: BorderSide(color: Colors.black)),
                  children: [
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text("Date")),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Start Date")),
                      Padding(
                          padding: EdgeInsets.all(10), child: Text("End Date")),
                    ]),
                    TableRow(children: [
                      const Padding(
                          padding: EdgeInsets.all(5), child: Text("Est")),
                      Padding(
                          padding: const EdgeInsets.all(5),
                          child: GetDatePicker(
                            getselectedate: esStart,
                            getexacttime: (date) {},
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
                          padding: EdgeInsets.all(5), child: Text("Plan")),
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
                          padding: EdgeInsets.all(5), child: Text("Actual")),
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
          ? CircularProgressIndicator() // Loader when in progress
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
        ));
  }

  Future<void> _submitTask() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final url = Uri.parse('https://portalwiz.net/laravelapi/public/api/add_project_tasks');

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
      "plan_start_date": "${planStart.year}-${planStart.month}-${planStart.day}",
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
       Get.showSnackbar(GetSnackBar(title: "Task Status",message: response.body,));
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

