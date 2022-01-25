import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Helper{
  static Future<String?> getUserNameSharedPreference() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? currentUser = await pref.getString(DBconstants.name);
    print(currentUser);
    return currentUser;
  }
}