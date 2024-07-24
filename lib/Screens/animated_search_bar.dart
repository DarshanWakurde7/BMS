import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class AnimatedDropdown extends StatefulWidget {
  final double initialSize;
  final double expandedWidth;
  final double expandedHeight;
   bool isExpanded;
  final List<dynamic> dropdownItems;
    String selectedItem;
  final ValueChanged<dynamic?> onChanged; // Callback for when a new item is selected
final  ValueChanged<bool?>  setData;
  AnimatedDropdown({
    this.initialSize = 50.0,
    this.expandedWidth = 200.0,
    this.expandedHeight = 100.0,
    required this.selectedItem,
    required this.dropdownItems,
    required this.isExpanded,
    required this.onChanged, // Required parameter for callback
    required this.setData, // Required parameter for callback
  });

  @override
  _AnimatedDropdownState createState() => _AnimatedDropdownState();
}

class _AnimatedDropdownState extends State<AnimatedDropdown> with SingleTickerProviderStateMixin {
 
  late AnimationController _controller;
  late Animation<double> _animation;

 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.initialSize,
      end: widget.expandedWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial selected item if dropdownItems is not empty
    widget.selectedItem = widget.dropdownItems.isNotEmpty ? widget.dropdownItems.first : null;
  }

  void _toggleExpansion() {
     
    setState(() {
   
      widget.isExpanded = !widget.isExpanded;
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: _animation.value,
            height: widget.expandedHeight,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22.0),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    radius: widget.initialSize / 2,
                    child: Icon(Icons.expand_more),
                  ),
                ),
                if (widget.isExpanded)
                  Positioned(
                    left: widget.initialSize,
                    child: Container(
                      width: _animation.value - widget.initialSize,
                      height: widget.expandedHeight,
                      color: Colors.white,
                      child:    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Team',
                        labelStyle: TextStyle(fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                        isDense: true,
                      ),
                    
                      onChanged: (int? newValue) {
                            widget.onChanged(newValue);
                      },
                      items: widget.dropdownItems.map<DropdownMenuItem<int>>((team) {
                        return DropdownMenuItem<int>(
                          value: team['team_id'],
                          child: Text(
                            team['team_name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MultiSelectDropdown extends StatefulWidget {
  final double initialSize;
  final double expandedWidth;
  final double expandedHeight;
   bool isExpanded;
  List<ValueItem> selectedItem;
  final List<dynamic> dropdownItems; // Updated to match MultiSelectDropDown
  final ValueChanged<List<ValueItem>> onChanged; // Callback for when items are selected
  final ValueChanged<bool> changedata; // Callback for when items are selected

  MultiSelectDropdown({
    this.initialSize = 50.0,
    this.expandedWidth = 200.0,
    this.expandedHeight = 100.0,
   required this.isExpanded,
   required this.selectedItem,
    required this.dropdownItems,
    required this.onChanged,
    required this.changedata,
  });

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.initialSize,
      end: widget.expandedWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggleExpansion() {
    setState(() {
      widget.isExpanded = !widget.isExpanded??false;
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: _animation.value,
            height: widget.expandedHeight,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22.0),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    radius: widget.initialSize / 2,
                    child: Icon(Icons.expand_more),
                  ),
                ),
                if (widget.isExpanded)
                  Positioned(
                    left: widget.initialSize,
                    child: Container(
                      width: _animation.value - widget.initialSize,
                      height: widget.expandedHeight,
                      color: Colors.white,
                      child: MultiSelectDropDown(
                        options: widget.dropdownItems.map((e){
                          return ValueItem(label: e["last_name"]+" "+e["first_name"], value: e["user_id"]);
                        }).toList(),
                  
                         onOptionSelected: (value) {
                        setState(() {
                          widget.selectedItem = value;
                        });
                        widget.onChanged(value);
                      },
                    
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

