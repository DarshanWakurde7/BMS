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
    scroller.addListener(_scrollListener);
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
    await ApiCalls.getDataofCards(1.toString());

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 190,
      color: Colors.transparent,
      child: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          await ApiCalls.getDataofCards(1.toString());
          setState(() {
            dataOfCards;
            filteredDataOfCards = dataOfCards;
          });
        },
        child: ListView.separated(
          controller: scroller,
          separatorBuilder: (context, index) => Divider(),
          itemCount: filteredDataOfCards.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (val) {
                    _onSearchChanged(val);
                    print(val);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22)),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
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
              );
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
