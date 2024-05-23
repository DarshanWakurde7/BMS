import 'dart:math';

import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/pojos/models/FilterDataPojo.dart';
import 'package:bms/widgets/TitleofClentinfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getwidget/getwidget.dart';

class AddEnquireForm extends StatefulWidget {
  const AddEnquireForm({super.key});

  @override
  State<AddEnquireForm> createState() => __AddEnquireFormState();
}

class __AddEnquireFormState extends State<AddEnquireForm> with SingleTickerProviderStateMixin {

final controller = PageController(initialPage: 0);
late TabController tabController;

TextEditingController lastname= TextEditingController();
TextEditingController firstname= TextEditingController();
TextEditingController emailaddress= TextEditingController();
TextEditingController companyname= TextEditingController();
TextEditingController whatsappno= TextEditingController();
TextEditingController phoneno= TextEditingController();
TextEditingController address= TextEditingController();
TextEditingController state= TextEditingController();
TextEditingController enquireDetails= TextEditingController();
TextEditingController enquireDate= TextEditingController();
TextEditingController enquireClousreDate= TextEditingController();
TextEditingController nextAppointmentDate= TextEditingController();
TextEditingController notes= TextEditingController();

TextEditingController amount= TextEditingController();
TextEditingController dataSource= TextEditingController();
TextEditingController pincode= TextEditingController();
TextEditingController city= TextEditingController();

EnquiryType enquiredropdown=EnquiryType(enquiryType: "select Enquiry");
ApplicantType applicantDropdown=ApplicantType(applicantType: "Applicant Type");
EnquiryStatus enquireStatusDropdown=EnquiryStatus(enquiryStatus: "Enquiry Status");
EnquirySources enquireSourceDropdown=EnquirySources(enquirySource: "Enquiry Source");
LeadLevel leadLevelDropdown=LeadLevel(leadLevel: "Lead level");
AssingedTo assingedTo=AssingedTo(firstName: "Assign",lastName: "To*");

GetAllDropdownEnquire getAllDropDownData=GetAllDropdownEnquire();




void _validateForm() async{

  showDialog(context: context, builder: (context){
  return Dialog(
    backgroundColor: Colors.transparent,
    child: Center(
      child: Lottie.network("https://lottie.host/2fcce2a4-14ea-4f92-a8f9-997c441d3043/EbknVutwPu.json",width: 200),
    ),
  );
});
    final validators = [
      MyFormValidation.validateNotEmpty(lastname.text,"Last Name"),
      MyFormValidation.validateNotEmpty(firstname.text,"First name"),
      MyFormValidation.validateEmail(emailaddress.text),
      // MyFormValidation.validateNotEmpty(companyname.text),
      // MyFormValidation.validateNotEmpty(whatsappno.text),
      MyFormValidation.validateNotEmpty(phoneno.text,"Phone Number"),
      // MyFormValidation.validateNotEmpty(address.text),
      // MyFormValidation.validateNotEmpty(state.text),
      // MyFormValidation.validateNotEmpty(enquireDetails.text),
      // MyFormValidation.validateDate(enquireDate.text),
      // MyFormValidation.validateDate(enquireClousreDate.text),
      // MyFormValidation.validateDate(nextAppointmentDate.text),
      // MyFormValidation.validateNotEmpty(notes.text),
      // MyFormValidation.validateNotEmpty(amount.text),
      // MyFormValidation.validateNotEmpty(dataSource.text),
      // MyFormValidation.validateNotEmpty(pincode.text),
      // MyFormValidation.validateNotEmpty(city.text),
    ];

    for (var validatorMessage in validators) {
      if (validatorMessage != null) {
        MyFormValidation.showSnackBar(context, validatorMessage);
        
   Navigator.pop(context); 
        return;
      }
    }

SharedPreferences sharedPreferences=await SharedPreferences.getInstance();

print('userid: ${sharedPreferences.getInt('user_id')}');


String data=await ApiCalls.addEnquireCall(firstname.text, lastname.text, phoneno.text, emailaddress.text, 
state.text, city.text, enquireDetails.text, whatsappno.text, companyname.text, (sharedPreferences.getInt('user_id')).toString(), 
(sharedPreferences.getInt('account_id')).toString(), enquireDate.text, dataSource.text, address.text,
(enquiredropdown.enquiryTypeId==null?"":enquiredropdown.enquiryTypeId).toString(), (applicantDropdown.applicantTypeId==null?"":applicantDropdown.applicantTypeId).toString(), (enquireSourceDropdown.enquiryModeId==null?"":enquireSourceDropdown.enquiryModeId ).toString(),(leadLevelDropdown.leadLevelId==null?"":leadLevelDropdown.leadLevelId ).toString(), (enquireStatusDropdown.enquiryStatusId==null?"":enquireStatusDropdown.enquiryStatusId).toString(), (assingedTo.userId==null?"":assingedTo.userId).toString(), enquireClousreDate.text, nextAppointmentDate.text, notes.text);

Navigator.pop(context);
   ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(data),
      backgroundColor: Colors.blueAccent,
      duration: Duration(milliseconds: 800),
    )
   );   

   Navigator.pop(context); 



  }






























