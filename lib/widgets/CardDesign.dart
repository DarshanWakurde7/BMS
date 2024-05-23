

import 'package:bms/Screens/AddTime.dart';
import 'package:bms/pojos/models/CardPojodata.dart';
import 'package:bms/Screens/Comment.dart';
import 'package:bms/Screens/TimeSheet.dart';
import 'package:bms/Screens/addTaskPage.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';




class myCards1 extends StatefulWidget{


  myCards1({required this.Title,required this.taskTypeName,required this.description,required this.priority,required this.mydata,required this.colab,required this.plandate,required this.todate,required this.assigne,super.key,required this.index,required this.isFocused ,required this.data,required this.refresh});

final int index;
final List<String> mydata;
final List<String> priority;
final List<Collaborators> colab;
final String Title,description,plandate,todate,assigne,taskTypeName;
final bool isFocused;
Autogenerated data;
Function refresh;
  @override
  State<myCards1> createState() => _myCards1State();
}

class _myCards1State extends State<myCards1> {


getTimeState timer=getTimeState();
var countReview=TextEditingController();



 TimeOfDay? mynew=TimeOfDay(hour: 12, minute: 00);
 TimeOfDay? mynew1=TimeOfDay(hour: 12, minute: 00);
  var review=TextEditingController();
  var comment=TextEditingController();
  DateTime todays=DateTime.now();

String Status="Status";
String priority="Priority";
DateTime selectedDate=DateTime.now();
DateTime timesheetdate=DateTime.now();
DateTime toselectedDate=DateTime.now();
List<String> colborators=[];
Color col= const Color.fromRGBO(255, 255, 231, 1);
@override
  void initState() {
      for (int i=0;i<widget.colab.length;i++){
        colborators.add(widget.colab[i].assingedName??"");
      }
      col=(widget.isFocused)?Color.fromARGB(255, 192, 215, 255):const Color.fromRGBO(255, 255, 231, 1);

    super.initState();
  }




