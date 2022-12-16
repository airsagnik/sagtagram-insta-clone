import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sagtagram/models/activitymodel.dart';
import '../models/postclass.dart';

class Activityfeed extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final fire = FirebaseFirestore.instance;

  Future<List<Activityload>> fetchrequest() async {
    List<Activityload> lst = [];
    var res = await fire
        .collection('activity')
        .doc(auth.currentUser.uid)
        .collection('followrequest')
        .orderBy('time', descending: true)
        .get();

    await Future.forEach(res.docs, (element) async {
      var data1 = element.data();
      var res2 = await fire.collection('user').doc(element.id).get();
      var data2 = res2.data();
      Activityload obj = Activityload(
          comment: false,
          likes: false,
          status: data1['status'],
          time: data1['time'].toDate(),
          userid: element.id,
          username: data2['username'],
          private: data2['private'],
          profilepicurl: data2['profileurl']);

      lst.add(obj);
    });

    res = await fire
        .collection('activity')
        .doc(auth.currentUser.uid)
        .collection('likes')
        .orderBy('time', descending: true)
        .get();

    await Future.forEach(res.docs, (element) async {
      var data1 = element.data();
      bool ans = false;
      if (data1['comment'] == true) {
        ans = true;
      }
      var res2 = await fire.collection('user').doc(data1['userid']).get();
      var data2 = res2.data();
      Activityload obj = Activityload(
          postuserid: ans == false ? null : data1['postuserid'],
          comment: ans,
          postid: data1["postid"],
          likes: true,
          time: data1['time'].toDate(),
          userid: data1['userid'],
          username: data2['username'],
          private: data2['private'],
          profilepicurl: data2['profileurl']);

      lst.add(obj);
    });

    res = await fire
        .collection('activity')
        .doc(auth.currentUser.uid)
        .collection('comments')
        .orderBy('time', descending: true)
        .get();
    print("comments");
    print(res.docs.length);

    await Future.forEach(res.docs, (element) async {
      var data1 = element.data();
      var res2 = await fire.collection('user').doc(data1['userid']).get();
      var data2 = res2.data();
      Activityload obj = Activityload(
          comment: true,
          postid: data1["postid"],
          likes: false,
          time: data1['time'].toDate(),
          userid: data1['userid'],
          username: data2['username'],
          private: data2['private'],
          profilepicurl: data2['profileurl']);

      lst.add(obj);
    });

    return lst;
  }

  Future<void> acceptrequest(String userid) async {
    await fire
        .collection('following')
        .doc(userid)
        .collection('userids')
        .doc(auth.currentUser.uid)
        .update({"status": "following"});

    await fire
        .collection('followers')
        .doc(auth.currentUser.uid)
        .collection("followersid")
        .doc(userid)
        .set({"id": userid, "status": "following"});

    await fire
        .collection("activity")
        .doc(auth.currentUser.uid)
        .collection('followrequest')
        .doc(userid)
        .update({"status": "following"});
  }

  Future<void> declinerequest(String userid) async {
    await fire
        .collection('following')
        .doc(userid)
        .collection('userids')
        .doc(auth.currentUser.uid)
        .delete();

    await fire
        .collection("activity")
        .doc(auth.currentUser.uid)
        .collection('followrequest')
        .doc(userid)
        .delete();
  }
}
