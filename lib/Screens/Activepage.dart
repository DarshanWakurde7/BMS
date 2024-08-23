import 'package:bms/widgets/CardDesign.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';

class Active extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotActiveState();
  }
}

class NotActiveState extends State<Active> {
  late int count;
  ScrollController scroller = ScrollController();
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredDataOfCards = [];

  @override
  void initState() {
    count = 4;
    getApiCallsActive();
    super.initState();
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
    print("okk");
    await ApiCalls.getDataofCards(
        2.toString(), [], [], [], null, null, null, null);
    setState(() {
      dataOfCards;
      filteredDataOfCards = dataOfCards;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 190,
        color: Colors.transparent,
        child: RefreshIndicator(
          onRefresh: () async {
            getApiCallsActive();
          },
          child: ListView.separated(
              itemCount: dataOfCards.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: ((context, index) {
                return myCards1(
                    Title:
                        dataOfCards[index].projectName ?? "Project Name Here",
                    taskTypeName: dataOfCards[index].taskTypeName ?? "Normal",
                    description: dataOfCards[index].taskName ?? "Task Name",
                    mydata: myStatus,
                    colab: dataOfCards[index].collaborators ?? [],
                    priority: myprority,
                    plandate: dataOfCards[index].planStartDate ?? "00-00-0000",
                    todate: dataOfCards[index].planEndDate ?? "00-00-0000",
                    assigne: dataOfCards[index].assingedName ?? "Donald Trumph",
                    index: index,
                    isFocused: dataOfCards[index].focus ?? false,
                    data: dataOfCards[index],
                    refresh: () {
                      getApiCallsActive();
                    },
                    projectid: dataOfCards[index].projectTaskId ?? 0,
                    star: dataOfCards[index].lkFeedbackId,
                    emoji: dataOfCards[index].smileyId,
                    statusString: dataOfCards[index].status ?? "",
                    priorityString: dataOfCards[index].priorityName ?? "");
              })),
        ));
  }
}
