import 'dart:io';

import 'package:chat_app_mk2/constants/color_constants.dart';
import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:chat_app_mk2/helpers/auth_helper.dart';
import 'package:chat_app_mk2/models/chat.dart';
import 'package:chat_app_mk2/providers/auth_provider.dart';
import 'package:chat_app_mk2/providers/chat_provider.dart';
import 'package:chat_app_mk2/screens/view_image.dart';
import 'package:chat_app_mk2/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

class ChatScreen extends StatefulWidget {

  final String peerID;
  final String peerName;
  final String peerAvatar;

  const ChatScreen({Key? key, required this.peerID,required this.peerName,required this.peerAvatar}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(
    peerID: this.peerID,
    peerName: this.peerName,
    peerAvatar: this.peerAvatar
  );
}

class _ChatScreenState extends State<ChatScreen> {

  _ChatScreenState({required this.peerID,required this.peerName,required this.peerAvatar});

  String peerID;
  String peerName;
  String peerAvatar;
  late String currentUserName;
  late String currentUserID;

  List<QueryDocumentSnapshot> messageList = new List.from([]);

  int _limit = 20;
  int _limit_increment = 20;

  String chatRoomID="";

  File? image;
  bool loading = false;
  bool isShowSticker = false;
  String imageURL ="";

  TextEditingController messageEditingController = new TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();

    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener(){
    if(listScrollController.offset >= listScrollController.position.maxScrollExtent
      && !listScrollController.position.outOfRange){
      setState(() {
        _limit+= _limit_increment;
      });
    }
  }

  void onFocusChange(){
    if(focusNode.hasFocus){
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal(){
    if(authProvider.getUserFirebaseID().toString().isNotEmpty){
      currentUserID = authProvider.getUserFirebaseID().toString();
    }
    else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthHelper()),
              (Route<dynamic> route) => false,);
    }
    
    if(currentUserID.hashCode <= peerID.hashCode){
      //chatRoomID = '$currentUserID-$peerID';
      chatRoomID = '$currentUserID-$peerID';
    }
    else{
      chatRoomID = '$peerID-$currentUserID';
    }
    
    chatProvider.updateDataFirestore(DBconstants.pathUserCollection, currentUserID, {DBconstants.chattingWith:peerID});

  }

  Future getImage() async{
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if(pickedFile != null){
      image =File(pickedFile.path);
      if(image!=null){
        setState(() {
          loading = true;
        });
        uploadFile();
      }
    }
  }

  void getGIF(){
    focusNode.unfocus();
    setState(() {
      isShowSticker =!isShowSticker;
    });
  }

