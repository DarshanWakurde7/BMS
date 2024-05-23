import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/pojos/models/FilterDataPojo.dart';
import 'package:bms/pojos/models/enquireComment.dart';
import 'package:bms/pojos/models/getAllDataofEnquireCard.dart';
import 'package:bms/widgets/enquireCommentCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnquireFullInfo extends StatefulWidget {
  const EnquireFullInfo({super.key,required this.id});
 final int id;

  @override
  State<EnquireFullInfo> createState() => _EnquireFullInfoState();
}

class _EnquireFullInfoState extends State<EnquireFullInfo> {

TextEditingController fname=TextEditingController();
TextEditingController datasource=TextEditingController();
TextEditingController lname=TextEditingController();
TextEditingController email=TextEditingController();
TextEditingController company =TextEditingController();
TextEditingController whatsapp=TextEditingController();
TextEditingController phone=TextEditingController();
TextEditingController enquireDate=TextEditingController(); 
TextEditingController followupdate=TextEditingController(); 
TextEditingController newAppointment=TextEditingController();
TextEditingController commentTextField=TextEditingController();
TextEditingController estimateClousreDate=TextEditingController();
EnquiryStatus enquireStatusDropdown=EnquiryStatus(enquiryStatus: "Enquiry Status");
EnquiryType enquiretypeDropdown=EnquiryType(enquiryType: "Enquiry Type");
EnquirySources enquireSourceDropdown=EnquirySources(enquirySource: "Enquiry Source");
LeadLevel leadLevelDropdown=LeadLevel(leadLevel: "Lead Level ");
AssingedTo assingedTo=AssingedTo(firstName: "Assigned to",lastName: "To");
CommentStatus commentstatus=CommentStatus(commentStatus: "Comment Status");
GetAllDropdownEnquire getAllDropdownEnquireInCard=GetAllDropdownEnquire();

bool intercheck=false;
bool notifyCustomer=false;
int noticommenttoCusto=0;
GetAllDataofEnquire getAllDataofEnquire=GetAllDataofEnquire();
List<EnquiresCommentss> enquireComment=[];
@override
  void initState() {
    getApiCalls();
    // TODO: implement initState
    super.initState();
  }





void getApiCalls()async{

  SharedPreferences sharedPreferences=await SharedPreferences.getInstance();



showDialog(
 
  context: context, builder: (context){
  return
Center(
      child: Lottie.network("https://lottie.host/2fcce2a4-14ea-4f92-a8f9-997c441d3043/EbknVutwPu.json",width: 200),
    
  );
});


  
      getAllDropdownEnquireInCard=await ApiCalls.getAllDropDOwnsEnquire();
     getAllDataofEnquire=await ApiCalls.getFullDataOfEnquire(widget.id);
          setState(() {
       getAllDropdownEnquireInCard;
       fname.text=getAllDataofEnquire.fname??"";
       lname.text=getAllDataofEnquire.lname??"";
       email.text=getAllDataofEnquire.email??"";
       company.text=getAllDataofEnquire.companyName??"";
       whatsapp.text=getAllDataofEnquire.whatsappNo??"";
       phone.text=(getAllDataofEnquire.phone??0).toString();
       enquireDate.text=getAllDataofEnquire.enqDetailMsg??"";
       enquireDate.text=getAllDataofEnquire.enquiryDate??"";
       estimateClousreDate.text=getAllDataofEnquire.estimatedClosureDate??"";
       datasource.text=getAllDataofEnquire.dataSource??"";
       enquireStatusDropdown.enquiryStatus=getAllDataofEnquire.enquiryStatus;
     });
      Navigator.pop(context);   

      print(getAllDropdownEnquireInCard.applicantType);
    enquireComment=await ApiCalls.getEnquireComment((sharedPreferences.getInt("account_id")).toString(),widget.id.toString());
    // print(enquireComment.length);
  
 
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent.shade100,
        onPressed: (){
              showDialog(
                barrierDismissible: true,
                context: context, builder: (context){
                return Dialog(
                  child: Scaffold(
                  appBar: AppBar(title: Text("Comments"),centerTitle: true,),
                  body: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: enquireComment.length,
                      itemBuilder: (context,index){
                      return EnquireComment(name: enquireComment[index].createdFname??"", date: enquireComment[index].updatedAt??"", comment: enquireComment[0].message??"", nextfollupdate: enquireComment[0].followUpDate??"", status: "followup",profile: enquireComment[0].profilePath??"profilepicture/G1SMGwzAvl1eYTZhsh7YfqVFMD9m0ElikUIIQGGy.webp",);
                    }),
                  ),
                  ),
                );
              });
      },
      child: Icon(Icons.chat),
      ),
      appBar: AppBar(title: Text("Clients Information"),
      centerTitle: true,
      ),
      body: ListView(
        children: [
          Card(
            
            margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
            elevation: 1,
              color: Colors.white,
            child: Container(

           decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 196, 196, 196),width: 0.5),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white
           ),
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Text("Personal Information",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                                        // SizedBox(height: 10,),
                         SizedBox(height: 4,),

                        TextFormField(
                        
                          controller: fname,
                          decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                            labelStyle: TextStyle(fontSize: 14),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.lerp(BorderSide(color: Colors.blueAccent), BorderSide(color: Colors.blueAccent), 10,)
                            ),
                            label: Text("First Name",textAlign: TextAlign.center,),
                           
                           
                            
                          ),
                        ),
                        SizedBox(height: 6,),
                        TextFormField(
                          controller: lname,
                          decoration: InputDecoration(
                            label: Text("Last Name"),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            labelStyle: TextStyle(fontSize: 14)
                            // border: OutlineInputBorder(
                            //   borderSide: BorderSide.none,
                            //   borderRadius: BorderRadius.circular(15)
                            // )
                          ),
                        ),
                                            SizedBox(height: 6,),

                        TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                            label: Text("Email address"),
                            // label: Icon(Icons.email_outlined),
                            contentPadding: EdgeInsets.zero,
                              isDense: true,
                            labelStyle: TextStyle(fontSize: 14)
                            // border: OutlineInputBorder(
                            //     borderSide: BorderSide.none,
                            //   borderRadius: BorderRadius.circular(15)
                            // )
                          ),
                        ),
                                                SizedBox(height: 6,),

                        TextFormField(
                          controller: company,
                          decoration: InputDecoration(
                            label: Text("Comapny Name"),
                                                        contentPadding: EdgeInsets.zero,

                              isDense: true,
                            labelStyle: TextStyle(fontSize: 14)
                            // border: OutlineInputBorder(
                            //     borderSide: BorderSide.none,
                            //   borderRadius: BorderRadius.circular(15)
                            // )
                          ),
                        ),
                                              SizedBox(height: 6,),

                        TextFormField(
                          controller: whatsapp,
                          decoration: InputDecoration(
                            label: Text("WhatsApp No"),
                                                        contentPadding: EdgeInsets.zero,

                              isDense: true,
                            labelStyle: TextStyle(fontSize: 14)
                            // border: OutlineInputBorder(
                            //     borderSide: BorderSide.none,
                            //   borderRadius: BorderRadius.circular(15)
                            // )
                          ),
                        ),
                                         SizedBox(height: 6,),

                        TextFormField(
                          controller: phone,
                          decoration: InputDecoration(
                              isDense: true,
                            label: Text("Phone No",),
                            contentPadding: EdgeInsets.zero,
                            labelStyle: TextStyle(fontSize: 14)
                            // border: OutlineInputBorder(
                            //     borderSide: BorderSide.none,
                            //   borderRadius: BorderRadius.circular(15)
                            // )
                          ),
                        ),
                            
                         SizedBox(height: 6,),

                
                        Text("Created By Darshan Wakurde Date: 12/3/2024",style:TextStyle(fontSize: 12))
                        
                          ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Card(
                 margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
            elevation: 2,
              color: Colors.white,
            child: Container(
              
            decoration: BoxDecoration(
               border: Border.all(color: Color.fromARGB(255, 196, 196, 196),width: 0.5),
              borderRadius: BorderRadius.circular(7),
              color: Colors.white
            ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                        Text("Enquiry Information",style: TextStyle(fontSize: 24,fontWeight: FontWeight.w500),),
                                        SizedBox(height: 10,),

                        TextFormField(
                          controller: fname,
                     
                          decoration: InputDecoration(
                            
                            label: Text("Enquiry Details"),
                            contentPadding: EdgeInsets.zero,
                            // contentPadding: EdgeInsets.fromLTRB(5, 2, 2, 2),
                           
                          isDense: true,

                          ),
                        ),
                        SizedBox(height: 2,),
                        TextFormField(
                          controller: enquireDate,
                            readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: ()async{
                                    DateTime? date= await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2099));
                                        setState(() {
                                          
                                                enquireDate.text='${date!.day}/${date!.month}/${date!.year}';
                                             }); 
                              },
                              child: Icon(Icons.calendar_month_outlined)),
                            label: Text("Enquiry Date",style: TextStyle(fontSize: 14)),
                            isDense: true,
                            contentPadding: EdgeInsets.zero
                          ),
                        ),
                                                SizedBox(height: 2,),

                        TextFormField(
                          controller: estimateClousreDate,
                            readOnly: true,
                          decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                              onTap: ()async{
                                    DateTime? date= await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2099));
                                        setState(() {
                                          
                                                estimateClousreDate.text='${date!.day}/${date!.month}/${date!.year}';
                                             });
                              },
                              child: Icon(Icons.calendar_month_outlined)),
                            label: Text("Estimate Clousare Date",style: TextStyle(fontSize: 14)),
                              isDense: true,
                         contentPadding: EdgeInsets.zero
                          ),
                        ),
                                                SizedBox(height: 2,),

                        TextFormField(
                          controller: newAppointment,
                            readOnly: true,
                          decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                              onTap: ()async{
                                    DateTime? date= await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2099));
                                                setState(() {
                                                newAppointment.text='${date!.day}/${date!.month}/${date!.year}';
                                             });
                              },
                              child: Icon(Icons.calendar_month_outlined)),
                            label: Text("New Appointment Date",style: TextStyle(fontSize: 14),),
                            isDense: true,
                         contentPadding: EdgeInsets.zero
                          ),
                        ),
                                                SizedBox(height: 10,),
  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.05,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    // border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                   
                                    menuMaxHeight: 120,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(enquireStatusDropdown.enquiryStatus??"",style: TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,)),
                                    items:  (getAllDropdownEnquireInCard.enquiryStatus??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.enquiryStatus,
                                    child: Text(item.enquiryStatus??"",style: TextStyle(fontSize: 14),),
                                  )).toList(), onChanged:(item){
                             getAllDropdownEnquireInCard.enquiryStatus!.forEach((element) {
                                          (element.enquiryStatus==item)?setState(() {
                                            enquireStatusDropdown=element;
                                          }):null;
                                     });
                                
                    
                                    print(item);
                                  } )),
                                                                                  SizedBox(height: 5,),

  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.05,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    // border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                   
                                    menuMaxHeight: 120,

                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(enquireSourceDropdown.enquirySource??"",style: TextStyle(fontSize: 15,color: Colors.black),textAlign: TextAlign.center,)),
                                    items:  (getAllDropdownEnquireInCard.enquirySources??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.enquirySource,
                                    child: Text(item.enquirySource??"",style: TextStyle(fontSize: 14),),
                                  )).toList(), onChanged:(item){
                             getAllDropdownEnquireInCard.enquirySources!.forEach((element) {
                                          (element.enquirySource==item)?setState(() {
                                            enquireSourceDropdown=element;
                                          }):null;
                                     });
                                
                    
                                    print(item);
                                  } )),

                                                                                  SizedBox(height: 10,),

  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.05,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    // border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    
                                   menuMaxHeight: 120,

                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(enquiretypeDropdown.enquiryType??"",style: TextStyle(fontSize: 15,color: Colors.black),textAlign: TextAlign.center,)),
                                    items:  (getAllDropdownEnquireInCard.enquiryType??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.enquiryType,
                                    child: Text(item.enquiryType??"",style: TextStyle(fontSize: 14),),
                                  )).toList(), onChanged:(item){
                             getAllDropdownEnquireInCard.enquiryType!.forEach((element) {
                                          (element.enquiryType==item)?setState(() {
                                            enquiretypeDropdown=element;
                                          }):null;
                                     });
                                
                    
                                    print(item);
                                  } )),
                                                                                  SizedBox(height: 10,),

  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.05,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    // border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    menuMaxHeight: 200,
                                
                                   

                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(assingedTo.firstName??"",style: TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,)),
                                    items:  (getAllDropdownEnquireInCard.assingedTo??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.firstName,
                                    child: Text(item.firstName??"",style: TextStyle(fontSize: 14),),
                                  )).toList(), onChanged:(item){
                             getAllDropdownEnquireInCard.assingedTo!.forEach((element) {
                                          (element.firstName==item)?setState(() {
                                           assingedTo=element;
                                          }):null;
                                     });
                                
                    
                                    print(item);
                                  } )),
                                                                                  SizedBox(height: 5,),

  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.05,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                  
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(leadLevelDropdown.leadLevel??"",style: TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,)),
                                    items:  (getAllDropdownEnquireInCard.leadLevel??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.leadLevel,
                                    child: Text(item.leadLevel??"",style: TextStyle(fontSize: 14),),
                                  )).toList(), onChanged:(item){
                             getAllDropdownEnquireInCard.leadLevel!.forEach((element) {
                                          (element.leadLevel==item)?setState(() {
                                            leadLevelDropdown=element;
                                          }):null;
                                     });
                                
                    
                                    print(item);
                                  } )),

                                     SizedBox(height: 10,),


                                    TextFormField(
                          controller: datasource,
                     
                          decoration: InputDecoration(
                            
                            label: Text("Data Source"),
                              isDense: true,
                              contentPadding: EdgeInsets.zero
                          ),
                        ),
                       
                        
                          ],
                ),
              ),
            ),
          ),

                                     SizedBox(height: 20,),



            Card(
color: Colors.white,
elevation: 2,
    margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                 border: Border.all(color: Color.fromARGB(255, 196, 196, 196),width: 0.5),
              ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                          Text("Comments",style: TextStyle(fontSize: 24,fontWeight: FontWeight.w500),),
                        SizedBox(height: 20,),
                         TextFormField(
                                                                       
                                                                 
                                                                       decoration: InputDecoration(
                                                                         label: Text("Post Comment"),
                                                                         hintText: "Post Comment",
                                                                         border: OutlineInputBorder(
                                                                           borderRadius: BorderRadius.circular(8)
                                                                         )
                                                                       ),
                                                                       controller: commentTextField,
                                                                    minLines: 5, // any number you need (It works as the rows for the textarea)
                                                                    keyboardType: TextInputType.multiline,
                                                                    maxLines: null,
                                                                 ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Internal Comment"),
                        Checkbox(
                          activeColor: Colors.blueAccent,
                          value: intercheck, onChanged: (inter){
                         setState(() {
                           intercheck=inter??false;
                            notifyCustomer=!intercheck;
                         });
                        }),
                        SizedBox(width:5,),
                         Text("Notify Customer"),
                        Checkbox(
                          activeColor: Colors.blueAccent,
                          value: notifyCustomer, onChanged: (notifyCust){
                         setState(() {
                           notifyCustomer=notifyCust??false;
                            intercheck=!notifyCustomer;
                         });
                        }),
                      ],
                    ),

