import 'dart:async';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/Enquire.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:bms/Screens/LanderPage.dart';
import 'package:bms/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';


late String profile;
class SplashScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
  return SplashScreenState();
  }

}


class SplashScreenState extends State<SplashScreen>{

@override
  void initState() {
    Timer(Duration(milliseconds: 5000), () { 
savedData();
    });
    super.initState();
  }



void savedData() async{
final sharedpref= await SharedPreferences.getInstance();
String email=sharedpref.getString("user_email")??"";

if(!email.isEmpty){

if(sharedpref.getInt("role_id")==2){
  print("...........................");
  print(sharedpref.getInt("role_id"));
  print("...........................");
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyEnquire()));
}
 else {await ApiCalls.getDataofCards(2.toString());
await ApiCalls.getStatus(sharedpref.getInt('account_id').toString());
await ApiCalls.getDataofTimeShaeet(sharedpref.getInt('account_id')??0, sharedpref.getInt('user_id')??0);
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  LanderPage()));}

}
else{
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const MyHomePage(title: "BMS",)));

}



}


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color.fromARGB(255, 120, 169, 255),
 
    body: Container(
      
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.transparent
      ),
      child: Center(
      
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                    SizedBox(height: 20,),

      Container(
        
        height: MediaQuery.of(context).size.height*0.15,
        width: MediaQuery.of(context).size.width*0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: AssetImage("asset/image/Portalwiz App Icon v3_white.png"),fit: BoxFit.cover)),
      ),
      LottieBuilder.network(
        height: 170,
        "https://lottie.host/b6e2ece4-9f85-48c9-a261-edf6bee354e5/Jic7jD0Aow.json"),
  
            ]
      
          ),
      
      
      ),
    ),
  );

  }


}
