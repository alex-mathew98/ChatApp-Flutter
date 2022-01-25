import 'package:chat_app_mk2/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

class Login extends StatefulWidget {
  final Function toggle;
  const Login(this.toggle);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final key = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {

    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch(authProvider.status){
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign In Failed");
        break;
      case Status.authenticateCancelled:
        Fluttertoast.showToast(msg: "Sign In cancelled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign In success");
        break;
      default:
        break;
    }

    login(){
      if (key.currentState!.validate()) {
        // authFunc.login(emailController.text, passwordController.text).then((
        //     value) {
        //   if (value != null) {
        //     Helper.saveLoggedInSharedPreference(true);
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => const Home()));
        //   }
        //   else{
        //     //Send toast message
        //   }
        // });

        authProvider.loginMK2(emailController.text, passwordController.text)
                    .then((value) {
                        if(value){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Home()));
                        }
                        else{
                          Fluttertoast.showToast(msg: "Sign In Failed");
                        }
                    });
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height-50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Form(
                  key: key,
                  child: Column(
                    children: [
                      TextFormField(
                          autofocus: false,
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            labelText: 'Email',
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          )),
                      const SizedBox(height:20.0,),
                      TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            labelText: 'Password',
                            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0,),
                Container(
                  alignment: Alignment.centerRight,
                  child: const Text("Forgot Password"),
                ),
                const SizedBox(height: 15.0,),
                GestureDetector(
                  onTap: () {
                    login();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30)),
                    child: const Text("Sign In",
                        style:
                        TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 15.0,),
                GestureDetector(
                  onTap: () async{
                    bool isSuccess = await authProvider.handleGoogleSignIn();
                    if(isSuccess){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: const Text("Sign In with Google",style: TextStyle(
                        color: Colors.black,
                        fontSize: 15
                    )),
                  ),
                ),
                const SizedBox(height: 10.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    const Text("Sign up for an account,"),
                    GestureDetector(
                      onTap: (){
                        widget.toggle();
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text("here!",style: TextStyle(decoration:TextDecoration.underline ),)),
                    )
                  ],
                ),
                const SizedBox(height: 5.0,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
