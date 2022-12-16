import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sagtagram/models/postclass.dart';

class Reelsprovider extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final fire = FirebaseFirestore.instance;
  QueryDocumentSnapshot lastdocid;
  Future<List<Post>> fetchreels(int a) async {
    List<Post> lst = [];
    var res;
    if (a == 0) {
      res = await fire
          .collection('reels')
          .orderBy("time", descending: true)
          .limit(20)
          .get();
    } else {
      res = await fire
          .collection('reels')
          .orderBy("time", descending: true)
          .limit(20)
          .startAfterDocument(lastdocid)
          .get();
    }

    await Future.forEach(res.docs, (element) async {
      lastdocid = element;
      var postdata = element.data();
      var useres = await fire.collection('user').doc(postdata['userid']).get();
      var userinfo = useres.data();
      bool ans;
      var likeres = await fire
          .collection('likes')
          .doc(element.id)
          .collection('users')
          .doc(auth.currentUser.uid)
          .get();
      if (likeres.data() == null) {
        ans = false;
      } else {
        ans = likeres.data()["liked"];
      }
      int c = 0;
      var countdata = await fire.collection('likescount').doc(element.id).get();
      if (countdata.data() != null) {
        var cdata = countdata.data();
        c = cdata["no"];
      }
      Post obj = Post(
          caption: element['caption'],
          category: element['category'],
          imageurl: element['imageurl'],
          liked: ans,
          likes: c,
          postid: element.id,
          postype: element['type'],
          profilepic: userinfo['profileurl'],
          time: element['time'].toDate(),
          userid: element['userid'],
          username: userinfo['username']);
      lst.add(obj);
    });
    return lst;
  }
}
