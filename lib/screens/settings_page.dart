import 'dart:io';

import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:chat_app_mk2/constants/title_constants.dart';
import 'package:chat_app_mk2/models/user.dart';
import 'package:chat_app_mk2/providers/settings_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/src/provider.dart';


class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TitleConstants.settingsTitle),
      ),
      // body: Container(),
      body: SettingsPage(),

    );
  }
}



class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>{

  TextEditingController? nameController;
  TextEditingController? aboutController;

  String id ="";
  String name ="";
  String email ="";
  String about ="";
  String photoURL ="";

  bool loading = false;
  File? imageFile;
  late SettingsProvider settingsProvider;

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode aboutFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    settingsProvider = context.read<SettingsProvider>();
    readLocal();
  }

  void readLocal(){
    setState(() {
      id = settingsProvider.getPref(DBconstants.id) ?? "";
      name = settingsProvider.getPref(DBconstants.name) ?? "";
      email = settingsProvider.getPref(DBconstants.email) ?? "";
      about = settingsProvider.getPref(DBconstants.about) ??"";
      photoURL = settingsProvider.getPref(DBconstants.photoUrl) ?? "";
    });
    nameController = TextEditingController(text: name);
    aboutController = TextEditingController(text: about);
  }

  Future getImage() async{
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker.getImage(source: ImageSource.gallery).catchError((error){
      Fluttertoast.showToast(msg: error.toString());
    });

    File? image;
    if(pickedFile !=null){
      setState(() {
        imageFile = image;
        loading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async{
    String fileName = id;
    UploadTask uploadTask = settingsProvider.uploadTask(imageFile!, fileName);
    try{
      TaskSnapshot snapshot = await uploadTask;
      photoURL = await snapshot.ref.getDownloadURL();

      Users updateInfo = Users(
          id: id,
          name: name,
          email: email,
          about: about,
          photoURL: photoURL
      );
      settingsProvider.updateDataFireStore(DBconstants.pathUserCollection, id, updateInfo.toJson())
                      .then((data) async => {
                          await settingsProvider.setPref(DBconstants.photoUrl, photoURL),
                          setState((){
                            loading = false;
                          })
                      }).catchError((error){
                          setState((){
                            loading = false;
                          });
                          Fluttertoast.showToast(msg: error.toString());
                      });
    } on FirebaseException catch (e){
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void handleUpdateData(){
    nameFocusNode.unfocus();
    aboutFocusNode.unfocus();

    setState(() {
      loading =true;
    });

    Users updateInfo = Users(
        id: id,
        name: name,
        email: email,
        about: about,
        photoURL: photoURL
    );
    settingsProvider.updateDataFireStore(DBconstants.pathUserCollection, id, updateInfo.toJson())
                    .then((data) async{

            await settingsProvider.setPref(DBconstants.name, name);
            await settingsProvider.setPref(DBconstants.email, email);
            await settingsProvider.setPref(DBconstants.about, about);
            await settingsProvider.setPref(DBconstants.photoUrl, photoURL);

            setState(() {
              loading = false;
            });
            Fluttertoast.showToast(msg: "Successfully Updated");
     }).catchError((error){
        setState(() {
          loading = false;
        });

        Fluttertoast.showToast(msg: error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          padding: EdgeInsets.only(left:15,right:15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                  onPressed: getImage,
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: imageFile == null
                        ? photoURL.isNotEmpty
                          ?ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: Image.network(
                              photoURL,
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                              errorBuilder:(context,object, stackTrace){
                                return const Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: Colors.grey,
                                );
                              },
                              loadingBuilder: (BuildContext context,Widget child, ImageChunkEvent? loadingProgress){
                                  if(loadingProgress == null) return child;
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                        value: loadingProgress.expectedTotalBytes != null &&
                                              loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                                              : null,
                                      ),
                                    ),
                                  );
                              }
                            ),
                          ) :   const Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: Colors.grey,
                              )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(45),
                          child: Image.file(
                              imageFile!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                          ),
                        ),
                  )
                  ,
                  
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: const Text(
                        "Name",
                        style: TextStyle(
                          fontStyle:FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                    ),
                    margin: EdgeInsets.only(left: 10,bottom: 5,top: 10),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30,right: 30),
                    child: Theme(
                        data:Theme.of(context).copyWith(primaryColor: Colors.white),
                        child:  TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: "Write your name",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: Colors.grey)
                          ),
                          controller: nameController,
                          onChanged: (value){
                            name = value;
                          },
                          focusNode: nameFocusNode,
                        ),
                    ),
                  ),
                  Container(
                    child: const Text(
                      "About me",
                      style: TextStyle(
                          fontStyle:FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                    margin: EdgeInsets.only(left: 10,bottom: 5,top: 10),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30,right: 30),
                    child: Theme(
                      data:Theme.of(context).copyWith(primaryColor: Colors.white),
                      child:  TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: "Update Bio ",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: Colors.grey)
                        ),
                        controller: aboutController,
                        onChanged: (value){
                          about = value;
                        },
                        focusNode: aboutFocusNode,
                      ),
                    ),
                  ),
                  Container(
                    margin:EdgeInsets.only(top: 50,bottom: 50),
                    child: TextButton(
                      onPressed: handleUpdateData,
                      child: Text(
                        "Update now",
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.fromLTRB(30, 10, 30, 10),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

}
