import 'package:chat_app_mk2/screens/login_page.dart';
import 'package:chat_app_mk2/screens/register_page.dart';
import 'package:flutter/material.dart';

class AuthHelper extends StatefulWidget {
  const AuthHelper({Key? key}) : super(key: key);

  @override
  _AuthHelperState createState() => _AuthHelperState();
}

class _AuthHelperState extends State<AuthHelper> {

  bool showSignIn = true;

  void toggleMode(){
    setState(() {
      showSignIn= !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn? Login(toggleMode) :  Register(toggleMode) ;
  }
}
