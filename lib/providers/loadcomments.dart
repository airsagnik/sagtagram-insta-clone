import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sagtagram/models/comments.dart';

class LoadComments with ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final fire = FirebaseFirestore.instance;
  QueryDocumentSnapshot doclast;

  Future<Comments> addreply(String postid, String comment, String replycmid,
      String replytouserid, String postuserid, String parentcmtid) async {
    DateTime t = DateTime.now();
    var res = await fire
        .collection('comments')
        .doc(postid)
        .collection('comment')
        .doc(parentcmtid)
        .collection('reply')
        .add({
      "time": t,
      "text": comment,
      "userid": auth.currentUser.uid,
      "replyto": replytouserid,
      "parentid": parentcmtid
    });
    await fire
        .collection('activity')
        .doc(postuserid)
        .collection('comments')
        .add({"userid": auth.currentUser.uid, "time": t, "postid": postid});

    var d = await fire.collection('user').doc(auth.currentUser.uid).get();
    var replyuser = await fire.collection('user').doc(replytouserid).get();
    var info = d.data();
    var reply = replyuser.data();

    Comments obj = Comments(
      likes: false,
      likesno: 0,
      replytoname: reply["username"],
      parentcmtid: parentcmtid,
      isreply: true,
      commentid: res.id,
      profilepicurl: info['profileurl'],
      text: comment,
      time: t,
      userid: auth.currentUser.uid,
      username: info['username'],
    );
    return obj;
  }

  Future<Comments> putcomments(
      String postid, String comment, String userid) async {
    var t = DateTime.now();
    var res = await fire
        .collection('comments')
        .doc(postid)
        .collection('comment')
        .add({"text": comment, "time": t, "userid": auth.currentUser.uid});

    await fire
        .collection('activity')
        .doc(userid)
        .collection('comments')
        .add({"userid": auth.currentUser.uid, "time": t, "postid": postid});

    var d = await fire.collection('user').doc(auth.currentUser.uid).get();
    var info = d.data();

    Comments obj = Comments(
      likes: false,
      isreply: false,
      commentid: res.id,
      profilepicurl: info['profileurl'],
      text: comment,
      time: t,
      userid: auth.currentUser.uid,
      username: info['username'],
    );
    return obj;
  }

  Future<List<Comments>> getcomments(String postid, int a) async {
    List<Comments> lst = [];
    List<String> commenters = [];
    QuerySnapshot<Map<String, dynamic>> res;
    if (a == 0) {
      print("into");
      res = await fire
          .collection('comments')
          .doc(postid)
          .collection('comment')
          .orderBy("time", descending: true)
          .limit(20)
          .get();

      print(res.docs.length);
    } else {
      res = await fire
          .collection('comments')
          .doc(postid)
          .collection('comment')
          .orderBy("time")
          .limit(20)
          .startAfterDocument(doclast)
          .get();
    }

    await Future.forEach(res.docs, (element) async {
      doclast = element;
      String cmtid = element.id;
      var d = element.data();
      var userdata = await fire.collection('user').doc(d["userid"]).get();
      var info = userdata.data();
      var likedata = await fire
          .collection('commentlikes')
          .doc(element.id)
          .collection('likes')
          .get();
      bool ans = false;
      int a = likedata.docs.length;
      likedata.docs.forEach((e) {
        if (e.id == auth.currentUser.uid) {
          ans = true;
        }
      });

      Comments obj;
      obj = Comments(
          isreply: false,
          likesno: a,
          likes: ans,
          commentid: element.id,
          userid: d["userid"],
          profilepicurl: info['profileurl'],
          text: d['text'],
          time: d['time'].toDate(),
          username: info['username']);

      lst.add(obj);

      var replies = await fire
          .collection('comments')
          .doc(postid)
          .collection('comment')
          .doc(element.id)
          .collection('reply')
          .get();
      //bringing replies to a comment
      await Future.forEach(replies.docs, (repl) async {
        var d = repl.data();
        var usercommenter =
            await fire.collection('user').doc(d["replyto"]).get();
        var userdata = await fire.collection('user').doc(d["userid"]).get();
        var info = userdata.data();
        var likedata = await fire
            .collection('commentlikes')
            .doc(repl.id)
            .collection('likes')
            .get();
        bool ans = false;
        int a = likedata.docs.length;
        likedata.docs.forEach((e) {
          if (e.id == auth.currentUser.uid) {
            ans = true;
          }
        });

        Comments obj;
        obj = Comments(
            parentcmtid: cmtid,
            replytoname: usercommenter["username"],
            isreply: true,
            likesno: a,
            likes: ans,
            commentid: repl.id,
            userid: d["userid"],
            profilepicurl: info['profileurl'],
            text: d['text'],
            time: d['time'].toDate(),
            username: info['username']);

        lst.add(obj);
      });
    });
    print("last");
    print(lst);
    return lst;
  }

  Future<void> likecomment(String commentid, String commentersid, String postid,
      String postuserid) async {
    DateTime t = DateTime.now();
    await fire
        .collection('commentlikes')
        .doc(commentid)
        .collection('likes')
        .doc(auth.currentUser.uid)
        .set({
      "time": t,
      "commentersid": commentersid,
      "userid": auth.currentUser.uid,
      "liked": true,
    });

    await fire
        .collection('activity')
        .doc(commentersid)
        .collection('likes')
        .add({
      "postuserid": postuserid,
      "commentersid": commentersid,
      "commentid": commentid,
      "time": t,
      "comment": true,
      "postid": postid,
      "userid": auth.currentUser.uid,
    });
  }

  Future<void> dislikecomment(
      String commentid, String commentersid, String postid) async {
    await fire
        .collection('commentlikes')
        .doc(commentid)
        .collection('likes')
        .doc(auth.currentUser.uid)
        .delete();

    var res = await fire
        .collection('activity')
        .doc(commentersid)
        .collection('likes')
        .where("commentid", isEqualTo: commentid)
        .where("comment", isEqualTo: true)
        .where("userid", isEqualTo: auth.currentUser.uid)
        .get();
    await Future.forEach(res.docs, (element) async {
      await fire
          .collection('activity')
          .doc(commentersid)
          .collection('likes')
          .doc(element.id)
          .delete();
    });
  }
}