  @override
  Widget build(BuildContext context) {
   return Card(
    color:col,
            margin: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
            child: Container(

           
              margin: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                width: MediaQuery.of(context).size.width,
              
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                          children:[InkWell(child: const Icon(Icons.file_open_outlined,size: 24,),onTap: (){
                         
                               //---------------
                         
                          },),SizedBox(width: MediaQuery.of(context).size.width*0.015,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.6,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                                child: Text(widget.Title,style: const TextStyle(fontWeight: FontWeight.w800,fontSize: 12,color: Colors.black,overflow: TextOverflow.fade),maxLines: 1,softWrap: true,overflow: TextOverflow.fade,)),
                          ),] ),
                          Expanded(child: Text(" "+widget.taskTypeName,style: TextStyle(background: Paint()..color=Colors.white,color:Colors.pinkAccent,fontWeight: FontWeight.w400,fontSize: 10),textAlign: TextAlign.end,overflow: TextOverflow.fade,))
                       ],
                     ),
                    const SizedBox(height: 8,),
                     Row(children: [InkWell(child: const Icon(Icons.message_outlined,size: 25,),onTap: (){
                      //-----------------------
                    
                        // ApiCalls.getComments(dataOfCards[widget.index].accountId??1, dataOfCards[widget.index].projectId??0, dataOfCards[widget.index].projectTaskId??0);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CommentPage(accid: dataOfCards[widget.index].accountId??1, projectId: dataOfCards[widget.index].projectId??0, projecttaskid: dataOfCards[widget.index].projectTaskId??0,created_by: dataOfCards[widget.index].createdBy??0,showProject: false,)));

                     },),const SizedBox(width: 5,),Expanded(child: Text(widget.description,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14),maxLines: 2,softWrap: false,)),SizedBox(width: 5,), Text(dataOfCards[widget.index].taskDayAgo??'0'+'d',style: const TextStyle(color: Color.fromARGB(255, 32, 114, 255),fontSize: 16,fontWeight: FontWeight.w600),)]),
                       const SizedBox(height: 8,),
                        Row(children: [InkWell(child: Icon(Icons.history),onTap: (){


                                                timeSheet.clear();
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Timesheet(accid: dataOfCards[widget.index].accountId??1,projecid:  dataOfCards[widget.index].projectTaskId??1,check: true,)));


                        },),SizedBox(width: 8,),Text('Est',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12),),SizedBox(width: 5,),Text(dataOfCards[widget.index].estEfforts??'00',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Color.fromARGB(255, 33, 89, 243))), SizedBox(width: 15,),Text('My',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12)),SizedBox(width: 5,),Text(dataOfCards[widget.index].myEfforts??'00',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Color.fromARGB(255, 33, 89, 243))),SizedBox(width: 10,),Text('All',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12)),SizedBox(width: 5,),Text(dataOfCards[widget.index].allEfforts??'0.00',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Color.fromARGB(255, 33, 89, 243)))], ),
                       const SizedBox(height: 8,),
                  Row(
                    children:[ 
                      
                      Padding(
                      padding: EdgeInsets.fromLTRB(30,5,5,10),
                      child: Container(
                        
                     
                        height: MediaQuery.of(context).size.height*0.03,
                        width: MediaQuery.of(context).size.width*0.35,
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(24),
                          color: Colors.white
                        ),
                        child: DropdownButton<String>(
                          underline: Text(""),
                          menuMaxHeight: 150,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(25),
                          hint: Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Text(Status,style: TextStyle(fontSize: 12,color: Colors.black),)),
                          items: widget.mydata.map((item)=>DropdownMenuItem<String>(
                          value: item,
                          
                          child: Text(item,style: TextStyle(fontSize: 10),overflow: TextOverflow.fade,
                            maxLines: 2,
                            softWrap: false,),
                        )).toList(), onChanged:(item)async{
                                setState(() {
                                  
                              Status=item.toString();
                              widget.data.status=item??"";
                             
                                });

                              await ApiCalls.updateProjectTaskByUser(widget.data);
                              widget.refresh();
                      
                        } )),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(30,5,5,10),
                      child: Container(
                        
                     
                        height: MediaQuery.of(context).size.height*0.03,
                        width: MediaQuery.of(context).size.width*0.35,
                           decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(),
                          color: Colors.white
                        ),
                        child: DropdownButton<String>(
                          underline: Text(""),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(25),
                          hint: Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Text(priority,style: TextStyle(fontSize: 12,color: Colors.black),textAlign: TextAlign.center,)),
                          items: widget.priority.map((item)=>DropdownMenuItem<String>(
                          value: item,
                          child: Text(item,style: TextStyle(fontSize: 11),),
                        )).toList(), onChanged:(item){
                          setState(() {
                            priority=item.toString();
                          });
                          print(item);
                        } )),


                    ),
    
                    ]
                  ),


                       Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                        child: Row(children: [Text('Plan',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12),),SizedBox(width: 30,),Text(widget.plandate,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 10),),SizedBox(width: 40,),Text('To',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 10),),SizedBox(width: 20,),Text(widget.todate,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 10)),])),
                    const SizedBox(height: 8,),
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                    child: Row(children: [const Text("Actual",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12),),SizedBox(width: 20,),InkWell(child:  Text("${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",style: const TextStyle(fontWeight: FontWeight.w300,fontSize: 10,color: Color.fromARGB(255, 33, 89, 243))),onTap:()async{
                    
                      final DateTime? dateTime=await showDatePicker(context: context, firstDate: DateTime(1000), lastDate: DateTime(3000),initialDate: selectedDate,
                      barrierColor: Colors.transparent,
                      builder: (context, child) {
                    
                              return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.blueAccent, // header background color
                                  onPrimary: Colors.black, // header text color
                                  onSurface: Colors.black, // body text color
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue, // button text color
                                  ),
                    
                                ),
                              ),
                              child: child!,
                              ); 
                              
                              
                              
                              
                              
                              
                              
                    
                      },
                    
                    
                      );
                    
                    
                      if(dateTime!=null){
                        setState(() {
                          selectedDate=dateTime;
                        });
                      }
                    
                    },),SizedBox(width:50,),const Text("To",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12),),SizedBox(width: 20,),InkWell(child:  Text("${toselectedDate.day}/${toselectedDate.month}/${toselectedDate.year}",style: const TextStyle(fontWeight: FontWeight.w300,fontSize: 12,color: Color.fromARGB(255, 33, 89, 243))),onTap:()async{
                    
                     final DateTime? dateTime=await showDatePicker(context: context, firstDate: DateTime(1000), lastDate: DateTime(3000),initialDate: toselectedDate);
                      if(dateTime!=null){
                          setState(() {
                            toselectedDate=dateTime;
                          });
                    
                      }
                      
                    },)]),
                  ),


