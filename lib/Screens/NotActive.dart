import 'package:bms/widgets/CardDesign.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotActive extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotActiveState();
  }
}

class NotActiveState extends State<NotActive> {
  late int count;
  ScrollController scroller = ScrollController();
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredDataOfCards = [];
  bool _isFilterVisible = false;
  bool _isAdditionalFilterVisible = false;
  List<Map<String, dynamic>> tasktype = [];
  List<Map<String, dynamic>> categorytype = [];
  List<Map<String, dynamic>> createdby = [];
  List<ValueItem> selectedcreatedby = [];
  List<ValueItem> selectedtasktype = [];
  List<ValueItem> selectedcategorytype = [];
  List<Map<String, dynamic>> projectTypes = [];
  List<Map<String, dynamic>> projectNames = [];
  List<Map<String, dynamic>> assignees = [];
  List<Map<String, dynamic>> taskStatuses = [];
  List<ValueItem> selectedProjectType = [];
  List<ValueItem> selectedProjectName = [];
  List<ValueItem> selectedAssignees = [];
  List<ValueItem> selectedTaskStatus = [];
  int roleId = 0;
  bool isLoading = false;

  @override
  void initState() {
    count = 4;

    fetchDropdownata();
    isLoading = true;
    getApiCallsActive();
    super.initState();
    scroller.addListener(_scrollListener);
  }

  void fetchDropdownata() async {
    final pref = await SharedPreferences.getInstance();

    tasktype = await ApiCalls.filterTaskTypeDropDown();
    categorytype = await ApiCalls.filterTaskCategoryDropDown();
    createdby = await ApiCalls.filterTaskCreatedByDropDown();
    projectTypes = await ApiCalls.filterProjectTypeDropDown();
    projectNames = await ApiCalls.filterProjectNameDropDown();
    assignees = await ApiCalls.filterAssigneeDropDown();
    taskStatuses = await ApiCalls.filterTaskStatusDropDown();
    print("Project Names: $projectNames");
    print("okkk...${taskStatuses}");
    setState(() {
      roleId = pref.getInt("role_id") ?? 0;
      tasktype;
      categorytype;
      createdby;
      projectTypes;
      projectNames;
      assignees;
      taskStatuses;
      isLoading = false;
    });
  }

  void _toggleAdditionalFilterVisibility() {
    setState(() {
      _isAdditionalFilterVisible = !_isAdditionalFilterVisible;
    });
  }

  void _onSearchChanged(String val) {
    setState(() {
      if (val.isEmpty) {
        print(dataOfCards.length);
        filteredDataOfCards = dataOfCards;
      } else {
        filteredDataOfCards = dataOfCards
            .where((card) =>
                (card.projectName ?? "")
                    .toLowerCase()
                    .contains(val.toLowerCase()) ||
                (card.taskTypeName ?? "")
                    .toLowerCase()
                    .contains(val.toLowerCase()) ||
                (card.taskName ?? "").toLowerCase().contains(val.toLowerCase()))
            .toList();
      }
    });
  }

  void getApiCallsActive() async {
    dataOfCards.clear();
    await ApiCalls.getDataofCards(
      1.toString(),
      selectedcreatedby.map((e) {
        return e.value as int;
      }).toList(),
      selectedtasktype.map((e) {
        return e.value as int;
      }).toList(),
      selectedcategorytype.map((e) {
        return e.value as int;
      }).toList(),
      selectedProjectType.map((e) {
        return e.value as int;
      }).toList(),
      selectedProjectName.map((e) {
        return e.value as int;
      }).toList(),
      selectedAssignees.map((e) {
        return e.value as int;
      }).toList(),
      selectedTaskStatus.map((e) {
        return e.value as int;
      }).toList(),
    );

    setState(() {
      dataOfCards;
      filteredDataOfCards = dataOfCards;
    });
  }

  @override
  void dispose() {
    scroller.removeListener(_scrollListener);
    searchController.dispose();
    super.dispose();
  }

