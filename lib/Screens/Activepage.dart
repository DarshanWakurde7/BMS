import 'package:bms/widgets/CardDesign.dart';

import 'package:bms/ApiCalls/apiCalls.dart';

import 'package:flutter/material.dart';

class Active extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ActiveState();
  }
}

class ActiveState extends State<Active> {
  @override
  void initState() {
    getApiCallsActive();
    super.initState();
  }

  void getApiCallsActive() async {
    print("okk");
    await ApiCalls.getDataofCards(2.toString());
    setState(() {
      dataOfCards;
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
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
                  Title: dataOfCards[index].projectName ?? "Project Name Here",
                  taskTypeName: dataOfCards[index].taskTypeName ?? "Noraml",
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
                );
              })),
        ));
  }
}
