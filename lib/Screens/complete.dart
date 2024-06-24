


import 'package:bms/widgets/CardDesign.dart';

import 'package:bms/ApiCalls/apiCalls.dart';

import 'package:flutter/material.dart';


List<String> mydata=['lsd','sdkm','skdcms','dcsd','dcsd'];
List<String> colab=['lsd','sdkm','skdcms','dcsd','dcsd'];


class Complete extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
 return CompleteState();

  }


}


class CompleteState extends State<Complete>{





@override
  void initState() {
getApiCallsActive();
 
    super.initState();
  }
  

void getApiCallsActive()async{
     await ApiCalls.getDataofCards(5.toString());
  setState(() { dataOfCards;});
}

















  @override
  Widget build(BuildContext context) {
 
    return    Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height-190,
                    color: Colors.transparent,
                    child: RefreshIndicator(
                      onRefresh: ()async{
                        getApiCallsActive();
                      },
                      child: ListView.separated(
                        separatorBuilder: (context,index)=>Divider(),
                        itemCount: dataOfCards.length,
                        itemBuilder:((context, index) {
                      
                          @override
                        void setState(VoidCallback fn) {
                         
                         
                          super.setState(fn);
                        }
                      
                            return myCards1(Title: dataOfCards[index].projectName??"Project Name Here",taskTypeName: dataOfCards[index].taskTypeName??"Noraml", description: dataOfCards[index].taskName??"Task Name", mydata: mydata, colab: dataOfCards[index].collaborators??[],priority: myprority, plandate: dataOfCards[index].planStartDate??"00-00-0000", todate: dataOfCards[index].planEndDate??"00-00-0000", assigne: dataOfCards[index].assingedName??"Donald Trumph",index: index,isFocused: dataOfCards[index].focus??false,data: dataOfCards[index],refresh: (){
                              getApiCallsActive();
                            },);
                      
                      
                      
                      })),
                    )
                        
                  );

  }





}