double page=1/4;

@override
  void initState() {
    getDataofDropdownApi();
    tabController=TabController(length: 0, vsync: this,initialIndex: 0);
    // TODO: implement initState
    super.initState();
  }


  getDataofDropdownApi()async{
       getAllDropDownData=await ApiCalls.getAllDropDOwnsEnquire();
       print(getAllDropDownData.leadLevel);
       setState(() {
         getAllDropDownData;
       });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        
        foregroundColor: Colors.blueAccent.shade200,
        onPressed: 
_validateForm
      ,child: Text("Save",style: TextStyle(color: Colors.black),),),
      appBar: AppBar(
        title: Text("Clients Information"),
        centerTitle: true,
        bottom: PreferredSize(preferredSize: Size.fromHeight(30), child:  Center(
          child: GFProgressBar(
               percentage: page,
               lineHeight: 10,
               width:372,
               radius: 150,
               backgroundColor : Colors.white,
               progressBarColor: Colors.blueAccent.shade100,
          ),
        )),
      ),
      body:PageView(
      onPageChanged: (val){
        setState(() {
          page=(val+1)/4;
        });
      },
        children: [

              SingleChildScrollView(
                child: Padding(
                  
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      SizedBox(height: 40,),
                         CatdTitle(title: "Personal Details",),
                         
                          SizedBox(height: 20,),
                                TextFormField(
                                  
                                  controller: firstname,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    label: Text("First Name"),
                                 border: UnderlineInputBorder(borderSide: BorderSide()),
                                    isDense: true
                                  ),
                                ),
                                   SizedBox(height: 20,),
                                TextFormField(
                                  controller: lastname,
                                  decoration: InputDecoration(
                                     contentPadding: EdgeInsets.zero,
                                    label: Text("Last Name"),
                                    border: UnderlineInputBorder(borderSide: BorderSide()),
                                    isDense: true
                                  ),
                                ),
                                SizedBox(height: 20,),
                                TextFormField(
                                  controller: emailaddress,
                                  decoration: InputDecoration(
                                    label: Text("Email Address"),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    isDense: true
                                  ),
                                ),
                                SizedBox(height: 20,),
                                TextFormField(
                                  controller: companyname,
                                  decoration: InputDecoration(
                                    label: Text("Comapny Name"),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    isDense: true
                                  ),
                                ),
                                
                                                  SizedBox(height: 20,),
                          
                                TextFormField(
                                  controller: whatsappno,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    label: Text("Whatsup no"),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    isDense: true
                                  ),
                                ),
                                                  SizedBox(height: 20,),
                          
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: phoneno,
                                  decoration: InputDecoration(
                                    label: Text("Phone no"),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    isDense: true
                                  ),
                                ),
                  
                    ],
                  ),
                ),
              ),


               Padding(
                 padding: const EdgeInsets.all(15.0),
                 child: SingleChildScrollView(
                   child: Column(
                            children: [
                                               SizedBox(height: 40,),
                             CatdTitle(title: "Address Details",),
                          
                             
                              SizedBox(height: 25,),
                          
                               TextFormField(
                                
                          
                                decoration: InputDecoration(
                                  label: Text("Address"),
                                  hintText: "Address",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)
                                  )
                                ),
                                controller: address,
                             minLines: 5, // any number you need (It works as the rows for the textarea)
                             keyboardType: TextInputType.multiline,
                             maxLines: null,
                          ),
                           SizedBox(height: 20,),
                             TextFormField(
                                    controller: city,
                                    decoration: InputDecoration(
                                      label: Text("City"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      isDense: true
                                    ),
                                  ),
                                   SizedBox(height: 20,),
                          
                             TextFormField(
                                    controller: state,
                                    decoration: InputDecoration(
                                      label: Text("State"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      isDense: true
                                    ),
                                  ),
                                   SizedBox(height: 20,),
                          
                             TextFormField(
                                    controller: pincode,
                                  keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      
                                      label: Text("Pincode"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      isDense: true
                                    ),
                                  ),
                          
                            
                            ],
                          ),
                 ),
               ),





 Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                      
                                      SizedBox(height: 40,),
                         CatdTitle(title: "Enquiry Details",),
                          SizedBox(height: 25,),
                         TextFormField(
                                
                          
                                decoration: InputDecoration(
                                  label: Text("Enquiry Details"),
                                  hintText: "Enquiry Details",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)
                                  )
                                ),
                                controller: enquireDetails,
                             minLines: 3, // any number you need (It works as the rows for the textarea)
                             keyboardType: TextInputType.multiline,
                             maxLines: null,
                          ),
                         
                                   SizedBox(height: 20,),
                          
                           
                                   
                          
                      
                        
                      
                      
                                  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.065,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    underline: Text(""),
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(enquiredropdown.enquiryType??"",style: TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,)),
                                    items: (getAllDropDownData.enquiryType??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.enquiryType,
                                    child: Text(item.enquiryType??"",style: TextStyle(fontSize: 14,color: Colors.black),),
                                  )).toList(), onChanged:(item){
                            getAllDropDownData.enquiryType!.forEach((element) {
                                          (element.enquiryType==item)?setState(() {
                                            enquiredropdown=element;
                                          }):null;
                                     });
                                
                    
                                  } )),
                                    SizedBox(height: 20,),
                                  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.065,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    underline: Text(""),
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(enquireStatusDropdown.enquiryStatus??"",style: TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,)),
                                    items:  (getAllDropDownData.enquiryStatus??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.enquiryStatus,
                                    child: Text(item.enquiryStatus??"",style: TextStyle(fontSize: 14,color: Colors.black),),
                                  )).toList(), onChanged:(item){
                             getAllDropDownData.applicantType!.forEach((element) {
                                          (element.applicantType==item)?setState(() {
                                            applicantDropdown=element;
                                          }):null;
                                     });
                                
                    
                                    print(item);
                                  } )),
                                    SizedBox(height: 20,),
                                           TextFormField(
                                    controller: amount,
                                  keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      
                                      label: Text("Amount"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      isDense: true
                                    ),
                                  ),
                                    SizedBox(height: 20,),
                                  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.065,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    underline: Text(""),
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(enquireSourceDropdown.enquirySource??"",style: TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,)),
                                    items: (getAllDropDownData.enquirySources??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.enquirySource,
                                    child: Text(item.enquirySource??"",style: TextStyle(fontSize: 14,color: Colors.black),),
                                  )).toList(), onChanged:(item){
                                  getAllDropDownData.enquirySources!.forEach((element) {
                                          (element.enquirySource==item)?setState(() {
                                            enquireSourceDropdown=element;
                                          }):null;
                                     });
                                
                    
                                    print(item);
                                  } )),
                                    SizedBox(height: 20,),
                                      TextFormField(
                                    controller: dataSource,
                                    decoration: InputDecoration(
                                      label: Text("Data Source"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      isDense: true
                                    ),
                                  ),
                                    SizedBox(height: 20,),
                                  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.065,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    underline: Text(""),
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text(leadLevelDropdown.leadLevel??"",style: TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,)),
                                    items: (getAllDropDownData.leadLevel??[]).map((item)=>DropdownMenuItem<String>(
                                    value: item.leadLevel,
                                    child: Text(item.leadLevel??"",style: TextStyle(fontSize: 14,color: Colors.black),),
                                  )).toList(), onChanged:(item){
                              getAllDropDownData.leadLevel!.forEach((element) {
                                          (element.leadLevel==item)?setState(() {
                                            leadLevelDropdown=element;
                                          }):null;
                                     });
                                
                    
                                  } )),
                                    SizedBox(height: 20,),
                                  Container(
                                  
                               
                                  height: MediaQuery.of(context).size.height*0.065,
                                  width: double.infinity,
                                     decoration: BoxDecoration(
                      
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.black54),
                                    color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    menuMaxHeight: 150,
                                    underline: Text(""),
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(25),
                                    hint: Padding(
                                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                      child: Text((assingedTo.firstName??""+" "+(assingedTo.lastName??"")),style: TextStyle(fontSize: 16,color: Colors.black),textAlign: TextAlign.center,)),
                                    items: (getAllDropDownData.assingedTo??[]).map((item)=>DropdownMenuItem<String>(
                                    value: (item.firstName??""+" "+(item.lastName??"")),
                                    child: Text((item.firstName??""+" "+(item.lastName??"")),style: TextStyle(fontSize: 14,color: Colors.black),),
                                  )).toList(), onChanged:(item){
        
                                    getAllDropDownData.assingedTo!.forEach((element) {
                                          (element.firstName==item)?setState(() {
                                            assingedTo=element;
                                          }):null;
                                     });
                                
                    
                                  } )),
                                    SizedBox(height: 20,),
                                  // Container(
                                  
                               
                                  // height: MediaQuery.of(context).size.height*0.065,
                                  // width: double.infinity,
                                  //    decoration: BoxDecoration(
                      
                                  //   borderRadius: BorderRadius.circular(15),
                                  //   border: Border.all(color: Colors.black54),
                                  //   color: Colors.white
                                  // ),
                                  // child: DropdownButton<String>(
                                  //   underline: Text(""),
                                  //   isExpanded: true,
                                  //   borderRadius: BorderRadius.circular(25),
                                  //   hint: Padding(
                                  //     padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  //     child: Text(ass,style: TextStyle(fontSize: 16,color: Colors.grey),textAlign: TextAlign.center,)),
                                  //   items: lsitdata.map((item)=>DropdownMenuItem<String>(
                                  //   value: item,
                                  //   child: Text(item,style: TextStyle(fontSize: 14),),
                                  // )).toList(), onChanged:(item){
                                  //   setState(() {
                                  //     datadrop=item.toString();
                                  //   });
                                  //   print(item);
                                  // } )),
                                                  SizedBox(height: 30,),




                                                  
              
                        
                        ],
                      ),
                    ),
                  ),


 SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                      
                                      SizedBox(height: 40,),
                         CatdTitle(title: "Internal Information",),
                         
                          SizedBox(height: 25,),
                      
                           Padding(
                                                  padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                                                  child: TextField(
                                                    
                                                    readOnly: true,
                                                    controller: enquireDate,
                                                    decoration: InputDecoration(
                                                      
                                                      label: Text(" Enquiry Date"),
                                                     
                                                      isDense: true,
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.black),
                                                        borderRadius: BorderRadius.circular(15)),
                                                      suffixIcon: GestureDetector(
                                                        onTap: ()async{
                          DateTime? date= await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2099));
                                                         print('${date!.day}/${date!.month}/${date!.year}');
                                                         setState(() {
                                                            enquireDate.text='${date!.year}/${date!.month}/${date!.day}';
                                                         });                                            },
                                                        child: Icon(Icons.date_range_outlined))
                                                    ),
                                                  ),
                                                ),
                                                  SizedBox(height: 20,),
                           Padding(
                                                  padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                                                  child: TextField(
                                                    
                                                    readOnly: true,
                                                    controller: enquireClousreDate,
                                                    decoration: InputDecoration(
                                                      
                                                      label: Text(" Enquiry Clouser Date"),
                                                     
                                                      isDense: true,
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.black),
                                                        borderRadius: BorderRadius.circular(15)),
                                                      suffixIcon: GestureDetector(
                                                        onTap: ()async{
                          DateTime? date= await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2099));
                                                         print('${date!.day}/${date!.month}/${date!.year}');
                                                         setState(() {
                                                            enquireClousreDate.text='${date!.year}/${date!.month}/${date!.day}';
                                                         });                                            },
                                                        child: Icon(Icons.date_range_outlined))
                                                    ),
                                                  ),
                                                ),
                                                  SizedBox(height: 20,),
                           Padding(
                                                  padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                                                  child: TextField(
                                                    
                                                    readOnly: true,
                                                    controller: nextAppointmentDate,
                                                    decoration: InputDecoration(
                                                      
                                                      label: Text(" Next Appointment Date"),
                                                     
                                                      isDense: true,
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.black),
                                                        borderRadius: BorderRadius.circular(15)),
                                                      suffixIcon: GestureDetector(
                                                        onTap: ()async{
                          DateTime? date= await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2099));
                                                         print('${date!.day}/${date!.month}/${date!.year}');
                                                         setState(() {
                                                            nextAppointmentDate.text='${date!.year}/${date!.month}/${date!.day}';
                                                         });                                            },
                                                        child: Icon(Icons.date_range_outlined))
                                                    ),
                                                  ),
                                                ),
                                                  SizedBox(height: 20,),
                                                   Padding(
                                                      padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                                                     child: TextFormField(
                                                                         
                                                                   
                                                                         decoration: InputDecoration(
                                                                           label: Text("Notes"),
                                                                           hintText: "Notes",
                                                                           border: OutlineInputBorder(
                                                                             borderRadius: BorderRadius.circular(8)
                                                                           )
                                                                         ),
                                                                         controller: notes,
                                                                      minLines: 5, // any number you need (It works as the rows for the textarea)
                                                                      keyboardType: TextInputType.multiline,
                                                                      maxLines: null,
                                                                   ),
                                                   ),
                                            SizedBox(height: 20,),
                      
                        ],
                      ),
                    ),
 ),
        ],
      )
        
      
    );
  


  }



}


class MyFormValidation {
  static dynamic validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email address is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static dynamic validateDate(String value) {
    if (value.isEmpty) {
      return 'Date is required';
    } else if (!RegExp(r'^\d{4}/\d{1,2}/\d{2}$').hasMatch(value)) {
      return 'Enter a date in YYYY/MM/DD format';
    }
    return null;
  }

  static dynamic validateNotEmpty(String value,String fields) {
    if (value.isEmpty) {
      return '${fields}All Field is required';
    }
    return null;
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(message),
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}