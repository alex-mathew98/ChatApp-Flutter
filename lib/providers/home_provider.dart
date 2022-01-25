import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeProvider{
  final FirebaseFirestore firebaseFirestore;
  HomeProvider({
    required this.firebaseFirestore
  });

  //Updating a collection's document in firestore
  Future<void> updateDataFireStore(String collectionPath,String path,Map<String,String> dataNeedUpdate){
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  //For searching users
  Stream<QuerySnapshot> getStreamFireStore(String collectionPath,int limit,String? search){
    if(search?.isNotEmpty == true){
      return firebaseFirestore.collection(collectionPath)
                              .limit(limit)
                              .where(DBconstants.name,isEqualTo: search)
                              .snapshots();
                              
    }
    else{
      return firebaseFirestore.collection(collectionPath)
                              .limit(limit)
                              .snapshots();
    }
  }


}