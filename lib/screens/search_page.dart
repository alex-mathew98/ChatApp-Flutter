import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:chat_app_mk2/helpers/auth_helper.dart';
import 'package:chat_app_mk2/models/user.dart';
import 'package:chat_app_mk2/providers/auth_provider.dart';
import 'package:chat_app_mk2/providers/home_provider.dart';
import 'package:chat_app_mk2/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/src/provider.dart';

import 'chat_page.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late String currentUserID;
  late AuthProvider authProvider;
  late HomeProvider homeProvider;


  int _limit = 20;
  int _limit_increment = 20;
  final ScrollController listScrollController = ScrollController();

  String _search = "";
  Debouncer searchDebouncer = Debouncer(milliseconds: 500);
  StreamController<bool> clearController = StreamController<bool>();
  TextEditingController searchTextEditingController =
      new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    clearController.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();

    if (authProvider.getUserFirebaseID().toString().isNotEmpty == true) {
      currentUserID = authProvider.getUserFirebaseID().toString();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthHelper()),
          (Route<dynamic> route) => false);
    }

    //listScrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limit_increment;
      });
    }
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      Users user = Users.fromDocument(document);
      if (user.id == currentUserID) {
        return SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            onPressed: () {
              if (Utilities.isKeyBoardShowing()) {
                Utilities.closeKeyboard(context);
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            peerID: user.id,
                            peerName: user.name,
                            peerAvatar: user.photoURL,
                          )));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.grey.withOpacity(.2)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ))),
            child: Row(
              children: <Widget>[
                Material(
                  child: user.photoURL.isNotEmpty
                      ? Image.network(user.photoURL,
                          fit: BoxFit.cover, width: 50, height: 50,
                          errorBuilder: (context, object, stackTrace) {
                          return const Icon(
                            Icons.account_circle,
                            size: 50,
                            color: Colors.grey,
                          );
                        }, loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                                value: loadingProgress.expectedTotalBytes !=
                                            null &&
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        })
                      : Icon(
                          Icons.account_circle,
                          size: 50,
                          color: Colors.grey,
                        ),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                    child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${user.name}',
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      ),
                      Container(
                        child: Text(
                          '${user.email}',
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20),
                ))
              ],
            ),
          ),
          margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Row(
                children: [
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32.0)),
                      child: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: TextField(
                    controller: searchTextEditingController,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        clearController.add(true);
                        setState(() {
                          _search = value;
                        });
                      } else {
                        _search = "";
                      }
                    },
                    decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.white)),
                  )),
                  StreamBuilder(
                      stream: clearController.stream,
                      builder: (context, snapshot) {
                        return snapshot.data == true
                            ? GestureDetector(
                                onTap: () {
                                  searchTextEditingController.clear();
                                  clearController.add(false);
                                  setState(() {
                                    _search = "";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  child: const Icon(Icons.clear_rounded),
                                ),
                              )
                            : SizedBox.shrink();
                      }),
                ],
              ),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: homeProvider.getStreamFireStore(
                        DBconstants.pathUserCollection, _limit, _search),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.builder(
                            padding: EdgeInsets.all(10),
                            itemBuilder: (context, index) =>
                                buildItem(context, snapshot.data?.docs[index]),
                            itemCount: snapshot.data?.docs.length,
                            controller: listScrollController,
                          );
                        } else {
                          return const Center(
                            child: Text(
                              "No user found!",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        );
                      }
                    }))

          ],
        ),
      ),
    );
  }
}
