


import 'package:bms/widgets/CardDesign.dart';

import 'package:bms/ApiCalls/apiCalls.dart';

import 'package:flutter/material.dart';




class Clear extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
 return ClearState();

  }


}


class ClearState extends State<Clear>{





@override
  void initState() {

ApiCalls.getDataofCards(7.toString());
 dataofCardClear;
    super.initState();
  }
  


















  @override
  Widget build(BuildContext context) {
 
    return    Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height-190,
                    color: Colors.transparent,
                    child: ListView.separated(
                      separatorBuilder: (context,index)=>Divider(),
                      itemCount: dataofCardClear.length,
                      itemBuilder:((context, index) {

                        @override
  void setState(VoidCallback fn) {
    dataofCardClear;
   
    super.setState(fn);
  }

                          return myCards1(Title: dataofCardClear[index].projectName??"Project Name Here",taskTypeName: dataofCardClear[index].taskTypeName??"Noraml", description: dataofCardClear[index].taskName??"Task Name", mydata: myCategories, colab: dataofCardClear[index].collaborators??[],priority: myprority, plandate: dataofCardClear[index].planStartDate??"00-00-0000", todate: dataofCardClear[index].planEndDate??"00-00-0000", assigne: dataofCardClear[index].assingedName??"Donald Trumph",index: index,isFocused: dataOfCards[index].focus??false,data: dataOfCards[index],refresh: (){
                        ApiCalls.getDataofCards(7.toString());
                          },);



                    }))
                        
                  );

  }





}