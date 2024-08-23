import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  final String message;

  CustomSnackBar({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: EdgeInsets.only(top: 40.0), // Adjust the top margin as needed
        child: Card(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
