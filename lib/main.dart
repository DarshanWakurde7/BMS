import 'dart:convert';
import 'package:bms/Screens/NotActive.dart';
import 'package:bms/Screens/SplashScreen.dart';
import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:bms/methods/internetconnectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bms/pojos/models/loginpojo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List<Data> loginResponse = [];
Future<void> main() async {
  runApp(const MyApp());

  DependacyInjection.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: {
        '/NotStarted': (context) => NotActive(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var username = TextEditingController();
  var password = TextEditingController();

  bool obcurseText = true;
// static String baseurl="https://pw-bms-dev.portalwiz.in/laravelapi/public/api/";
  static String baseurl = "https://portalwiz.net/laravelapi/public/api/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics:
            const ClampingScrollPhysics(parent: NeverScrollableScrollPhysics()),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.075,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 100.5,
                  child: Image.asset("asset/image/portalwiz.png"),
                ),
              ]),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextField(
                  cursorHeight: 30,
                  controller: username,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, size: 24),
                      label: const Text('Username'),
                      labelStyle: const TextStyle(color: Colors.black),
                      isDense: true,
                      contentPadding: EdgeInsets.all(5.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      )),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TextField(
                  cursorHeight: 30,
                  controller: password,
                  obscureText: obcurseText,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        size: 24,
                      ),
                      suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obcurseText = !obcurseText;
                            });
                          },
                          child: const Icon(Icons.visibility_off_outlined,
                              size: 24)),
                      label: const Text('Password'),
                      labelStyle: const TextStyle(color: Colors.black),
                      isDense: true,
                      contentPadding: EdgeInsets.all(5.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      )),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.075,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.13,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 2, 177, 246),
                          Color.fromARGB(255, 0, 143, 191),
                          Color.fromARGB(255, 0, 109, 242),
                          Color.fromARGB(255, 0, 34, 168)
                        ],
                        begin: Alignment.topRight,
                        stops: [0.2, 0.4, 0.6, 0.8],
                        end: Alignment.bottomLeft)),
                child: ElevatedButton(
                  onPressed: () {
                    RegExp regex = RegExp(r'^[a-z0-9]+(?:[_-][a-z0-9]+)*$',
                        caseSensitive: false);
                    if ((username.text.isNotEmpty) &&
                        (password.text.isNotEmpty)) {
                      checkLogin(username.text.toString(),
                          password.text.toString(), context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Sorry please enter all valid fields!!"),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> checkLogin(
      String username, String password, BuildContext context) async {
    final sharedPref = await SharedPreferences.getInstance();
    Uri uri = Uri.parse('${baseurl}login?');

    var body = {"username": username, "password": password};

    final response = await http.post(uri, body: body);

    print(response.statusCode);
    var data = jsonDecode(response.body.toString());

    if (data['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login SuccessFul"),
        backgroundColor: Colors.blueAccent,
      ));

      for (Map<String, dynamic> i in data['data']) {
        loginResponse.add(Data.fromJson(i));
      }

      print(response.body);
      sharedPref.setInt("session_id", loginResponse[0].activeStatusId!);
      sharedPref.setInt("user_id", loginResponse[0].userId!);
      sharedPref.setInt("punch_Status", 0);
      sharedPref.setInt("account_id", loginResponse[0].accountId!);
      sharedPref.setInt("role_id", loginResponse[0].roleId!);
      sharedPref.setString(
          "user_email", loginResponse[0].profilePath.toString());
      sharedPref.setString("username", loginResponse[0].profilePath.toString());
      sharedPref.setString(
          "user_full_name", loginResponse[0].profilePath.toString());
      sharedPref.setString(
          "account_display_name", loginResponse[0].profilePath.toString());
      sharedPref.setString(
          "profile_path", loginResponse[0].profilePath.toString());
      sharedPref.setString(
          "product_display_name", loginResponse[0].profilePath.toString());
      sharedPref.setBool("privacy Terms", false);
      ApiCalls.getStatus(loginResponse[0].accountId!.toString());

// ApiCalls.getDataofCards(1.toString());

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SplashScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message']),
        backgroundColor: Colors.redAccent,
      ));
    }
  }
}
