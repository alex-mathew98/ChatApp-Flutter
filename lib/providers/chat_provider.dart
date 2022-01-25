import 'dart:io';
import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:chat_app_mk2/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider{
  final SharedPreferences prefs;
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  ChatProvider({
    required this.prefs,
    required this.firebaseStorage,
    required this.firebaseFirestore
  });

  UploadTask uploadTask(File image,String file){
    Reference reference = firebaseStorage.ref().child(file);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }
  
  Future<void> updateDataFirestore(String collectionPath,String docPath,Map<String,dynamic> data){
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(data);
  }
  
  Stream<QuerySnapshot> getChats(String chatRoomID,int limit){
    return firebaseFirestore.collection(DBconstants.pathMessageCollection)
                            .doc(chatRoomID)
                            .collection(chatRoomID)
                            .orderBy(DBconstants.time,descending: true)
                            .limit(limit)
                            .snapshots();
  }

  void sendMessage(String message, int type,String chatRoomID,String currentUserID, String peerID){
    print("-------TESTING!!!--------");
    print("chatroomID"+chatRoomID);
    print("-------------------------");
    DocumentReference documentReference = firebaseFirestore
                                          .collection(DBconstants.pathMessageCollection)
                                          .doc(chatRoomID)
                                          .collection(chatRoomID)
                                          .doc(DateTime.now().millisecondsSinceEpoch.toString());

    Chat chat =Chat(receiverID: peerID, senderID: currentUserID, time: DateTime.now().millisecondsSinceEpoch.toString(), message: message, type: type);

    FirebaseFirestore.instance.runTransaction((transaction) async{
      transaction.set(documentReference, chat.toJson());
    });
  }
}

class messageType{
  static const text = 0;
  static const image =1;
  static const gif =2;
}