  void _toggleFilterVisibility() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 190,
      color: Colors.transparent,
      child: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          setState(() {
            isLoading = true; // Set loading state to true when refreshing
          });
          getApiCallsActive();
          setState(() {
            isLoading =
                false; // Set loading state to false after data is fetched
          });
        },
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
                controller: scroller,
                separatorBuilder: (context, index) => Divider(),
                itemCount: filteredDataOfCards.isEmpty
                    ? 1
                    : filteredDataOfCards.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: TextField(
                                controller: searchController,
                                onChanged: (val) {
                                  _onSearchChanged(val);
                                  print(val);
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  hintText: 'Search by Task Name/Project Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _toggleFilterVisibility,
                              icon: Icon(
                                Icons.filter_alt_outlined,
                                color: Colors.blueAccent,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _isFilterVisible ? null : 0,
                          child: Visibility(
                            visible: _isFilterVisible,
                            child: Container(
                              padding: EdgeInsets.all(16),
                              color: Colors.grey[200],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Common filters for all users
                                  MultiSelectDropDown(
                                    hint: "Task Type",
                                    onOptionSelected: (val) {
                                      setState(() {
                                        selectedtasktype = val;
                                      });
                                      getApiCallsActive();
                                    },
                                    options: tasktype
                                        .map((e) => ValueItem(
                                            label: "${e["task_type"] ?? "0"} ",
                                            value: e["task_type_id"]))
                                        .toList(),
                                    selectedOptions: selectedtasktype,
                                  ),
                                  SizedBox(height: 3),
                                  MultiSelectDropDown(
                                    hint: "Task Category",
                                    onOptionSelected: (val) {
                                      setState(() {
                                        selectedcategorytype = val;
                                      });
                                      getApiCallsActive();
                                    },
                                    options: categorytype
                                        .map((e) => ValueItem(
                                            label:
                                                "${e["task_category"] ?? "0"}",
                                            value: e["task_category_id"]))
                                        .toList(),
                                    selectedOptions: selectedcategorytype,
                                  ),
                                  SizedBox(height: 3),
                                  MultiSelectDropDown(
                                    searchEnabled: true,
                                    hint: "Created By",
                                    onOptionSelected: (val) {
                                      setState(() {
                                        selectedcreatedby = val;
                                      });
                                      getApiCallsActive();
                                    },
                                    options: createdby
                                        .map((e) => ValueItem(
                                            label:
                                                "${e["first_name"] ?? "0"} ${e["last_name"] ?? "0"}",
                                            value: e["user_id"]))
                                        .toList(),
                                    selectedOptions: selectedcreatedby,
                                  ),
                                  // Additional filters for role_id = 1
                                  if (roleId == 1) ...[
                                    SizedBox(height: 3),
                                    MultiSelectDropDown(
                                      hint: "Project Type",
                                      onOptionSelected: (val) {
                                        setState(() {
                                          selectedProjectType = val;
                                        });
                                        getApiCallsActive();
                                      },
                                      options: projectTypes
                                          .map((e) => ValueItem(
                                              label:
                                                  "${e["project_type"] ?? "0"}",
                                              value: e["project_type_id"]))
                                          .toList(),
                                      selectedOptions: selectedProjectType,
                                    ),
                                    SizedBox(height: 3),
                                    MultiSelectDropDown(
                                      hint: "Project Name",
                                      onOptionSelected: (val) {
                                        setState(() {
                                          selectedProjectName = val;
                                        });
                                        getApiCallsActive();
                                      },
                                      options: projectNames
                                          .map((e) => ValueItem(
                                              label:
                                                  "${e["project_name"] ?? "0"}",
                                              value: e["project_id"]))
                                          .toList(),
                                      selectedOptions: selectedProjectName,
                                    ),
                                    SizedBox(height: 3),
                                    MultiSelectDropDown(
                                      searchEnabled: true,
                                      hint: "Assignees",
                                      onOptionSelected: (val) {
                                        setState(() {
                                          selectedAssignees = val;
                                        });
                                        getApiCallsActive();
                                      },
                                      options: assignees
                                          .map((e) => ValueItem(
                                              label:
                                                  "${e["first_name"] ?? "0"} ${e["last_name"] ?? "0"}",
                                              value: e["user_id"]))
                                          .toList(),
                                      selectedOptions: selectedAssignees,
                                    ),
                                    SizedBox(height: 3),
                                    MultiSelectDropDown(
                                      hint: "Task Status",
                                      onOptionSelected: (val) {
                                        setState(() {
                                          selectedTaskStatus = val;
                                        });
                                        getApiCallsActive();
                                      },
                                      options: taskStatuses
                                          .map((e) => ValueItem(
                                              label:
                                                  "${e["task_status"] ?? "0"}",
                                              value: e["task_status_id"]))
                                          .toList(),
                                      selectedOptions: selectedTaskStatus,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        filteredDataOfCards.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  'No Data Found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    );
                  } else {
                    final card = filteredDataOfCards[index - 1];
                    return myCards1(
                        projectid: dataOfCards[index].projectTaskId ?? 0,
                        Title: card.projectName ?? "Project Name Here",
                        taskTypeName: card.taskTypeName ?? "Normal",
                        description: card.taskName ?? "Task Name",
                        mydata: myStatus,
                        colab: card.collaborators ?? [],
                        priority: myprority,
                        plandate: card.planStartDate ?? "00-00-0000",
                        todate: card.planEndDate ?? "00-00-0000",
                        assigne: card.assingedName ?? "Donald Trumph",
                        index: index - 1,
                        isFocused: card.focus ?? false,
                        data: card,
                        refresh: () {
                          getApiCallsActive();
                        },
                        star: dataOfCards[index].lkFeedbackId,
                        emoji: dataOfCards[index].smileyId,
                        statusString: dataOfCards[index].status ?? "",
                        priorityString: dataOfCards[index].priorityName ?? "");
                  }
                },
              ),
      ),
    );
  }

  void _scrollListener() async {
    if (scroller.position.pixels == scroller.position.maxScrollExtent) {
      await ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: CircularProgressIndicator()),
        backgroundColor: Colors.transparent,
        duration: Duration(milliseconds: 500),
      ));

      setState(() {
        if (count < dataOfCards.length) {
          count = count + 1;
        }
      });
    }
  }
}
