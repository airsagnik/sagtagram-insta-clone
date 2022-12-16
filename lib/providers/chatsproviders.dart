import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sagtagram/models/chatroomstructure.dart';
import '../models/user.dart';
import '../models/postclass.dart';

class ChatsProvider extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final fire = FirebaseFirestore.instance;

  Future<String> findchatroom(String searcheduserid) async {
    var chatroomid;
    var res = await fire
        .collection('chatroom')
        .doc(auth.currentUser.uid)
        .collection('chatrooms')
        .where("userid", isEqualTo: searcheduserid)
        .get();

    res.docs.forEach((element) {
      chatroomid = element.id;
    });

    return chatroomid;
  }

  Future<List<Chatroom>> loadchatrooms() async {
    List<Chatroom> lst = [];
    var res = await fire
        .collection('chatroom')
        .doc(auth.currentUser.uid)
        .collection('chatrooms')
        .orderBy("time", descending: true)
        .get();

    await Future.forEach(res.docs, (element) async {
      var chatroomid = element.id;
      var userid = element["userid"];
      var userinfo = await fire.collection('user').doc(userid).get();
      var userdata = userinfo.data();
      print("chat section");
      print(userdata);
      Users obj = Users(
          email: userdata['email'],
          fullname: userdata['name'],
          password: userdata['password'],
          userid: userid,
          bio: userdata['bio'],
          private: userdata['private'],
          profilepic: userdata['profileurl'],
          username: userdata['username']);
      Chatroom chatitem = Chatroom(id: chatroomid, obj: obj);
      lst.add(chatitem);
    });
    return lst;
  }

  Future<void> sendmessage(
      String chatroomid, String text, String secuserid, Post obj) async {
    DateTime k = DateTime.now();
    if (obj == null) {
      await fire
          .collection('chats')
          .doc(chatroomid)
          .collection('messages')
          .add({
        "senderid": auth.currentUser.uid,
        "text": text,
        "time": k,
        "sharedpost": null,
      });
    } else {
      await fire
          .collection('chats')
          .doc(chatroomid)
          .collection('messages')
          .add({
        "senderid": auth.currentUser.uid,
        "text": null,
        "time": k,
        "sharedpost": {
          "postid": obj.postid,
          "caption": obj.caption,
          "category": obj.category,
          "imageurl": obj.imageurl,
          "type": obj.postype,
          "userid": obj.userid,
          "time": obj.time
        },
      });
    }

    await fire
        .collection('chatroom')
        .doc(auth.currentUser.uid)
        .collection('chatrooms')
        .doc(chatroomid)
        .update({"time": k});
    await fire
        .collection('chatroom')
        .doc(secuserid)
        .collection('chatrooms')
        .doc(chatroomid)
        .update({"time": k});
  }

  Future<String> createnewchatroom(String secuserid, String text) async {
    var t = DateTime.now();
    var res = await fire.collection('chats').add(
        {"userid1": auth.currentUser.uid, "userid2": secuserid, "time": t});
    var chatroomid = res.id;

    await fire.collection('chats').doc(chatroomid).collection('messages').add({
      "senderid": auth.currentUser.uid,
      "text": text,
      "time": t,
      "sharedpost": null,
    });

    await fire
        .collection('chatroom')
        .doc(auth.currentUser.uid)
        .collection('chatrooms')
        .doc(chatroomid)
        .set({
      "userid": secuserid,
      "time": t,
    });

    await fire
        .collection('chatroom')
        .doc(secuserid)
        .collection('chatrooms')
        .doc(chatroomid)
        .set({
      "userid": auth.currentUser.uid,
      "time": t,
    });
    return chatroomid;
  }
}
