import 'dart:convert';
import 'package:bms/pojos/models/CompanyModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bms/Screens/AddCompany.dart';

class CompaniesPage extends StatefulWidget {
  @override
  _CompaniesPageState createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  late Future<List<Company>> _companies;
  List<Company> _allCompanies = [];
  List<Company> _filteredCompanies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCompanies);
    _companies = fetchCompanies();
  }

  Future<List<Company>> fetchCompanies() async {
    final response = await http.post(
      Uri.parse(
          'https://pw-bms-dev.portalwiz.in/laravelapi/public/api/fetch_companies'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account_id': '1100',
      }),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      _allCompanies =
          jsonResponse.map((data) => Company.fromJson(data)).toList();
      _filteredCompanies = _allCompanies;
      return _allCompanies;
    } else {
      throw Exception('Failed to load companies');
    }
  }

  void _filterCompanies() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCompanies = _allCompanies.where((company) {
        return company.companyName.toLowerCase().contains(query) ||
            company.companyType.toLowerCase().contains(query) ||
            company.headquarter.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _refreshCompanies() {
    setState(() {
      _companies = fetchCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Information'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search companies...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Company>>(
        future: _companies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || _filteredCompanies.isEmpty) {
            return Center(child: Text('No companies found'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: _filteredCompanies.length,
            itemBuilder: (context, index) {
              final company = _filteredCompanies[index];
              return CompanyCard(
                companyName: company.companyName,
                companyStatus: company.companyStatus ?? 'N/A',
                companyType: company.companyType ?? 'N/A',
                headquarter: company.headquarter ?? 'N/A',
                companyPhone: company.companyPhone ?? 'N/A',
                alternatePhone: company.alternatePhone ?? 'N/A',
                companyEmail: company.companyEmail ?? 'N/A',
                alternateEmail: company.alternateEmail ?? 'N/A',
                gstNumber: company.gstNumber ?? 'N/A',
                panNumber: company.panNo ?? 'N/A',
                tanNumber: company.tanNo ?? 'N/A',
                website: company.website ?? 'N/A',
                address1: company.address1 ?? 'N/A',
                address2: company.address2 ?? 'N/A',
                city: company.city ?? 'N/A',
                state: company.state ?? 'N/A',
                pin: company.pin ?? 'N/A',
                country: company.country ?? 'N/A',
                gpsLocation: company.gpsLocation ?? 'N/A',
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCompany(
                onContactAdded: _refreshCompanies,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 139, 195, 241),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CompanyCard extends StatefulWidget {
  final String companyName;
  final String companyStatus;
  final String companyType;
  final String headquarter;
  final String companyPhone;
  final String alternatePhone;
  final String companyEmail;
  final String alternateEmail;
  final String gstNumber;
  final String panNumber;
  final String tanNumber;
  final String website;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String pin;
  final String country;
  final String gpsLocation;

  CompanyCard({
    required this.companyName,
    required this.companyStatus,
    required this.companyType,
    required this.headquarter,
    required this.companyPhone,
    required this.alternatePhone,
    required this.companyEmail,
    required this.alternateEmail,
    required this.gstNumber,
    required this.panNumber,
    required this.tanNumber,
    required this.website,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.pin,
    required this.country,
    required this.gpsLocation,
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
                    widget.companyName,
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
            _buildDoubleRow(
                "Status:", widget.companyStatus, "Type:", widget.companyType),
            _buildDoubleRow("Headquarter:", widget.headquarter, "Phone:",
                widget.companyPhone),
            if (_showDetails) ...[
              _buildDoubleRow("Alternate Phone:", widget.alternatePhone,
                  "Email:", widget.companyEmail),
              _buildDoubleRow("Alternate Email:", widget.alternateEmail,
                  "GST Number:", widget.gstNumber),
              _buildDoubleRow("PAN Number:", widget.panNumber, "TAN Number:",
                  widget.tanNumber),
              _buildDoubleRow(
                  "Website:", widget.website, "Address 1:", widget.address1),
              _buildDoubleRow(
                  "Address 2:", widget.address2, "City:", widget.city),
              _buildDoubleRow("State:", widget.state, "PIN:", widget.pin),
              _buildDoubleRow("Country:", widget.country, "GPS Location:",
                  widget.gpsLocation),
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
