import 'package:shared_preferences/shared_preferences.dart';

class LoginData {
late int session_id,account_id,role_id;
 late String user_email,username,user_full_name,profile_path;	


 LoginData({required session_id,required account_id,required role_id,required user_email, });

void setData() async{

final pref=await SharedPreferences.getInstance();

session_id=pref.getInt('session_id')!;
account_id=pref.getInt('account_id')!;
role_id=pref.getInt('role_id')!;
user_email=pref.getString('user_email')!;

}


Future<int> getSessionId()async{
final pref=await SharedPreferences.getInstance();

session_id=pref.getInt('session_id')!;
  return session_id;
}
Future<int> getAccountId()async{
final pref=await SharedPreferences.getInstance();

account_id=pref.getInt('account_id')!;
  return account_id;
}
Future<int> getRoleId()async{
final pref=await SharedPreferences.getInstance();

role_id=pref.getInt('role_id')!;
  return role_id;
}
Future<String> getUsername()async{
final pref=await SharedPreferences.getInstance();
username=pref.getString('username')!;
  return username;
}

Future<String> getUserFullName()  async{
final pref=await SharedPreferences.getInstance();
user_full_name=pref.getString('user_full_name')!;
  return user_full_name;
}
Future<String> getProfilePath()async{
final pref=await SharedPreferences.getInstance();
profile_path=pref.getString('profile_path')!;
  return profile_path;
}





}