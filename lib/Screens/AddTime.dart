
import 'package:flutter/material.dart';




class GetTime extends StatefulWidget{
const GetTime({required this.getselected});

    final Function(TimeOfDay) getselected;
  @override
  State<StatefulWidget> createState() {
      return getTimeState();
  }






}


class getTimeState extends State<GetTime>{

   

 TimeOfDay? selectedDate;
@override
  void initState() {
 selectedDate=TimeOfDay(hour: 00, minute: 00);
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap: ()async{

TimeOfDay? day=await showTimePicker(context: context, initialTime:selectedDate!,initialEntryMode: TimePickerEntryMode.input);


setState(() {
  selectedDate=day??TimeOfDay(hour: 00, minute: 00);
});
widget.getselected(selectedDate!);

      },

      child: Text(selectedDate!.format(context),style: const TextStyle(color: Colors.blue),),
    );
  }


}