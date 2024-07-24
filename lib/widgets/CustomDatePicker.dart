import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  CustomDatePicker({required this.initialDate, required this.onDateChanged});

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime _selectedDate = DateTime.now();
  final int _rangeDays = 30; // Number of days to show in the range

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  List<DateTime> _generateDateRange() {
    final List<DateTime> dates = [];
    final DateTime today = DateTime.now();
    final DateTime startDate = today.subtract(Duration(days: _rangeDays));
    for (int i = 0; i <= _rangeDays; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> dates = _generateDateRange();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate.isSameDay(date);
          final formattedDate = DateFormat('MMM d').format(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                widget.onDateChanged(date);
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Center(
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

extension DateUtils on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
