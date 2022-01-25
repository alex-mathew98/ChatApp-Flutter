import 'package:chat_app_mk2/helpers/auth_helper.dart';
import 'package:chat_app_mk2/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import 'home_page.dart';
import 'login_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5),(){
      checkSignedIn();
    });
  }

  void checkSignedIn() async{
    AuthProvider authProvider= context.read<AuthProvider>();
    bool isLoggedIn_Google = await authProvider.isLoggedIn_Google();
    //bool isLoggedIn_Email = await authProvider.isLoggedIn_Email();
    if(isLoggedIn_Google){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthHelper()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:  [
            Text("Welcome to the chat app",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.red),),
            const SizedBox(height: 20),
            Container(
              width:20,
              height:20,
              child:const CircularProgressIndicator(
                color: Colors.blue
              )
            )
          ],
        ),
      ),
    );
  }
}
