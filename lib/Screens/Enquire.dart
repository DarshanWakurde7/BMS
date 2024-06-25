import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/AddFormScreen.dart';
import 'package:bms/Screens/EnquirefullInfo.dart';
import 'package:bms/controller/enquireCardsController.dart';
import 'package:bms/pojos/models/Enquirepojo.dart';
import 'package:bms/pojos/models/FilterDataPojo.dart';
import 'package:bms/widgets/EnquireCardDesign.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyEnquire extends StatefulWidget {
  const MyEnquire({super.key});

  @override
  State<MyEnquire> createState() => _MyEnquireState();
}

class _MyEnquireState extends State<MyEnquire> {
  List<ValueItem<int>> EnqSatus = [];
  List<ValueItem<int>> assignedtp = [];
  List<ValueItem<int>> enqType = [];
  List<ValueItem<int>> enqSource = [];
  TextEditingController searchEnquire = TextEditingController();
  TextEditingController fromdate = TextEditingController();
  TextEditingController todate = TextEditingController();
  TextEditingController updatedate = TextEditingController();
  TextEditingController enqdate = TextEditingController();

  String dropdowndata = "select one";

  GetAllDropdownEnquire getAllDropDownData = GetAllDropdownEnquire();
  EnquireCardsController enquireCardsController =
      Get.put(EnquireCardsController());

  @override
  void initState() {
    getdataForFirst();
    // TODO: implement initState
    super.initState();
  }

  getdataForFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getdata([], [prefs.getInt("user_id") ?? 1], [], [], '09/24/2022', '', '',
        '', '', '', '50');
    getAllDropDownData = await ApiCalls.getAllDropDOwnsEnquire();
  }

  void getdata(
      List<int> enqids,
      List<int> assigned,
      List<ValueItem> Enqsource,
      List<ValueItem> EnqType,
      String createdDatefrom,
      String createdDateto,
      String updatedfromdate,
      String updatedtodate,
      String enqfromdate,
      String Enqtodate,
      String EnqCount) async {
    print(assignedtp);

    enquireCardsController.getEnquireCards(
        enqids,
        assigned,
        Enqsource,
        EnqType,
        createdDatefrom,
        createdDateto,
        updatedfromdate,
        updatedtodate,
        enqfromdate,
        Enqtodate,
        EnqCount);
    getAllDropDownData = await ApiCalls.getAllDropDOwnsEnquire();

    setState(() {
      getAllDropDownData;
    });
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<String> lsitdata = ["50", "100", "GetAll"];
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        semanticLabel: "Filter",
        child: Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.blueAccent.shade100,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 5),
                    height: MediaQuery.of(context).size.height * 0.12,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Text(
                      'Enquiry Filters',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "   Enquiry Status",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                  child: MultiSelectDropDown(
                      hintPadding: EdgeInsets.zero,
                      borderWidth: 0,
                      padding: EdgeInsets.all(5),
                      onOptionSelected: (value) {
                        setState(() {
                          EnqSatus = value;
                        });
                      },
                      options: (getAllDropDownData.enquiryStatus ?? [])
                          .map((e) => ValueItem(
                              label: e.enquiryStatus ?? "",
                              value: e.enquiryStatusId))
                          .toList()),
                ),
                Text(
                  "   Assigned to ",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                  child: MultiSelectDropDown(
                      searchEnabled: true,
                      padding: EdgeInsets.all(5),
                      onOptionSelected: (value) {
                        setState(() {
                          assignedtp = value;
                        });
                      },
                      options: (getAllDropDownData.assingedTo ?? [])
                          .map((e) => ValueItem(
                              label: (e.firstName ?? "") +
                                  " " +
                                  (e.lastName ?? ""),
                              value: e.userId))
                          .toList()),
                ),
                Text(
                  "   Enquiry Type ",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                  child: MultiSelectDropDown(
                    padding: EdgeInsets.all(5),
                    onOptionSelected: (value) {
                      setState(() {
                        enqType = value;
                      });
                    },
                    options: (getAllDropDownData.enquiryType ?? [])
                        .map((e) => ValueItem(
                            label: (e.enquiryType ?? ""),
                            value: e.enquiryTypeId))
                        .toList(),
                  ),
                ),
                Text(
                  "   Enquiry Source ",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                  child: MultiSelectDropDown(
                      padding: EdgeInsets.all(5),
                      onOptionSelected: (value) {
                        setState(() {
                          enqSource = value;
                        });
                      },
                      options: (getAllDropDownData.enquirySources ?? [])
                          .map((e) => ValueItem(
                              label: (e.enquirySource ?? ""),
                              value: e.enquiryModeId))
                          .toList()),
                ),
                Text(
                  "   From Created Date ",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: TextField(
                    readOnly: true,
                    controller: fromdate,
                    decoration: InputDecoration(
                        label: Text(" created Date"),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(40)),
                        suffixIcon: GestureDetector(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2099));
                              print(
                                  '${date!.day}/${date!.month}/${date!.year}');
                              setState(() {
                                fromdate.text =
                                    '${date!.day}/${date!.month}/${date!.year}';
                              });
                            },
                            child: Icon(Icons.date_range_outlined))),
                  ),
                ),
                Text(
                  "   To Created Date ",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: TextField(
                    readOnly: true,
                    controller: todate,
                    decoration: InputDecoration(
                        label: Text(" To Created Date"),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(40)),
                        suffixIcon: GestureDetector(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2099));
                              print(
                                  '${date!.day}/${date!.month}/${date!.year}');
                              setState(() {
                                todate.text =
                                    '${date!.day}/${date!.month}/${date!.year}';
                              });
                            },
                            child: Icon(Icons.date_range_outlined))),
                  ),
                ),
                Text(
                  "   Updated Date ",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: TextField(
                    readOnly: true,
                    controller: updatedate,
                    decoration: InputDecoration(
                        label: Text(" Updated Date"),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(40)),
                        suffixIcon: GestureDetector(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2099));
                              print(
                                  '${date!.day}/${date!.month}/${date!.year}');
                              setState(() {
                                updatedate.text =
                                    '${date!.day}/${date!.month}/${date!.year}';
                              });
                            },
                            child: Icon(Icons.date_range_outlined))),
                  ),
                ),
                Text(
                  "   Enquiry Date ",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: TextField(
                    readOnly: true,
                    controller: enqdate,
                    decoration: InputDecoration(
                        label: Text(" Enquiry Date"),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(40)),
                        suffixIcon: GestureDetector(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2099));
                              print(
                                  '${date!.day}/${date!.month}/${date!.year}');
                              setState(() {
                                enqdate.text =
                                    '${date!.day}/${date!.month}/${date!.year}';
                              });
                            },
                            child: Icon(Icons.date_range_outlined))),
                  ),
                ),
                Text(
                  "   Enquiry Count",
                  style: TextStyle(fontSize: 15),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    height: MediaQuery.of(context).size.height * 0.065,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black54),
                        color: Colors.white),
                    child: DropdownButton<String>(
                        underline: Text(""),
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(40),
                        hint: Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Text(
                              dropdowndata,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            )),
                        items: lsitdata
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ))
                            .toList(),
                        onChanged: (item) {
                          setState(() {
                            dropdowndata = item.toString();
                          });
                          print(item);
                        })),
                Text(
                  "   Updated Date ",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
                  child: TextField(
                    readOnly: true,
                    controller: updatedate,
                    decoration: InputDecoration(
                        label: Text(" Updated Date"),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(40)),
                        suffixIcon: GestureDetector(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2099));
                              print(
                                  '${date!.day}/${date!.month}/${date!.year}');
                              setState(() {
                                updatedate.text =
                                    '${date!.day}/${date!.month}/${date!.year}';
                              });
                            },
                            child: Icon(Icons.date_range_outlined))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () async {
                        print(assignedtp.map((id) => id.value).toList());
                        getdata(
                            EnqSatus.map((id) => id.value ?? 0).toList(),
                            assignedtp.map((id) => id.value ?? 0).toList(),
                            enqSource.map((item) => item).toList(),
                            enqType.map((item) => item).toList(),
                            (fromdate.text.isEmpty) ? '' : fromdate.text,
                            (todate.text.isEmpty) ? '' : todate.text,
                            (updatedate.text.isEmpty) ? '' : updatedate.text,
                            (updatedate.text.isEmpty) ? '' : updatedate.text,
                            (enqdate.text.isEmpty) ? '' : enqdate.text,
                            (enqdate.text.isEmpty) ? '' : enqdate.text,
                            "50");

                        setState(() {
                          enquireCardsController.enquiredata;
                        });
                        Navigator.pop(context);
                      },
                      child: Text("Filter Data")),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: ((context) {
              return AddEnquireForm();
            })));
          },
          tooltip: "Add Enquiry",
          child: Icon(
            Icons.add,
            color: Colors.black,
            size: 30,
          ),
          foregroundColor: Colors.blueAccent,
        );
      }),
      appBar: AppBar(
        title: Text("Enquiries"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () {
                print("okk");
                _scaffoldKey.currentState!.openEndDrawer();
              },
              child: Icon(
                Icons.filter_alt_outlined,
                size: 30,
                color: Colors.blueAccent,
              ),
            ),
          )
        ],
      ),
      body: ListView(children: [
        Table(
          columnWidths: {
            0: FractionColumnWidth(0.7),
            1: FractionColumnWidth(0.3)
          },
          children: [
            TableRow(children: [
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  controller: searchEnquire,
                  onChanged: (val) {
                    serchdata(val);
                  },
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      label: Text("Search"),
                      labelStyle: TextStyle(fontSize: 14),
                      prefixIcon: Icon(Icons.search)),
                ),
              ),

//     Container(
//       margin: EdgeInsets.only(top: 10 ,right: 5),
// height: MediaQuery.of(context).size.height*0.045,
//       child: ElevatedButton(
//         style: ButtonStyle(
//           surfaceTintColor: MaterialStatePropertyAll(Colors.white),
//          ),
//         onPressed: (){

//           // showDialog(context: context, builder: (context){
//           //   String dropdata="Get Count";
//           //    List<String> lsitdata=["50","100","GetAll"];
//           //   return ;

//           // });

//       }, child: Row(
//         children: [
//           Icon(Icons.sort,color: Colors.black,size: 18,),
//           SizedBox(width: 4,),
//           Text("Filter",style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),),
//         ],
//       )),
//     )
            ])
          ],
        ),
        SizedBox(height: 20),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: double.infinity),
          child: Obx(() {
            if (enquireCardsController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if ((!enquireCardsController.isLoading.value) &&
                (enquireCardsController.enquiredata.isEmpty)) {
              return Center(
                child: Card(
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Enquiries not available",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemBuilder: (context, ind) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnquireFullInfo(
                                    id: enquireCardsController
                                            .enquiredata[ind].enquiryId ??
                                        0,
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 4, 10.0, 4),
                      child: MyWidget(
                        Name: (enquireCardsController.enquiredata[ind].fname ??
                                "") +
                            " " +
                            (enquireCardsController.enquiredata[ind].lname ??
                                ""),
                        type: enquireCardsController
                                .enquiredata[ind].enquiryType ??
                            "",
                        created: enquireCardsController
                                .enquiredata[ind].enquiryDate ??
                            "",
                        appointment: enquireCardsController
                                .enquiredata[ind].nextAppointmentDate ??
                            "",
                        require: enquireCardsController
                                .enquiredata[ind].enqDetailMsg ??
                            "empty",
                        phone:
                            enquireCardsController.enquiredata[ind].phone ?? 0,
                        whatsapp: int.parse(enquireCardsController
                                .enquiredata[ind].whatsappNo ??
                            "00"),
                        email: enquireCardsController.enquiredata[ind].email ??
                            "-",
                        dropval: enquireCardsController
                                .enquiredata[ind].enquiryStatus ??
                            "",
                        func: () {},
                        id: enquireCardsController.enquiredata[ind].enquiryId ??
                            0,
                      ),
                    ),
                  );
                },
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: ScrollPhysics(),
                itemCount: enquireCardsController.enquiredata.length,
              );
            }
          }),
        )
      ]),
    );
  }

  serchdata(String value) async {
    print(value);
    List<EnquiresPojo> result;
    if (value.isEmpty) {
      getdata([], [], [], [], '09/24/2022', '03/23/2024', '', '', '', '', '50');
      setState(() {
        enquireCardsController.enquiredata;
      });
      result = enquireCardsController.enquiredata;
    } else {
      result = enquireCardsController.enquiredata
          .where((element) => ((element.fname ?? "")
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              (element.enqDetailMsg ?? "")
                  .toLowerCase()
                  .contains(value.toLowerCase())))
          .toList();
    }

    setState(() {
      enquireCardsController.enquiredata = result;
    });
  }
}
