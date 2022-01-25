import 'package:chat_app_mk2/constants/title_constants.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImage extends StatelessWidget {

  final String photoURL;

  const ViewImage({Key? key, required this.photoURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TitleConstants.fullPhotoTitle,
          // style: TextStyle(),
        ),
      ),
      body:  Container(
        child: PhotoView(imageProvider: NetworkImage(photoURL),
          
        ),
      ),
    );
  }
}
