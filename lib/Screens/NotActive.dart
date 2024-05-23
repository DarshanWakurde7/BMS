


import 'package:bms/widgets/CardDesign.dart';
import 'package:bms/ApiCalls/apiCalls.dart';

import 'package:flutter/material.dart';





class NotActive extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
 return NotActiveState();

  }


}


class NotActiveState extends State<NotActive>{



late int count;
ScrollController scroller=ScrollController();

@override
  void initState() {
count=4;
getApiCallsActive();
    super.initState();
  }
  



  void getApiCallsActive() async{
    await  ApiCalls.getDataofCards(1.toString());

    setState(() {
         dataOfCards;
    });
    
  }













  @override
  Widget build(BuildContext context) {
 
    return    Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height-190,
                    color: Colors.transparent,
                    child: RefreshIndicator(
                      triggerMode: RefreshIndicatorTriggerMode.anywhere,
                      onRefresh: () async{
                          await ApiCalls.getDataofCards(1.toString());
                          setState(() {
                                
                                dataOfCards;
                          });
                      },
                      child: ListView.separated(
                        controller: scroller,
                        separatorBuilder: (context,index)=>Divider(),
                        itemCount: dataOfCards.length,
                        itemBuilder:((context, index) {
                      
                    
                            return myCards1(Title: dataOfCards[index].projectName??"Project Name Here",taskTypeName: dataOfCards[index].taskTypeName??"Noraml", description: dataOfCards[index].taskName??"Task Name", mydata: myStatus, colab: dataOfCards[index].collaborators??[],priority: myprority, plandate: dataOfCards[index].planStartDate??"00-00-0000", todate: dataOfCards[index].planEndDate??"00-00-0000", assigne: dataOfCards[index].assingedName??"Donald Trumph",index: index,isFocused: dataOfCards[index].focus??false,data: dataOfCards[index],refresh: (){
                              getApiCallsActive();
                            },);

                    
                    
                      
                      
                      
                      
                      })),
                    )
                        
                  );

  }


 void _scrollListner()async{

if(scroller.position.pixels==scroller.position.maxScrollExtent){

 await ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: CircularProgressIndicator()),backgroundColor: Colors.transparent,duration: Duration(milliseconds: 500),));


setState(() {
             if(count<dataOfCards.length){                        
              count=count+1;
              }                  
        });
}
 

        

  }





}