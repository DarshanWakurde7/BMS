


import 'package:bms/widgets/CardDesign.dart';
import 'package:bms/pojos/models/CardPojodata.dart';

import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/controller/GetxController.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';



List<String> colab=['lsd','sdkm','skdcms','dcsd','dcsd'];


class Snoozed extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
 return SnoozedState();

  }


}


class SnoozedState extends State<Snoozed>{
 BmsAppController openseaController = Get.put(BmsAppController());




@override
  void initState() {



  print("init");
 apiCallActivate();
    super.initState();
  }


  void apiCallActivate() async{
    await openseaController.getSnoozedApiCall();
    
  }
  


















  @override
  Widget build(BuildContext context) {
 
    return    Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height-190,
                    color: Colors.transparent,
                    child: Obx(

                      (){
                            if(openseaController.isLoading.value){
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            else{
                               return ListView.separated(
                        separatorBuilder: (context,index)=>Divider(),
                        itemCount: (openseaController.dataofCardsSnoozed.isEmpty)?0:openseaController.dataofCardsSnoozed.length,
                        itemBuilder:((context, index) {
                      
                          @override
                        void setState(VoidCallback fn) {
                         
                         
                          super.setState(fn);
                        }
                      
                            return myCards1(Title: openseaController.dataofCardsSnoozed[index].projectName??"Project Name Here", taskTypeName: openseaController.dataofCardsSnoozed[index].taskName??"Noraml",description: openseaController.dataofCardsSnoozed[index].taskName??"Task Name", mydata: myStatus, colab: openseaController.dataofCardsSnoozed[index].collaborators??<Collaborators>[],priority: myprority, plandate: openseaController.dataofCardsSnoozed[index].planStartDate??"00-00-0000", todate: openseaController.dataofCardsSnoozed[index].planEndDate??"00-00-0000", assigne: openseaController.dataofCardsSnoozed[index].assingedName??"Donald Trumph",index: index,isFocused: dataOfCards[index].focus??false,data: dataOfCards[index],refresh: (){
                              apiCallActivate();
                            },);
                      
                      
                      
                      }));
                            }


                      }
                    )
                        
                  );

  }





}