Padding(
                      padding: const EdgeInsets.fromLTRB(30,5,5,5),
                    child: Row(
                      children: [
                        Text("Assignee",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),),
SizedBox(width: MediaQuery.of(context).size.width*0.08,),
                                                InkWell(
                                                  onTap: (){
                                                        timeSheet.clear();
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Timesheet(accid: dataOfCards[widget.index].accountId??1,projecid:  dataOfCards[widget.index].projectTaskId??1,check: false,)));


                                                  },
                                                  child: Text(widget.assigne,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w300,color: Color.fromARGB(255, 3, 24, 255)),))

                     ],
                     ) 
                      
                      ),




Padding(
                      padding: const EdgeInsets.fromLTRB(30,0,10,10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Collaborator",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),),
                        SizedBox(width: 10,),
    Expanded(
      
      child: Padding(
        padding:EdgeInsets.fromLTRB(0, 3, 0, 0),
        child: Text(colborators.toString(),style: const TextStyle(fontSize: 11,fontWeight: FontWeight.w300),softWrap: true,maxLines: 3,overflow: TextOverflow.fade,)))

                     ],
                     ) 
                      
                      ),






            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [GestureDetector(
                
             
                
                onTap: (){
            getTimeSheetData();
              }, child: Icon(Icons.schedule_rounded,size: 24,)
              
              // Text('Add Time',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.blueAccent), // )
              
              ),
              
              
          


                    PopupMenuButton<PopupMenu>(

                      surfaceTintColor: Colors.white,
                      
                      
                      icon: const Icon(Icons.select_all,size: 28,),
                      onSelected: (value) async{

                            if(value.name.toString()=="ProjectComment"){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CommentPage(accid: dataOfCards[widget.index].accountId??1, projectId: dataOfCards[widget.index].projectId??0, projecttaskid: dataOfCards[widget.index].projectTaskId??0,created_by: dataOfCards[widget.index].createdBy??0,showProject: true,)));

                            }
                           else if(value.name.toString()=="Add"){

                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTask(title: widget.Title,accid: dataOfCards[widget.index].accountId??1,projecid: dataOfCards[widget.index].projectId??36,)));

                            }

                            else if(value.name.toString()=="Delete"){


                                showDialog(context: context, builder: (context){
                                 return  AlertDialog(

                               backgroundColor: Colors.white,
                                  title: const Text("Are you Sure ?",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w400),),
                                  actions: [


                                        ElevatedButton(
                                        style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white)),
                                        onPressed: (){

                                          Navigator.pop(context);

                                      }, child: const Text("Cancel",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w300,color: Colors.black),)),

                                      ElevatedButton(
                                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.redAccent)),
                                        onPressed: ()async{
                                                                        await ApiCalls.deleteTaskbyUser(dataOfCards[widget.index].accountId??1, dataOfCards[widget.index].projectTaskId??0, context);

                                      }, child: const Text("Delete",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w300,color: Colors.white),)),
       

                                  ],
                                 );
                                });



                            }

                      },
                      itemBuilder: (context)=>const  [

                        PopupMenuItem(
                        value:PopupMenu.Add,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[ Text("Add Task",style: TextStyle(fontSize: 12),),
                          Icon(Icons.add)
                          ])
                          ),
                        PopupMenuItem(
                           value:PopupMenu.Edit,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[ Text("Edit Task",style: TextStyle(fontSize: 12),),
                          Icon(Icons.edit)
                          ])
                          ),
                        PopupMenuItem(
                          value: PopupMenu.Delete,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[ Text("Delete Task",style: TextStyle(fontSize: 12),),
                          Icon(Icons.delete_outline)
                          ])
                          ),
                        PopupMenuItem(
                          value: PopupMenu.ProjectComment,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[ Text("Project Comment",style: TextStyle(fontSize: 12),),
                          Icon(Icons.comment_bank_outlined)
                          ])
                          ),

                    ]),





              
              
              ]
            )




                  
                  ],
                ),
                
            
            
            
            
            ),
          );
  }

  void getTimeSheetData(){


showDialog(context: context, builder: (context){

  return Dialog(

    child: Container(
      width: MediaQuery.of(context).size.width*0.75,
      height: MediaQuery.of(context).size.height*0.5,
      child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blueAccent.shade100,
                title: const Text("Add Time",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w300),),
                centerTitle: true,
              ),

              body: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                         children: [

                              SizedBox(height: 20,),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20,2,20,2),
                            child: Table(
                            
                              columnWidths: {
                                0:FlexColumnWidth(2)
                              },
                              border: const TableBorder(
                                horizontalInside: BorderSide(color: Colors.blueAccent)
                              ),
                              children: [
                                TableRow(
                           
                                  children: [
                                    Text("Date",style: TextStyle(fontSize: 17),),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month,size: 16,),
                                        SizedBox(width: 8,),
                                        GetDatePicker(getselectedate: todays,getexacttime: (date){
                                         setState(() {
                                           timesheetdate=date;
                                         });
                                        },),
                                      ],
                                    )
                                  ]
                                ),
                            
                                TableRow(
                                  children: [
                                    Text("Start Time",style: TextStyle(fontSize: 17),),
                                      Row(
                                        children: [
                                            Icon(Icons.schedule_outlined,size: 17,),
                                            SizedBox(width: 3,),
                                          GetTime(getselected: (p0) {
                                                                            setState(() {
                                                                            mynew=p0;
                                                                            });
                                                                          },),
                                        ],
                                      ),
                                  ]
                            
                                ),
                            
                                TableRow(
                                  children: [
                                          Text("End Time",style: TextStyle(fontSize: 17),),
                                               Row(
                                                 children: [
                                                             Icon(Icons.schedule_outlined,size: 17,),
                                            SizedBox(width: 3,),
                                                   GetTime(getselected: (p0) {
                                                                                     setState(() {
                                                                                     mynew1=p0;
                                                                                     });
                                                                                   },),
                                                 ],
                                               ),
                                  ]
                                )
                                
                              ],
                            ),
                          ),



