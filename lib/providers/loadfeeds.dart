import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sagtagram/models/activitymodel.dart';
import 'package:sagtagram/screens/activity.dart';
import '../models/user.dart';
import '../models/postclass.dart';

class LoadFeed extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final fire = FirebaseFirestore.instance;
  UserCredential user;
  Users userinfo;
  QueryDocumentSnapshot lastdocid;
  int lastnumber;
  QueryDocumentSnapshot lastdocidlikepage;
  QueryDocumentSnapshot lastexploredoc;

  Future<List<Post>> loadfeed(int a) async {
    print("Loading feed");
    //all followers userid is loaded in userid list
    List<String> userids = [];
    List<String> usernames = [];
    List<Post> postfeed = [];
    if (a == 0) {
      var res = await fire
          .collection('following')
          .doc(auth.currentUser.uid)
          .collection('userids')
          .where("status", isEqualTo: "following")
          .orderBy('id')
          .limit(5)
          .get();

      res.docs.forEach((element) {
        var d = element.data();
        print("santa claws");
        userids.add(d['id']);
        lastdocid = element;
      });
    }
    if (a == 1) {
      var res2 = await fire
          .collection('following')
          .doc(auth.currentUser.uid)
          .collection('userids')
          .where("status", isEqualTo: "following")
          .limit(5)
          .orderBy('id')
          .startAfterDocument(lastdocid)
          .get();
      res2.docs.forEach((element) {
        lastdocid = element;
        var d = element.data();
        userids.add(d['id']);
      });
    }
    print("O yes abhi");
    print(userids);

    //all the corresponding userids username is loaded
    await Future.forEach(userids, (element) async {
      var response = await fire.collection('user').doc(element).get();
      var userinformation = response.data();
      print(userinformation);
      userinfo = Users(
          profilepic: userinformation["profileurl"],
          bio: userinformation['bio'],
          username: userinformation['username'],
          email: userinformation['email'],
          fullname: userinformation['name'],
          password: userinformation['password'],
          userid: element);
      usernames.add(userinformation['username']);
      //all the post of a user are brought in
      var postres = await fire
          .collection('post')
          .doc(element)
          .collection('photos')
          .orderBy('time', descending: true)
          .limit(20)
          .get();
      await Future.forEach(postres.docs, (ele) async {
        var postdata = ele.data();
        bool ans;
        var likeres = await fire
            .collection('likes')
            .doc(ele.id)
            .collection('users')
            .doc(auth.currentUser.uid)
            .get();
        if (likeres.data() == null) {
          ans = false;
        } else {
          ans = likeres.data()["liked"];
        }
        int c = 0;
        var countdata = await fire.collection('likescount').doc(ele.id).get();
        if (countdata.data() != null) {
          var cdata = countdata.data();
          c = cdata["no"];
        }
        Post obj = Post(
          likes: c,
          liked: ans,
          profilepic: userinformation['profileurl'],
          caption: postdata['caption'],
          imageurl: postdata['imageurl'],
          postid: ele.id,
          postype: postdata['type'],
          time: postdata['time'].toDate(),
          username: userinformation['username'],
          userid: element,
        );
        postfeed.add(obj);
      });
    });

    return postfeed;
  }

  Future<void> likepost(String postid, String userid) async {
    DateTime tm = DateTime.now();
    await fire
        .collection('likes')
        .doc(postid)
        .collection("users")
        .doc(auth.currentUser.uid)
        .set({"liked": true, "time": tm});

    var res = await fire.collection('likescount').doc(postid).get();
    if (res.data() == null) {
      await fire.collection('likescount').doc(postid).set({"no": 1});
    } else {
      await fire
          .collection('likescount')
          .doc(postid)
          .set({"no": res.data()["no"] + 1});
    }

    await fire.collection('activity').doc(userid).collection('likes').add({
      "userid": auth.currentUser.uid,
      "time": tm,
      "postid": postid,
    });
  }

  Future<void> dislikepost(String postid, String userid) async {
    await fire
        .collection('likes')
        .doc(postid)
        .collection("users")
        .doc(auth.currentUser.uid)
        .delete();
    var res = await fire.collection('likescount').doc(postid).get();
    await fire
        .collection('likescount')
        .doc(postid)
        .set({"no": res.data()["no"] - 1});

    var delres = await fire
        .collection('activity')
        .doc(userid)
        .collection('likes')
        .where("postid", isEqualTo: postid)
        .where("userid", isEqualTo: auth.currentUser.uid)
        .get();

    print("activity length");
    print(delres.docs.length);

    await Future.forEach(delres.docs, (element) async {
      await fire
          .collection('activity')
          .doc(userid)
          .collection('likes')
          .doc(element.id)
          .delete();
    });
  }

  Future<List<Activityload>> fetchlikedusers(String postid, int a) async {
    List<Activityload> lst = [];
    print("loading likes");
    var res;
    if (a == 0) {
      res = await fire
          .collection('likes')
          .doc(postid)
          .collection('users')
          .orderBy("time")
          .where("liked", isEqualTo: true)
          .limit(20)
          .get();
    } else {
      res = await fire
          .collection('likes')
          .doc(postid)
          .collection('users')
          .orderBy("time")
          .where("liked", isEqualTo: true)
          .limit(20)
          .startAfterDocument(lastdocidlikepage)
          .get();
    }
    print(res.docs.length);
    String userid;
    await Future.forEach(res.docs, (element) async {
      userid = element.id;
      lastdocidlikepage = element;
      var udata = await fire.collection('user').doc(userid).get();
      var userdata = udata.data();

      Activityload obj = Activityload(
        userid: userid,
        username: userdata["username"],
        profilepicurl: userdata["profileurl"],
      );

      lst.add(obj);
    });
    return lst;
  }

  Future<List<Post>> loadexplorefeed(String category, int a) async {
    var res;
    if (a == 0) {
      res = await fire
          .collection('postexplore')
          .doc("Z62t7Opv552wVEOeEMRV")
          .collection(category)
          .orderBy("time", descending: true)
          .limit(20)
          .get();
    } else {
      res = await fire
          .collection('postexplore')
          .doc("Z62t7Opv552wVEOeEMRV")
          .collection(category)
          .orderBy("time", descending: true)
          .limit(20)
          .startAfterDocument(lastexploredoc)
          .get();
    }

    List<Post> lst = [];
    await Future.forEach(res.docs, (element) async {
      lastexploredoc = element;
      var userres = await fire.collection("user").doc(element["userid"]).get();
      var userinfo = userres.data();

      print(userinfo);
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
        caption: element["caption"],
        category: category,
        imageurl: element['imageurl'],
        liked: ans,
        likes: c,
        postid: element.id,
        postype: element['type'],
        profilepic: userinfo['profileurl'],
        time: element['time'].toDate(),
        userid: element["userid"],
        username: userinfo['username'],
      );
      lst.add(obj);
    });
    print("ekhane");
    print(lst.length);
    return lst;
  }

  Future<List<Post>> bringsinglepost(String postid, String userid) async {
    List<Post> lst = [];
    print(postid);
    print(userid);

    var res = await fire
        .collection('post')
        .doc(userid)
        .collection('photos')
        .doc(postid)
        .get();

    var postinfo = res.data();
    print(postinfo);

    var uinfo = await fire.collection('user').doc(userid).get();
    var userinfo = uinfo.data();
    bool ans;
    var likeres = await fire
        .collection('likes')
        .doc(postid)
        .collection('users')
        .doc(auth.currentUser.uid)
        .get();
    if (likeres.data() == null) {
      ans = false;
    } else {
      ans = likeres.data()["liked"];
    }
    int c = 0;
    var countdata = await fire.collection('likescount').doc(postid).get();
    if (countdata.data() != null) {
      var cdata = countdata.data();
      c = cdata["no"];
    }

    Post obj = Post(
      caption: postinfo['caption'],
      category: postinfo['category'],
      imageurl: postinfo['imageurl'],
      postid: postid,
      postype: postinfo['type'],
      time: postinfo['time'].toDate(),
      userid: postinfo['userid'],
      profilepic: userinfo['profileurl'],
      username: userinfo['username'],
      liked: ans,
      likes: c,
    );
    lst.add(obj);
    return lst;
  }
}
