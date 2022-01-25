import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class Chat{
  String receiverID;
  String senderID;
  String time;
  String message;
  int type;

  Chat({
    required this.receiverID,
    required this.senderID,
    required this.time,
    required this.message,
    required this.type
  });

  Map<String,dynamic> toJson(){
    return{
      DBconstants.receiverID: this.receiverID,
      DBconstants.senderID: this.senderID,
      DBconstants.time:this.time,
      DBconstants.message:this.message,
      DBconstants.type:this.type
    };
  }

  factory Chat.fromDocument(DocumentSnapshot doc){
    String receiverID = doc.get(DBconstants.receiverID);
    String senderID = doc.get(DBconstants.senderID);
    String time = doc.get(DBconstants.time);
    String message = doc.get(DBconstants.message);
    int type = doc.get(DBconstants.type);

    return Chat(receiverID: receiverID, senderID: senderID,time: time,message: message,type: type);
  }
}