Container(
    margin: const EdgeInsets.fromLTRB(20, 5, 15, 5),
    child: Row(
      children: [
        Text("Review: ",style: TextStyle(fontSize: 18),),
Expanded(child: TextField(
  controller: review,
  keyboardType: TextInputType.number,
decoration: InputDecoration(

  contentPadding: EdgeInsets.zero,
  isDense: true,
),
))
      ],
    ),
),

                          Container(
                            margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                            child: Row(
                              children: [
                                Expanded(child: TextFormField(
                                                                         
                                                                   
                                                                         decoration: InputDecoration(
                                                                           label: Text("Comment"),
                                                                          
                                                                           border: OutlineInputBorder(
                                                                             borderRadius: BorderRadius.circular(8)
                                                                           )
                                                                         ),
                                                                         controller: comment,
                                                                      minLines: 5, // any number you need (It works as the rows for the textarea)
                                                                      keyboardType: TextInputType.multiline,
                                                                      maxLines: null,
                                                                   ),
                                )
                              ],
                            ),
                          ),

SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                            Align(
                                alignment: Alignment.bottomRight,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                width: MediaQuery.of(context).size.width*0.4,
                                height: MediaQuery.of(context).size.height*0.04,
                                                    
                                  child: ElevatedButton(onPressed: ()async{
                                  
                                  // print(dataOfCards[widget.index].projectId!);
                                  print(todays);
                                        await ApiCalls.addTimeSheetOfProject(dataOfCards[widget.index].projectTaskId??0, dataOfCards[widget.index].accountId??0, dataOfCards[widget.index].projectId??0, dataOfCards[widget.index].actStartDate??"00/00/0000", dataOfCards[widget.index].actEndDate??"00/00/0000", dataOfCards[widget.index].taskStatus??0, dataOfCards[widget.index].priorityId??0, dataOfCards[widget.index].assingedTo??0, dataOfCards[widget.index].createdBy??0, dataOfCards[widget.index].taskDesc??"","${timesheetdate.year}/${timesheetdate.month}/${timesheetdate.day}" , comment.text.toString(), mynew!.format(context), mynew1!.format(context));
                                  
                                  
                                  }, child:const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [ 
                                    Icon(Icons.local_post_office),SizedBox(width: 10,),Text("Submit")],
                                  )
                                  ),
                              
                              ),
                            )
                          
                            



                         
                          
                            
                         ],

                ),
              ),
            ),
    ),

  );

});


}


}

enum PopupMenu{
  Add,Edit,Delete,ProjectComment
}



