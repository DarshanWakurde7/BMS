import 'dart:async';
import 'dart:convert';
import 'package:bms/Screens/Activepage.dart';
import 'package:bms/Screens/Enquire.dart';
import 'package:bms/Screens/NotActive.dart';
import 'package:bms/Screens/Snooze.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/clear.dart';
import 'package:bms/Screens/complete.dart';
import 'package:bms/Screens/hold.dart';
import 'package:bms/Screens/review.dart';
import 'package:bms/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as kit;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

List<String> fieldsNames=['Not Started','Active','Hold','Review','Complete','Snoozed','Clear'];

class LanderPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
return LanderPageState();
  }

}


class LanderPageState extends State<LanderPage>with SingleTickerProviderStateMixin{


var backColor;
late bool light;
bool checkLocation=false;
String punch_Status="";
late String urlAnime;
String profileUrl="";






Future<Position> _determinePosition() async {

  List<kit.LatLng> poligonlatslongs=[

   kit.LatLng(18.5944166,73.7917032),
   kit.LatLng(18.5942322,73.7928545),
  kit.LatLng(18.5941796,73.7928305),
  kit.LatLng(18.5947532,73.7932197),
  kit.LatLng(18.5946136,73.7935348),
  kit.LatLng(18.5941001,73.7934851),
  kit.LatLng(18.5939405,73.7932565),


  ];




  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Turn On Location"),backgroundColor: Colors.red,));
  
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
   
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  final position =await Geolocator.getCurrentPosition();
  print(position.latitude);
  print(position.longitude);
setState(() {
  checkLocation=kit.PolygonUtil.containsLocation(kit.LatLng(position.latitude, position.longitude), poligonlatslongs as List<kit.LatLng>, false);
});
print(checkLocation);  
  return position;
}
Future<void> openscanner() async{

try{




final pref=await SharedPreferences.getInstance();




Uri url=Uri.parse('https://portalwiz.net/laravelapi/public/api/add_attendance?');
Uri urlfetchAttendance=Uri.parse("https://portalwiz.net/laravelapi/public/api/fetch_attendance?");

var payload={

    "account_id": pref.getInt('account_id').toString(),
    "user_id": pref.getInt('user_id').toString(),
    "punch_status":pref.getInt('punch_Status').toString()

};

var payloadForFetch= { "account_id": pref.getInt('account_id').toString(),
    "user_id": pref.getInt('user_id').toString(),};



final response =await http.post(url,body: payload);

final responseAttendence=await http.post(urlfetchAttendance,body:payloadForFetch);



print(jsonDecode(responseAttendence.body)["data"]);

// for(Map<String,dynamic> i in jsonDecode(responseAttendence.body.toString())["data"]){
//  print(jsonDecode(responseAttendence.body)["data"][0]["time"]);
// }



var data =jsonDecode(response.body.toString());
print(data['success']);

if(!mounted)return;
setState(() {
if((data['success']) && (pref.getInt('punch_Status')==1) ){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Have a Great Day"),backgroundColor: Colors.greenAccent,));
   getPunched();
  pref.setInt('punch_Status', 0);

}
else{
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bye!!"),backgroundColor: Colors.blueAccent,));
      getPunched();
      pref.setInt('punch_Status', 1);
   

}
});




}
on PlatformException{
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sorry failed to scan Try Again"),backgroundColor: Colors.redAccent,));

}


}




  void getPunched()async{

final pref=await SharedPreferences.getInstance();



setState(() {
profileUrl=pref.getString('profile_path')??"";
if(pref.getInt('punch_Status')==1){
backColor=Colors.greenAccent;
light=false;
urlAnime="asset/animation/Animation - 1706007149763.json";
}
else{
  backColor=Colors.redAccent;

light=true;

urlAnime="asset/animation/Animation - 1706007655831.json";
}
});

  }
late TabController tabController;
  @override
  void initState() {


   
  getPunched();
    ApiCalls.getDataofCards(1.toString());
    

    dataOfCards;
    _determinePosition();
     tabController=TabController(length: 7, vsync: this,initialIndex: 0);
    super.initState();
    
  }

   @override
 void dispose() {
   tabController.dispose();
   super.dispose();
 }



void termsAndCondition(){

showDialog(context: context, builder: (context){
  return Dialog(
    child: Container(
      color: Colors.white,
       height:MediaQuery.of(context).size.height*0.64,
      child: Column(
        
        children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Portalwiz BMS Privacy Disclosure",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10,2,10,2),
                    child: Container(
                     color: Colors.white,
                        height:MediaQuery.of(context).size.height*0.45,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(""),
                                Text('''Portalwiz technologies values your privacy and transparency. To ensure the best user experience, we want to inform you of the following:'''),
                                Text(""),
                                Text('''Background Location: ''',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                                Text('''This app utilizes background location services to accurately track employee attendance and improve operational efficiency. Rest assured, your location data is used solely for this purpose and is handled securely.'''),
                                Text(""),
                                Text('''Email Address and Password:''',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                                Text('''Your email address and password are collected solely for authentication purposes. They are securely stored and encrypted to safeguard your account information.
By using Portalwiz BMS, you consent to the collection and processing of this data. \n \n We are committed to protecting your privacy and maintaining the confidentiality of your information.

For more details on how we handle your data, please refer to our Privacy Policy.'''),


                            ],
                          )),
                      ),
                  ),
                  
                  

                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.white),
                        backgroundColor: MaterialStatePropertyAll(Colors.white)),
                        onPressed: ()async{
                          SharedPreferences preferences=await SharedPreferences.getInstance();
                          preferences.setBool("privacy_Terms", true);
                          Navigator.pop(context);
                      
                      }, child: Text("Agree and Continue",style: TextStyle(color: Colors.black),)),
                    ),
                  )
        ],
      ),
    ),
  );
});

}






