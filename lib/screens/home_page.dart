import 'package:chat_app_mk2/constants/color_constants.dart';
import 'package:chat_app_mk2/constants/db_constants.dart';
import 'package:chat_app_mk2/constants/title_constants.dart';
import 'package:chat_app_mk2/helpers/auth_helper.dart';
import 'package:chat_app_mk2/helpers/pref_helpers.dart';
import 'package:chat_app_mk2/providers/auth_provider.dart';
import 'package:chat_app_mk2/providers/home_provider.dart';
import 'package:chat_app_mk2/screens/search_page.dart';
import 'package:chat_app_mk2/screens/settings_page.dart';
import 'package:chat_app_mk2/widgets/popup_choices.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limit_increment =20;
  bool isLoading = false;

  late String currentUserID;
  late AuthProvider authProvider;
  late HomeProvider homeProvider;

  List<PopupChoices> options = <PopupChoices>[
    PopupChoices(title: "Settings",icon: Icons.settings),
    PopupChoices(title: "Sign Out",icon: Icons.exit_to_app),
  ];

  Future<void> handleSignOut() async{
    authProvider.signout();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => AuthHelper()));
  }

  void scrollListener(){
    if(listScrollController.offset >= listScrollController.position.maxScrollExtent &&
       !listScrollController.position.outOfRange)
      {
        setState(() {
          _limit+=_limit_increment;
        });
      }
  }

  void onItemMenuPress(PopupChoices choice){
    if(choice.title == "Sign Out"){
      handleSignOut();
    }
    else{
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Settings()));
    }
  }

  Widget buildMenu(){
    return PopupMenuButton<PopupChoices>(
        icon: Icon(Icons.more_vert,color: Colors.grey,),
        onSelected: onItemMenuPress,
        itemBuilder: (BuildContext context){
          return options.map((PopupChoices choice){
            return PopupMenuItem<PopupChoices>(
                value: choice,
                child: Row(
                  children: <Widget>[
                    Icon(choice.icon,color: Colors.white,),
                    Container(width: 10,),
                    Text(choice.title,style: TextStyle(color:Colors.white),)
                  ],
                )
            );
          }).toList();
        }
    );
  }

  void registerNotification(){
    firebaseMessaging.requestPermission();
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.notification != null){
        //Show messaging
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      if(token != null){
        homeProvider.updateDataFireStore(DBconstants.pathUserCollection, currentUserID,
            {'pushToken':token});
      }
    }).catchError((error){
      Fluttertoast.showToast(msg: error.messsage.toString());
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();

    if(authProvider.getUserFirebaseID().toString().isNotEmpty == true){
      currentUserID = authProvider.getUserFirebaseID().toString();
    }
    else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> AuthHelper()), (Route<dynamic> route) => false);
    }

    listScrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(TitleConstants.homeTitle),
        actions: [
          buildMenu()
        ],
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Search()));
        },
      ),
    );
  }
}
