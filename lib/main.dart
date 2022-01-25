import 'package:chat_app_mk2/constants/title_constants.dart';
import 'package:chat_app_mk2/providers/auth_provider.dart';
import 'package:chat_app_mk2/providers/chat_provider.dart';
import 'package:chat_app_mk2/providers/home_provider.dart';
import 'package:chat_app_mk2/providers/settings_provider.dart';
import 'package:chat_app_mk2/screens/loading_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs,));
}

class MyApp extends StatelessWidget {

  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage =FirebaseStorage.instance;


  MyApp({required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(firebaseAuth: FirebaseAuth.instance, googleSignIn: GoogleSignIn(), prefs: this.prefs, firebaseFirestore: this.firebaseFirestore),
        ),
        Provider<SettingsProvider>(create: (_)=>SettingsProvider(prefs: this.prefs, firebaseFirestore: this.firebaseFirestore, firebaseStorage: this.firebaseStorage)),
        Provider<HomeProvider>(create: (_)=>HomeProvider(firebaseFirestore: this.firebaseFirestore)),
        Provider<SettingsProvider>(create: (_)=>SettingsProvider(prefs: this.prefs, firebaseFirestore: this.firebaseFirestore, firebaseStorage: this.firebaseStorage)),
        Provider<ChatProvider>(create: (_)=>ChatProvider(prefs: this.prefs, firebaseStorage: this.firebaseStorage, firebaseFirestore: this.firebaseFirestore))
      ],
      child: MaterialApp(
        title: TitleConstants.appTitle,
        theme: ThemeData.dark(),
        home: LoadingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
