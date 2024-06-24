
import 'package:flutter/material.dart';

class CatdTitle extends StatelessWidget {
   CatdTitle({super.key, required this.title});
   String title;

  @override
  Widget build(BuildContext context) {
    return  Card(
                    color: Colors.white,
                    elevation: 8,
                    child:  Container(
                    
                        color: Colors.white,
                        
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(15,10,15,10),
                          child: Text(title,style: TextStyle(fontSize: 18),))),
                    );
  }
}