SizedBox(height: 10,),
                     Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.065,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    menuMaxHeight: 200,
                                   
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(commentstatus.commentStatus??"",style: TextStyle(fontSize: 14,color: Colors.black),textAlign: TextAlign.center,)),
                                    items:  (getAllDropdownEnquireInCard.commentStatus??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.commentStatus,
                                    child: Text(item.commentStatus??"",style: TextStyle(fontSize: 14),),
                                  )).toList(), onChanged:(item){
                             getAllDropdownEnquireInCard.commentStatus!.forEach((element) {
                                          (element.commentStatus==item)?setState(() {
                                            commentstatus=element;
                                          }):null;
                                     });
                                
                    
                                    print(item);
                                  } )),
SizedBox(height: 10,),

TextFormField(
                          controller: estimateClousreDate,
                            readOnly: true,
                          decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                              onTap: ()async{
                                    DateTime? date= await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2099));
                                        setState(() {
                                          
                                                followupdate.text='${date!.day}/${date!.month}/${date!.year}';
                                             });
                              },
                              child: Icon(Icons.calendar_month_outlined)),
                            label: Text("Follow up Date",style: TextStyle(fontSize: 14)),
                            isDense: true,
                            contentPadding: EdgeInsets.zero
                            ),
                        ),
SizedBox(height: 15,),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(padding: EdgeInsets.all(10),
                          child: ElevatedButton(onPressed: ()async{
                              SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
                             String response= await ApiCalls.postEnquireCOmments(noticommenttoCusto.toString(), widget.id.toString(), followupdate.text, commentstatus.commentStatus??"", "", commentTextField.text, (sharedPreferences.getInt("user_id")).toString(), (sharedPreferences.getInt("account_id")).toString());
                                 enquireComment=await ApiCalls.getEnquireComment((sharedPreferences.getInt("account_id")).toString(),widget.id.toString());
                                setState(() {
                                  enquireComment;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response)));

                          }, child: Text("Post Comment")),
                          ),
                        )


                    
                      ],
                    ),
                  ),
                ),

            ),



             SizedBox(height: 20,),
        ],
      ),
    );
  }
}