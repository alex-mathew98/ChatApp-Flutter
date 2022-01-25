import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Users{
  String id;
  String name;
  String email;
  String about;
  String photoURL;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.about,
    required this.photoURL
  });

  Map<String, String> toJson(){
    return{
      DBconstants.name : name,
      DBconstants.email : email,
      DBconstants.about : about,
      DBconstants.photoUrl : photoURL,
    };
  }

  factory Users.fromDocument(DocumentSnapshot doc){
    String name="";
    String email="";
    String about="";
    String photoURL="";
    try{
      name = doc.get(DBconstants.name);
    }catch(e){}
    try{
      email = doc.get(DBconstants.email);
    }catch(e){}
    try{
      about = doc.get(DBconstants.about);
    }catch(e){}
    try{
      photoURL = doc.get(DBconstants.about);
    }catch(e){}

    return Users(
      id: doc.id,
      photoURL: photoURL,
      name:name,
      email: email,
      about: about,
    );
  }
}