void _showAlertDialog(bool visi) {
      showDialog(
        context: context,
        builder: (BuildContext Dialogcontext) {
        
          return Dialog(
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),color: Colors.white),
            
              width: MediaQuery.of(context).size.width*0.4,
              height: MediaQuery.of(context).size.height*0.2,
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Row(
               
               mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                  const Text("Out",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.redAccent),),
                  SizedBox(width: 10,),
                  punchinOrout(Dialogcontext),
                   SizedBox(width: 10,),
                  const Text("In",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.greenAccent),)
                 ],
               ),

               
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                  TableRow(
                    children: [Text("Status",textAlign: TextAlign.center,),Text("time")]
                  )
                ],
              ),
              // ListView.builder(
              //   itemCount: ,
              //   itemBuilder: (context,ind){

              // })



             ],
           ),
            ),
          );
        },
      );
    }





  @override
  Widget build(BuildContext context) {

          return Scaffold(

            drawer: Drawer(
              width: MediaQuery.of(context).size.width*0.6,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
SizedBox(height: MediaQuery.of(context).size.width*0.5,),

     CircleAvatar(

                             radius: 38,
                            backgroundColor: Colors.transparent,
                            
                              child: Image(image: NetworkImage("https://portalwiz.net/laravelapi/storage/app/"+profileUrl))
                            ),

SizedBox(height: MediaQuery.of(context).size.width*0.1,),
                  ListTile(
                    title:const Text("Home"),
                    leading: const Icon(Icons.home),

                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title:const Text("Gallery"),
                     leading: const Icon(Icons.picture_in_picture),

                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title:const Text("Enquires"),
                    leading: const Icon(Icons.question_answer_outlined),
                    onTap: (){
                      Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>MyEnquire()));
                    },
                  ),
                  ListTile(
                    title:const Text("Log Out"),
                    leading: const Icon(Icons.logout_outlined),
                    onTap: ()async{
                      Navigator.pop(context);
                      SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
                   await sharedPreferences.clear();
          
                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MyHomePage(title: "")));
                    },
                  ),
                  ListTile(
                    title:const Text("Version 1.1.0"),
                    leading: const Icon(Icons.mobile_friendly),
                    onTap: ()async{
                  
          
                   showAboutDialog(context: context);
                    },
                  ),
                ],
              ),
            ),
           appBar: AppBar(
            title:  Row(


                        

                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                  
                           Container(
                            margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.1, 0, MediaQuery.of(context).size.width*0.1, 0),
                            width: MediaQuery.of(context).size.height*0.15,
                            child:  Image.asset('asset/image/portalwiz.png'),
                            
                            ),


                            CircleAvatar(
                            backgroundColor: Colors.transparent,
                            
                              backgroundImage: NetworkImage("https://portalwiz.net/laravelapi/storage/app/"+profileUrl)
                            )
                          ],
                        ),
                        bottom:  PreferredSize(
                        
                       
                              preferredSize: Size.fromHeight(50.0),
                                 child: TabBar(tabs:const  [
                                Tab(text: "Not Started",),
                                Tab(text: "Active",),
                                Tab(text: "Hold",),
                                Tab(text: "Review",),
                                Tab(text: "Complete",),
                                Tab(text: "Snoozed",),
                                Tab(text: "Clear",),
                          ],
                          indicatorColor: Colors.blueAccent,
                          labelColor: Colors.blueAccent,
                          isScrollable: true,
                          controller:tabController ,
                          ),
                        )
                         ),


                         body:TabBarView(
                          controller: tabController,
                          children:  [
                              NotActive(),
                              Active(),
                              Hold(),
                              Review(),
                              Complete(),
                              Snoozed(),
                              Clear(),
                         ],
                        ) ,
    
           floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
     
        overlayStyle: ExpandableFabOverlayStyle(
          // color: Colors.black.withOpacity(0.5),
          blur: 5,
        ),
     
        children: [
  
         InkWell(
          onTap: ()async{
            SharedPreferences preferences=await SharedPreferences.getInstance();

        if(!(preferences.getBool("privacy_Terms")??false))
        {
          termsAndCondition();
        }

                
                   
                if(checkLocation){
           
                    _showAlertDialog(false);
                }
                else{
                  _determinePosition();
                  print("Sorry");
                }




          },
           child: CircleAvatar(
            child: const Icon(Icons.calendar_month_outlined,size: 34,),
            backgroundColor: backColor,
            radius: 24,
           ),
         )
    
        ],
      ),
  
);






       
        

  }





Container getAnime(){


  return Container(
          width: MediaQuery.of(context).size.width*0.3,
              height: MediaQuery.of(context).size.height*0.12,
    child: Lottie.asset(urlAnime));

}



 void showToast({
    required BuildContext context,
  }) {

    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
        builder: (context) => getAnime()
    );
    Overlay.of(context).insert(overlayEntry);
    Timer(Duration(seconds: 3), () =>  overlayEntry.remove());

  }


  Switch punchinOrout(BuildContext dialogContex){

   return Switch(
    
      // This bool value toggles th
      //e switch.
      value: light,
      activeColor: Colors.greenAccent,
      inactiveThumbColor: Colors.redAccent,
      inactiveTrackColor: Color.fromARGB(255, 255, 180, 180),
      onChanged: (bool value) {

showToast(context: context);

          openscanner();
         
        setState(() {
          light = value;
          urlAnime;
        });
          getAnime();
             Navigator.pop(dialogContex);
          _showAlertDialog(false);
      },
    );


  }




}


















