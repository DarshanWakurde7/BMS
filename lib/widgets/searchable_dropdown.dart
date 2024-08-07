import 'package:flutter/material.dart';

Future<String?> showEmployeeSearchDialog(
    BuildContext context, List<String> employees) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SearchDialog(employees: employees);
    },
  );
}

class SearchDialog extends StatefulWidget {
  final List<String> employees;

  SearchDialog({required this.employees});

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _filteredEmployees = widget.employees;
    _searchController.addListener(() {
      _filterEmployees();
    });
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = widget.employees
          .where((employee) => employee.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 400, // Adjust the maximum height as needed
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = _filteredEmployees[index];
                  return ListTile(
                    title: Text(employee),
                    onTap: () {
                      Navigator.of(context).pop(employee);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSearchDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  const CustomSearchDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.selectedItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['project_name']),
                onTap: () {
                  onChanged(item['project_name']);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