  Future uploadFile() async{
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask =chatProvider.uploadTask(image!,fileName);
    try{
      TaskSnapshot snapshot = await uploadTask;
      imageURL =await snapshot.ref.getDownloadURL();
      setState(() {
        loading = false;
        onSendMessage(imageURL,messageType.image);
      });
    } on FirebaseException catch(e){
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String message, int type){
    if(message.trim().isNotEmpty){
      messageEditingController.clear();
      chatProvider.sendMessage(message, type, chatRoomID, currentUserID, peerID);
      listScrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    else{
      Fluttertoast.showToast(msg: 'No message to send',backgroundColor: Colors.grey);
    }
  }

  bool isMessagebyUser(int index){
    if((index > 0 && messageList[index -1].get(DBconstants.senderID) == currentUserID) || index ==0 ){
      return true;
    }else{
      return false;
    }
  }

  bool isMessagebyPeer(int index){
    if((index > 0 && messageList[index -1].get(DBconstants.senderID) != currentUserID) || index ==0 ){
      return true;
    }else{
      return false;
    }
  }

  Widget buildLoading(){
    return Positioned(
        child: loading ? LoadingView() : SizedBox.shrink()
    );
  }

  Widget buildGIF(){
    return Expanded(
        child: Container(
          padding: EdgeInsets.all(5),
          height: 180,
          decoration: BoxDecoration(
            border: Border(top:BorderSide(color: Colors.grey,width: 0.5)),color: Colors.white
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                      onPressed: () => onSendMessage('mimi1', messageType.gif),
                      child: Image.asset(
                        'images/gifs/mimi1.gif',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )),
                  TextButton(
                      onPressed: () => onSendMessage('mimi2', messageType.gif),
                      child: Image.asset(
                        'images/gifs/mimi2.gif',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )),
                  TextButton(
                      onPressed: () => onSendMessage('mimi3', messageType.gif),
                      child: Image.asset(
                        'images/gifs/mimi3.gif',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                      onPressed: () => onSendMessage('mimi4', messageType.gif),
                      child: Image.asset(
                        'images/gifs/mimi4.gif',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )),
                  TextButton(
                      onPressed: () => onSendMessage('mimi5', messageType.gif),
                      child: Image.asset(
                        'images/gifs/mimi5.gif',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )),
                  TextButton(
                      onPressed: () => onSendMessage('mimi6', messageType.gif),
                      child: Image.asset(
                        'images/gifs/mimi6.gif',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ))
                ],
              )
            ],
          ),
        )
    );
  }

  Future<bool> pressBack(){
    if(isShowSticker){
      setState(() {
        isShowSticker= false;
      });
    }else{
      chatProvider.updateDataFirestore(
          DBconstants.pathUserCollection,
          currentUserID,
          {DBconstants.chattingWith:null}
      );
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  Widget buildInput(){
    return Container(
      // alignment: Alignment.bottomCenter,
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey,width: 0.5)),color: Colors.grey
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              getImage();
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.0)),
              child: Row(
                children: const [
                  SizedBox(width: 6,),
                  Icon(Icons.camera_enhance,size:25,),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              getGIF();
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.0)),
              child: Row(
                children: const [
                  SizedBox(width: 6,),
                  Icon(Icons.face_retouching_natural,size:25,),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20,),
          Expanded(
            child: TextField(
              onSubmitted: (value){
                onSendMessage(messageEditingController.text, messageType.text);
              },
              style: TextStyle(color: Colors.white,fontSize: 15),
              controller: messageEditingController,
              decoration: const InputDecoration.collapsed(
                  hintText:"Type your message",
                  hintStyle: TextStyle(color: Colors.grey),
              ),
              focusNode: focusNode,
            ),
          ),
          GestureDetector(
            onTap: () => onSendMessage(messageEditingController.text, messageType.text),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.0)),
              child: Row(
                children: const [
                  SizedBox(width: 6,),
                  Icon(Icons.send,size:25,),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(int index,DocumentSnapshot? document){
    if(document != null){
      Chat chat =Chat.fromDocument(document);
      if(chat.senderID == currentUserID){
        return Row(
          children: <Widget>[
            chat.type == messageType.text
            ?Container(
              child:Text(
                chat.message,
                style: TextStyle(
                  color: Colors.black
                ),
              ),
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              width: 200,
              decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.only(topLeft: Radius.circular(23),topRight: Radius.circular(23),bottomLeft: Radius.circular(23))),
              margin: EdgeInsets.only(bottom: 20, right: 10),
            ): chat.type == messageType.image
              ?Container(
                child: OutlinedButton(
                  onPressed:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(photoURL: chat.message)));
                  } ,
                  style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                  child: Material(
                    child: Image.network(
                      chat.message,
                      loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent? loadingProgress){
                        if(loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(0),
                            )
                          ),
                          width: 200,
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                              value: loadingProgress.expectedTotalBytes !=null &&
                                     loadingProgress.expectedTotalBytes !=null
                                     ? loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                                     :null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context,object,stackTrace){
                        return Material(
                          child: Image.asset(
                            'images/img_not_available.jpeg',
                            width: 200,
                            height: 200,
                            fit:BoxFit.cover
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                        );
                      },
                        width: 200,
                        height: 200,
                        fit:BoxFit.cover
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    clipBehavior: Clip.hardEdge,
                  ),
                ),
              margin: EdgeInsets.only(bottom: isMessagebyUser(index)? 20:10,right: 10),
              ):Container(
              child: Image.asset(
                'images/gifs/${chat.message}.gif',
                 width:100,
                 height: 100,
                 fit: BoxFit.cover,
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      }
      else{
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isMessagebyPeer(index) ?
                  Material(
                    child: Image.network(
                      peerAvatar,
                        loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent? loadingProgress){
                          if(loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                              value: loadingProgress.expectedTotalBytes !=null &&
                                  loadingProgress.expectedTotalBytes !=null
                                  ? loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                                  :null,
                            ),
                          );
                        },
                      errorBuilder: (context,object,stackTrace){
                        return const Icon(
                          Icons.account_circle,
                          size: 35,
                          color: Colors.grey,
                        );
                      },
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    clipBehavior: Clip.hardEdge,
                  ) : Container(width: 35,),
                  chat.type == messageType.text
                  ?Container(
                    child:Text(
                      chat.message,
                      style: const TextStyle(
                          color: Colors.black
                      ),
                    ),
                    // padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.only(topLeft: Radius.circular(23),topRight: Radius.circular(23),bottomRight: Radius.circular(23))),
                  ): chat.type == messageType.image
                  ? Container(
                    child: TextButton(
                      onPressed:(){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(photoURL: chat.message)));

                      } ,
                      style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                      child: Material(
                        child: Image.network(
                            chat.message,
                            loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent? loadingProgress){
                              if(loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(0),
                                    )
                                ),
                                width: 200,
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    value: loadingProgress.expectedTotalBytes !=null &&
                                        loadingProgress.expectedTotalBytes !=null
                                        ? loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                                        :null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context,object,stackTrace) =>Material(
                                child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200,
                                    height: 200,
                                    fit:BoxFit.cover
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            width: 200,
                            height: 200,
                            fit:BoxFit.cover
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                    // margin: EdgeInsets.only(bottom: isMessagebyUser(index)? 20:10,right: 10),
                  ): Container(
                      child: Image.asset(
                        'images/gifs/${chat.message}.gif',
                        width:100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(bottom: isMessagebyUser(index) ? 20:10, right: 10  ),
                  )
                ],
              ),
              // isMessagebyPeer(index)
              // ? Container(
              //   child: Text(
              //     DateFormat('dd MMM yyyy, hh:mm a')
              //     .format(DateTime.fromMicrosecondsSinceEpoch(int.parse(chat.time))) ,
              //    style: const TextStyle(color: ColorConstants.greyColor,fontSize: 12,fontStyle: FontStyle.italic),
              //   ),
              // )
              // : SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      }
    }else{
      return SizedBox.shrink();
    }

  }

  Widget buildItemMK2(int index,DocumentSnapshot? document){
    if(document != null){
      Chat chat =Chat.fromDocument(document);
      if(chat.senderID == currentUserID){
        return Row(
          children: <Widget>[
            chat.type == messageType.text
                ?Container(
              child:Text(
                chat.message,
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              width: 200,
              decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.only(topLeft: Radius.circular(23),topRight: Radius.circular(23),bottomLeft: Radius.circular(23))),
              margin: EdgeInsets.only(bottom: 15, right: 5,top:20),
            ): chat.type == messageType.image
                ?Container(
              child: OutlinedButton(
                onPressed:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(photoURL: chat.message)));
                } ,
                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                child: Material(
                  child: Image.network(
                      chat.message,
                      loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent? loadingProgress){
                        if(loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(
                                Radius.circular(0),
                              )
                          ),
                          width: 200,
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                              value: loadingProgress.expectedTotalBytes !=null &&
                                  loadingProgress.expectedTotalBytes !=null
                                  ? loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                                  :null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context,object,stackTrace){
                        return Material(
                          child: Image.asset(
                              'images/img_not_available.jpeg',
                              width: 200,
                              height: 200,
                              fit:BoxFit.cover
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                        );
                      },
                      width: 200,
                      height: 200,
                      fit:BoxFit.cover
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  clipBehavior: Clip.hardEdge,
                ),
              ),
              margin: EdgeInsets.only(bottom: isMessagebyUser(index)? 20:10,right: 10),
            ):Container(
              child: Image.asset(
                'images/gifs/${chat.message}.gif',
                width:100,
                height: 100,
                fit: BoxFit.cover,
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      }
      else{
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  // Container(width: 35,),
                  chat.type == messageType.text
                      ?Container(
                    child:Text(
                      chat.message,
                      style: const TextStyle(
                          color: Colors.black
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    margin: EdgeInsets.only(bottom: 20, right: 5,top:10),
                    decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.only(topLeft: Radius.circular(23),topRight: Radius.circular(23),bottomRight: Radius.circular(23))),
                  ): chat.type == messageType.image
                      ? Container(
                    child: TextButton(
                      onPressed:(){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(photoURL: chat.message)));
                      } ,
                      style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                      child: Material(
                        child: Image.network(
                            chat.message,
                            loadingBuilder: (BuildContext context,Widget child,ImageChunkEvent? loadingProgress){
                              if(loadingProgress == null) return child;
                              return Container(
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(0),
                                    )
                                ),
                                width: 200,
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    value: loadingProgress.expectedTotalBytes !=null &&
                                        loadingProgress.expectedTotalBytes !=null
                                        ? loadingProgress.cumulativeBytesLoaded/loadingProgress.expectedTotalBytes!
                                        :null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context,object,stackTrace) =>Material(
                              child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200,
                                  height: 200,
                                  fit:BoxFit.cover
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            width: 200,
                            height: 200,
                            fit:BoxFit.cover
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                  ): Container(
                    child: Image.asset(
                      'images/gifs/${chat.message}.gif',
                      width:100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    margin: EdgeInsets.only(bottom: 15, right: 10  ),
                  )
                ],
              ),
              // isMessagebyPeer(index)
              // ? Container(
              //   child: Text(
              //     DateFormat('dd MMM yyyy, hh:mm a')
              //     .format(DateTime.fromMicrosecondsSinceEpoch(int.parse(chat.time))) ,
              //    style: const TextStyle(color: ColorConstants.greyColor,fontSize: 12,fontStyle: FontStyle.italic),
              //   ),
              // )
              // : SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      }
    }else{
      return SizedBox.shrink();
    }

  }

  Widget buildMessageList(){
    return Flexible(
        child: chatRoomID.isNotEmpty
              ? StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChats(chatRoomID, _limit),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(snapshot.hasData){
                    return ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemBuilder: (context, index) => buildItemMK2(index,snapshot.data?.docs[index]),
                        itemCount: snapshot.data?.docs.length,
                        reverse: true,
                        controller: listScrollController,
                    );
                  }else{
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                }
              ):
              Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.account_circle,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(width: 20,),
            Text(this.peerName),
          ],
        ),
        centerTitle: true,
      ),
      body: WillPopScope(
          child: Stack(
            children: <Widget>[
              Column(
                children:<Widget> [
                  buildMessageList(),
                  isShowSticker? buildGIF() :SizedBox.shrink(),
                  buildInput(),
                ],
              ),
              buildLoading()
            ],
          ),
          onWillPop: pressBack),
    );
  }
}
