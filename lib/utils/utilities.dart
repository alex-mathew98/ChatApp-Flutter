import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

class Utilities{
  static bool isKeyBoardShowing(){
    if(WidgetsBinding.instance != null){
      return WidgetsBinding.instance!.window.viewInsets.bottom > 0;
    }
    else{
      return false;
    }
  }

  static closeKeyboard(BuildContext context){
    FocusScopeNode currentFocus = FocusScope.of(context);
    if(!currentFocus.hasPrimaryFocus){
      currentFocus.unfocus();
    }
  }
}

class Debouncer{
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action){
    _timer?.cancel();

    _timer = Timer(Duration(milliseconds: milliseconds),action);
  }

}