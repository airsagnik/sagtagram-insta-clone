import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Upload extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final fire = FirebaseFirestore.instance;
  Future<void> uploadpost(File image, String caption, String location,
      String posttype, String category) async {
    print(posttype + "in providers");
    DateTime t = DateTime.now();
    var response = await fire
        .collection('post')
        .doc(auth.currentUser.uid)
        .collection('photos')
        .add({
      'category': category,
      'type': posttype,
      'caption': caption,
      'location': location,
      'userid': auth.currentUser.uid,
      'time': t,
    });
    String postid = response.id;
    var res = await FirebaseStorage.instance
        .ref()
        .child('postphotos/$postid.jpg')
        .putFile(image);
    String url = await res.ref.getDownloadURL();
    var respon = await fire
        .collection('post')
        .doc(auth.currentUser.uid)
        .collection('photos')
        .doc(postid)
        .update({'imageurl': url});
    var userdetails =
        await fire.collection('user').doc(auth.currentUser.uid).get();
    var usdet = userdetails.data();

    if (usdet['private'] == false) {
      await fire
          .collection('postexplore')
          .doc("Z62t7Opv552wVEOeEMRV")
          .collection(category)
          .doc(postid)
          .set({
        'imageurl': url,
        'category': category,
        'type': posttype,
        'caption': caption,
        'location': location,
        'userid': auth.currentUser.uid,
        'time': t,
      });

      if (posttype == "reels" && usdet['private'] == false) {
        await fire.collection('reels').doc(postid).set({
          'imageurl': url,
          'category': category,
          'type': posttype,
          'caption': caption,
          'location': location,
          'userid': auth.currentUser.uid,
          'time': t,
        });
      }
    }
  }
}
