import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:chat_app_mk2/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

class Register extends StatefulWidget {
  final Function toggle;
  const Register(this.toggle);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool loading = false;


  final key = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    registerAccount() {
      if (key.currentState!.validate()) {


        authProvider.registerMK2(nameController.text,emailController.text, passwordController.text).then((value){
          authProvider.prefs.setString(DBconstants.name, nameController.text);
          authProvider.prefs.setBool(DBconstants.loggedIn, true);
          if(value){
            print(value);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Home()));
          }
        });

        setState(() {
          loading = true;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Register account"),
      ),
      body: loading
          ? Container(
        child: const Center(child: CircularProgressIndicator()),
      )
          : SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
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
                          validator: (value){
                            // return ((val?.isEmpty || val?.length < 4 )? "Name field cannot be empty": null);
                            if (value!.isEmpty || value.length <2) return 'Name field cannot be empty';
                            return null;
                          },
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(32.0)),
                            labelText: 'Name',
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 15.0),
                          )
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                          autofocus: false,
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(32.0)),
                            labelText: 'Email',
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 15.0),
                          )),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                          obscureText: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is required';
                            } else if (value.length < 6) {
                              return "Please provide a valid password";
                            }
                            return null;
                          },
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(32.0)),
                            labelText: 'Password',
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 15.0),
                          )),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                GestureDetector(
                  onTap: () {
                    registerAccount();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30)),
                    child: const Text("Sign Up",
                        style:
                        TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Text("Sign Up with Google",
                      style:
                      TextStyle(color: Colors.black, fontSize: 15)),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    Text("Already have an account!"),
                    GestureDetector(
                      onTap: (){
                        widget.toggle();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          "Sign In!",
                          style:
                          TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 70.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
