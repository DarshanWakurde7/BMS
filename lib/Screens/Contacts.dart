// contacts_page.dart

import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/Screens/AddContact.dart';
import 'package:bms/pojos/models/ContactModels.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _contactsFuture = ApiCalls().fetchContacts('1100');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found.'));
          } else {
            final contacts = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return CompanyCard(
                  firstName: contact.firstName,
                  lastName: contact.lastName,
                  phone: contact.phone,
                  alternatePhone: contact.alternatePhone,
                  email: contact.email,
                  alternateEmail: contact.alternateEmail,
                  gstNumber: contact.gstNumber,
                  address1: contact.address1,
                  address2: contact.address2,
                  city: contact.city,
                  state: contact.state,
                  pin: contact.pin,
                  country: contact.country,
                  designation: contact.designation,
                  createdBy: contact.createdBy,
                  createdAt: contact.createdAt,
                  updatedBy: contact.updatedBy,
                  displayName: contact.displayName,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContactForm(
                onContactAdded: _loadContacts, // Pass the refresh method
              ),
            ),
          );
          // Optionally, refresh the contacts when returning
          _loadContacts();
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 139, 195, 241),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CompanyCard extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final String alternatePhone;
  final String email;
  final String alternateEmail;
  final String gstNumber;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String pin;
  final String country;
  final String designation;
  final String createdBy;
  final String createdAt;
  final String updatedBy;
  final String displayName;

  CompanyCard({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.alternatePhone,
    required this.email,
    required this.alternateEmail,
    required this.gstNumber,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.pin,
    required this.country,
    required this.designation,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.displayName,
  });

  @override
  _CompanyCardState createState() => _CompanyCardState();
}

class _CompanyCardState extends State<CompanyCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      shadowColor: Colors.black,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.firstName +
                        (widget.lastName.isNotEmpty
                            ? ' ${widget.lastName}'
                            : ''),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                      _showDetails ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 0.5),
            Divider(color: Colors.grey),
            _buildDoubleRow("Phone:", widget.phone, "Alternate Phone:",
                widget.alternatePhone),
            _buildDoubleRow("Email:", widget.email, "Alternate Email:",
                widget.alternateEmail),
            if (_showDetails) ...[
              _buildDoubleRow("Display Name:", widget.displayName,
                  "GST Number:", widget.gstNumber),
              _buildDoubleRow("Designation:", widget.designation, "Address 1:",
                  widget.address1),
              _buildDoubleRow(
                  "Address 2:", widget.address2, "City:", widget.city),
              _buildDoubleRow("State:", widget.state, "PIN:", widget.pin),
              _buildDoubleRow(
                  "Country:", widget.country, "Created By:", widget.createdBy),
              _buildDoubleRow("Created At:", widget.createdAt, "Updated By:",
                  widget.updatedBy),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleRow(
      String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  label2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  value1,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Expanded(
                child: Text(
                  value2,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
