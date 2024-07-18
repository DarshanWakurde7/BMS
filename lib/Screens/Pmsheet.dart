import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProjectManagerSheet extends StatefulWidget {
  @override
  _ProjectManagerSheetState createState() => _ProjectManagerSheetState();
}

class _ProjectManagerSheetState extends State<ProjectManagerSheet>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  String? _selectedEmployee;
  TextEditingController _entryController = TextEditingController();
  List<Map<String, dynamic>> _entries = [];
  String _entryType = 'Plan';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Manager Sheet'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Add Entries'),
            Tab(text: 'View Entries'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Daily Plans and Achievements',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),

                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.blue),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (pickedDate != null &&
                                            pickedDate != _selectedDate)
                                          setState(() {
                                            _selectedDate = pickedDate;
                                          });
                                      },
                                      child: Text(
                                        "${_selectedDate.toLocal()}"
                                            .split(' ')[0],
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Select Employee',
                                  labelStyle: TextStyle(fontSize: 14),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 8.0),
                                  isDense: true,
                                ),
                                value: _selectedEmployee,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedEmployee = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Employee 1',
                                  'Employee 2',
                                  'Employee 3'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        // Entry Type Selector
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: CupertinoSegmentedControl<String>(
                              children: {
                                'Plan': Text('Plan'),
                                'Achievement': Text('Achievement'),
                              },
                              groupValue: _entryType,
                              onValueChanged: (String value) {
                                setState(() {
                                  _entryType = value;
                                });
                              },
                              borderColor: Colors.blue,
                              selectedColor: Colors.blue,
                              unselectedColor: Colors.white,
                              pressedColor: Colors.blueAccent,
                              padding: EdgeInsets.all(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        // Entry Field
                        TextFormField(
                          controller: _entryController,
                          minLines: _entryType == 'Achievement' ? 5 : 1,
                          maxLines: _entryType == 'Achievement' ? 10 : 1,
                          decoration: InputDecoration(
                            labelText: 'Enter ${_entryType}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedEmployee != null &&
                                _entryController.text.isNotEmpty) {
                              setState(() {
                                _entries.add({
                                  'type': _entryType,
                                  'employee': _selectedEmployee!,
                                  'entry': _entryController.text,
                                  'date': _selectedDate
                                });
                                _entryController.clear();
                              });
                            }
                          },
                          child: Text('Add ${_entryType}'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'View Entries',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Expanded(
                        child: ListView(
                          children: _groupedEntries().entries.map((entry) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text('${entry.key}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: entry.value.map((e) {
                                    return Text('${e['type']}: ${e['entry']}');
                                  }).toList(),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupedEntries() {
    Map<String, List<Map<String, dynamic>>> groupedEntries = {};

    for (var entry in _entries) {
      String key =
          '${entry['employee']} - ${entry['date'].toString().split(' ')[0]}';
      if (groupedEntries.containsKey(key)) {
        groupedEntries[key]!.add(entry);
      } else {
        groupedEntries[key] = [entry];
      }
    }

    return groupedEntries;
  }
}

void main() {
  runApp(MaterialApp(
    home: ProjectManagerSheet(),
  ));
}
