import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Timesheet extends StatefulWidget{

    Timesheet({required this.accid,required this.check,required this.projecid});

    final int accid,projecid;
    final bool check;


  @override
  State<StatefulWidget> createState() {
    return TimesheetState();
  }

}






class TimesheetState extends State<Timesheet>{


@override
  void initState() {


getApiCall();
    super.initState();
  }



Future<void> getApiCall()async{
SharedPreferences pref= await SharedPreferences.getInstance();

if(widget.check){
  await ApiCalls.getTimesheetbyTask(widget.accid, widget.projecid);
}
else{
  await ApiCalls.getDataofTimeShaeet(widget.accid, pref.getInt('user_id')??0);
}
  setState(() {
    timeSheet;
  });


}











  @override
  Widget build(BuildContext context) {
  return Scaffold(

appBar: AppBar(
  title: Text("Time Sheet",style: TextStyle(),),
),

body: ListView.builder(
  itemCount:timeSheet.length  ,
  itemBuilder:(context,index){


  return BuildCardForTimesheet(day: timeSheet[index].day??"", date: timeSheet[index].workDate??"", title: timeSheet[index].projectName??"", comment: timeSheet[index].comment??"", desc: timeSheet[index].taskName??"", startime: timeSheet[index].startTime??"", endtime: timeSheet[index].endTime??"", hours: timeSheet[index].hours??"");





  } 
  ),
// body: Center(child: Text(timeSheet.length.toString())),

  );
  }


}





class BuildCardForTimesheet extends StatelessWidget{

   BuildCardForTimesheet({
    required this.day,
    required this.date,
    required this.title,
    required this.comment,
    required this.desc,
    required this.startime,
    required this.endtime,
    required this.hours,
    });

final String day,date,comment,title,desc,startime,endtime,hours;


  @override
  Widget build(BuildContext context) {

        return Card(
          margin: EdgeInsets.all(15),
  color: Color.fromARGB(255, 255, 204, 204),
child: Padding(
  padding: EdgeInsets.all(10),
  child: Container(
  
  width: MediaQuery.of(context).size.width*0.8,
  child: Column(
    
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(day,style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300),),Text(date,style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300))
        ],
      ),
  
      Padding(
        padding: EdgeInsets.fromLTRB(10,5,10,5),
        child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
        
          children: [
          Text(title,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600))
        ],),
      ),
  
      Row(
        children: [
               
                  Expanded(child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
                    child: Text(desc,style: TextStyle(fontSize: 11,fontWeight: FontWeight.w400),maxLines: 1,softWrap: true,)))
  
        ],
      ),
  
   
  
       Padding(
        padding: EdgeInsets.all(10),
         child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
         
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Start time",style: TextStyle(fontSize: 10,fontWeight: FontWeight.w400),),SizedBox(width: 10,),Text(startime,style: TextStyle(fontSize: 10))
          ],
             ),
           Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("End time",style: TextStyle(fontSize: 10,fontWeight: FontWeight.w400),),SizedBox(width: 10,),Text(endtime,style: TextStyle(fontSize: 10))
          ],
             ),
         
          ],
             ),
       ),
           Row(
        children: [
               
                  Expanded(child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
                    child: Text(comment,style: TextStyle(fontSize: 10,fontWeight: FontWeight.w300),maxLines: 2,softWrap: true,)))
  
        ],
      ),
            Padding(
              padding: EdgeInsets.fromLTRB(0,5,5,0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                 
                   CircleAvatar(
                    child: Text(hours,style: TextStyle(color: Colors.white,fontSize: 18),),
                    backgroundColor: const Color.fromARGB(255, 210, 69, 69),
                    radius: 20,
                   )
              
                    ],
                  ),
            ),
  
    ]
    
    ),
  
  
  ),
),



);


  }


}