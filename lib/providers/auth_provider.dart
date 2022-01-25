import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:chat_app_mk2/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status{
  uninitalized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCancelled
}

class AuthProvider extends ChangeNotifier{

  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  late final FirebaseFirestore firebaseFirestore;
  late final SharedPreferences prefs;

  Status _status =Status.uninitalized;
  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firebaseFirestore
  });

  Users? _fireBaseUser(User user){
    return user !=null ? Users(id: user.uid,name: user.displayName!,email: user.email!,photoURL:user.photoURL!,about: "") : null;
  }

  String? getUserFirebaseID() {
    return prefs.getString(DBconstants.id);
  }

  Future<String?> getUserName() async{
    return prefs.getString(DBconstants.name);
  }

  Future login(String email,String password) async{
    try{
      UserCredential result =await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;
      return _fireBaseUser(firebaseUser!);
    }
    catch(e){
      print(e.toString());
    }
  }

  Future loginMK2(String email,String password) async{
    try{
      UserCredential result =await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;
      //return _fireBaseUser(firebaseUser!);
      if(firebaseUser!=null){
        final QuerySnapshot result = await firebaseFirestore
            .collection(DBconstants.pathUserCollection)
            .where(DBconstants.id,isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;

        DocumentSnapshot documentSnapshot = document[0];
        Users user = Users.fromDocument(documentSnapshot);

        print("Login"+user.id);
        prefs.setString(DBconstants.id, user.id);
        await prefs.setString(DBconstants.name, user.name);
        await prefs.setString(DBconstants.email, user.email);
        await prefs.setString(DBconstants.photoUrl, user.photoURL);
        await prefs.setString(DBconstants.about, user.about );

        await prefs.setBool(DBconstants.loggedIn, true);
        _status = Status.authenticated;
        notifyListeners();
        return true;
      }
      else{
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
      // return _fireBaseUser(firebaseUser!);
    }
    catch(e){
      print(e.toString());
    }
  }

  Future register(String email,String password) async{
    try{
      UserCredential result =await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;
      return _fireBaseUser(firebaseUser!);
    }
    catch(e){
      print(e.toString());
    }
  }

  Future registerMK2(String name,String email,String password) async{
    try{
      UserCredential result =await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;
      print("clears-1");
      //return _fireBaseUser(firebaseUser!);
      if(firebaseUser!=null){
        final QuerySnapshot result = await firebaseFirestore
            .collection(DBconstants.pathUserCollection)
            .where(DBconstants.id,isEqualTo: firebaseUser.uid)
            .get();
        print("clears-2");
        final List<DocumentSnapshot> document = result.docs;
        if(document.length == 0){
          firebaseFirestore.collection(DBconstants.pathUserCollection).doc(firebaseUser.uid).set({
            DBconstants.name:name,
            DBconstants.email:firebaseUser.email,
            DBconstants.id: firebaseUser.uid,
            "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
            DBconstants.chattingWith: null
          });

          User? currentUser = firebaseUser;
          print("Register"+currentUser.uid);
          await prefs.setString(DBconstants.id, currentUser.uid);
          await prefs.setString(DBconstants.email, currentUser.email ?? "");
          await prefs.setString(DBconstants.photoUrl, currentUser.photoURL ?? "");

          //TODO:
          //await prefs.setBool(DBconstants.loggedIn, true);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      }
      else{
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    }
    catch(e){
      print("Straight to error");
      print(e.toString());
    }
  }

  Future<bool> isLoggedIn_Email() async{
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if(isLoggedIn && prefs.getString(DBconstants.id)?.isNotEmpty == true){
      print("Yabba Dabba Doo"+prefs.getString(DBconstants.id).toString());
      return true;
    }
    else{
      return false;
    }
  }

  Future<bool> isLoggedIn_Google() async{
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if(isLoggedIn && prefs.getString(DBconstants.id)?.isNotEmpty == true){
      print(prefs.getString(DBconstants.id));
      return true;
    }
    else{
      return false;
    }
  }

  Future<bool> handleGoogleSignIn() async{

    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if(googleUser != null){
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );
      UserCredential result =await firebaseAuth.signInWithCredential(credential);
      User? firebaseUser = result.user;

      if(firebaseUser!=null){
        final QuerySnapshot result = await firebaseFirestore
            .collection(DBconstants.pathUserCollection)
            .where(DBconstants.id,isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        if(document.length == 0){
          firebaseFirestore.collection(DBconstants.pathUserCollection).doc(firebaseUser.uid).set({
            DBconstants.name:firebaseUser.displayName,
            DBconstants.email:firebaseUser.email,
            DBconstants.id: firebaseUser.uid,
            "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
            DBconstants.chattingWith: null
          });

          User? currentUser = firebaseUser;
          print("GSignIn-"+currentUser.uid);
          await prefs.setString(DBconstants.id, currentUser.uid);
          await prefs.setString(DBconstants.name, currentUser.displayName ?? "");
          await prefs.setString(DBconstants.email, currentUser.email ?? "");
          await prefs.setString(DBconstants.photoUrl, currentUser.photoURL ?? "");

          //TODO:
          await prefs.setBool(DBconstants.loggedIn, true);
        }
        else{
          DocumentSnapshot documentSnapshot = document[0];
          Users user = Users.fromDocument(documentSnapshot);

          await prefs.setString(DBconstants.id, user.id);
          await prefs.setString(DBconstants.name, user.name);
          await prefs.setString(DBconstants.email, user.email);
          await prefs.setString(DBconstants.photoUrl, user.photoURL);
          await prefs.setString(DBconstants.about, user.about);

          await prefs.setBool(DBconstants.loggedIn, true);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      }
      else{
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }

    }
    else{
      _status = Status.authenticateCancelled;
      notifyListeners();
      return false;
    }
  }

  Future signout() async{
    try{
      _status = Status.uninitalized;
      if(googleSignIn.isSignedIn() == true){
        googleSignIn.disconnect();
        googleSignIn.signOut();
      }
      //TODO:
      await prefs.setBool(DBconstants.loggedIn, false);
      await firebaseAuth.signOut();
    }
    catch(error){
      print(error);
    }
  }

}