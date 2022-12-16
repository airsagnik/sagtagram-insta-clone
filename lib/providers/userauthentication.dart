import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:sagtagram/models/user.dart';
import '../models/postclass.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';

class UserAuth extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final fire = FirebaseFirestore.instance;
  Timer timer;
  UserCredential user;
  Users userinfo;
  QueryDocumentSnapshot lastdocidownpost;

  Future<void> userauthentication(String name, String password, String username,
      String email, bool login) async {
    if (login == true) {
      var res;
      try {
        user = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = await fire
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .get();
      } on FirebaseAuthException catch (error) {
        throw error;
      } catch (error) {
        throw error;
      }

      var userdata = res.data();
      userinfo = Users(
          private: userdata['private'],
          profilepic: userdata['profileurl'],
          username: userdata['username'],
          email: userdata['email'],
          fullname: userdata['name'],
          password: userdata['password'],
          userid: auth.currentUser.uid);

      print(userdata);
    } else {
      try {
        user = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
      } on FirebaseAuthException catch (error) {
        throw error;
      } catch (error) {
        throw error;
      }
      userinfo = Users(
          private: true,
          profilepic: "",
          username: username,
          email: email,
          fullname: name,
          password: password,
          userid: auth.currentUser.uid);
      try {
        await fire.collection('user').doc(userinfo.userid).set({
          "private": true,
          'profileurl': "",
          'username': username,
          'name': userinfo.fullname,
          'email': userinfo.email,
          'password': userinfo.password,
        });
      } on FirebaseException catch (error) {
        throw error;
      } catch (error) {
        throw error;
      }
    }
  }

  Future<Users> fetchusedetails(String userid) async {
    var res = await fire.collection('user').doc(userid).get();
    var userdata = res.data();
    print(userdata);
    userinfo = Users(
        private: userdata['private'],
        profilepic: userdata['profileurl'],
        bio: userdata['bio'],
        username: userdata['username'],
        email: userdata['email'],
        fullname: userdata['name'],
        password: userdata['password'],
        userid: res.id);

    return userinfo;
  }

  Future<List<Post>> fetchownpost(String userid, int a) async {
    List<Post> lst = [];
    var res;
    if (a == 0) {
      res = await fire
          .collection('post')
          .doc(userid)
          .collection('photos')
          .orderBy('time', descending: true)
          .limit(20)
          .get();
    }
    if (a == 1) {
      res = await fire
          .collection('post')
          .doc(userid)
          .collection('photos')
          .orderBy('time', descending: true)
          .limit(20)
          .startAfterDocument(lastdocidownpost)
          .get();
    }

    print(res.docs.length);

    await Future.forEach(res.docs, (element) async {
      var datadoc = element.data();
      lastdocidownpost = element;
      bool ans;
      var likeres = await fire
          .collection('likes')
          .doc(element.id)
          .collection('users')
          .doc(auth.currentUser.uid)
          .get();
      var usedate = await fire.collection('user').doc(userid).get();
      var userinfo = usedate.data();
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

      print(datadoc['time']);
      Post obj = Post(
        liked: ans,
        likes: c,
        profilepic: userinfo['profileurl'],
        username: userinfo['username'],
        category: datadoc['category'],
        postype: datadoc['type'],
        caption: datadoc['caption'],
        imageurl: datadoc['imageurl'],
        postid: element.id,
        userid: datadoc['userid'],
        time: datadoc['time'].toDate(),
      );
      lst.add(obj);
    });

    return lst;
  }

  Future<String> followercheck(String userid) async {
    var data = await fire
        .collection('following')
        .doc(auth.currentUser.uid)
        .collection('userids')
        .get();
    String result = "false";
    data.docs.forEach((element) {
      print(element.id);
      if (element.id == userid) {
        result = element['status'];
      }
    });
    return result;
  }

  Future<List<Users>> bringusersforseach() async {
    var res = await fire.collection('user').get();
    List<Users> listofusers = [];
    res.docs.forEach((element) {
      var idu = element.id;
      if (idu != auth.currentUser.uid) {
        var data = element.data();
        Users obj = Users(
            private: data["private"],
            profilepic: data['profileurl'],
            bio: data['bio'],
            email: data['email'],
            fullname: data['name'],
            password: data['password'],
            userid: idu,
            username: data['username']);
        listofusers.add(obj);
      }
    });
    return listofusers;
  }

  Future<void> updateprofileinfo(
      {File image,
      String name,
      String username,
      String bio,
      String url}) async {
    var res = await fire
        .collection('user')
        .doc(auth.currentUser.uid)
        .update({"name": name, "username": username, "bio": bio});
    var profileurl;

    if (url.length == 0 && image != null) {
      var imageres = await FirebaseStorage.instance
          .ref()
          .child('/userimage/${auth.currentUser.uid}.jpg')
          .putFile(image);

      profileurl = await imageres.ref.getDownloadURL();
    }
    if (url.length != 0 && image != null) {
      await FirebaseStorage.instance
          .ref()
          .child('/userimage/${auth.currentUser.uid}.jpg')
          .delete();

      var imageres = await FirebaseStorage.instance
          .ref()
          .child('/userimage/${auth.currentUser.uid}.jpg')
          .putFile(image);

      profileurl = await imageres.ref.getDownloadURL();
    }

    if (image != null) {
      var res = await fire
          .collection('user')
          .doc(auth.currentUser.uid)
          .update({"profileurl": profileurl});
    }
    return;
  }

  Future<void> removeimage() async {
    await FirebaseStorage.instance
        .ref()
        .child('/userimage/${auth.currentUser.uid}.jpg')
        .delete();

    var res = await fire
        .collection('user')
        .doc(auth.currentUser.uid)
        .update({"profileurl": ""});
  }

  Future<void> sendfollowrequestprivate(String userid) async {
    print(userid);

    await fire
        .collection('activity')
        .doc(userid)
        .collection('followrequest')
        .doc(auth.currentUser.uid)
        .set({
      "status": "pending",
      "userid": auth.currentUser.uid,
      "time": DateTime.now(),
    });

    await fire
        .collection('following')
        .doc(auth.currentUser.uid)
        .collection('userids')
        .doc(userid)
        .set({"id": userid, "status": "Follow request sent"});
  }

  Future<void> sendfollowrequestpublic(String userid) async {
    await fire
        .collection('activity')
        .doc(userid)
        .collection('followrequest')
        .doc(auth.currentUser.uid)
        .set({
      "status": "following",
      "userid": auth.currentUser.uid,
      "time": DateTime.now(),
    });

    await fire
        .collection('followers')
        .doc(userid)
        .collection('followersid')
        .doc(auth.currentUser.uid)
        .set({"id": auth.currentUser.uid, "status": "following"});

    await fire
        .collection('following')
        .doc(auth.currentUser.uid)
        .collection('userids')
        .doc(userid)
        .set({"id": userid, "status": "following"});
  }

  Future<int> getfollowerscount(String userid) async {
    var res = await fire
        .collection('followers')
        .doc(userid)
        .collection('followersid')
        .get();
    return res.docs.length;
  }

  Future<int> getfollowingcount(String userid) async {
    var res = await fire
        .collection('following')
        .doc(userid)
        .collection('userids')
        .where('status', isEqualTo: "following")
        .get();
    return res.docs.length;
  }

  Future<void> unfollow(String userid) async {
    await fire
        .collection('following')
        .doc(auth.currentUser.uid)
        .collection('userids')
        .doc(userid)
        .delete();

    await fire
        .collection('followers')
        .doc(userid)
        .collection('followersid')
        .doc(auth.currentUser.uid)
        .delete();
  }

  Future<List<Users>> bringallfollowers(String userid, int foll) async {
    List<Users> lst = [];
    String searchfor;
    String collname;
    if (foll == 1) {
      searchfor = "followers";
      collname = "followersid";
    } else {
      searchfor = "following";
      collname = "userids";
    }
    var res;
    if (foll == 1) {
      res = await fire
          .collection(searchfor)
          .doc(userid)
          .collection(collname)
          .get();
    } else {
      res = await fire
          .collection(searchfor)
          .doc(userid)
          .collection(collname)
          .where("status", isEqualTo: "following")
          .get();
    }
    await Future.forEach(res.docs, (element) async {
      var followerid = element["id"];
      var userinfo = await fire.collection('user').doc(element.id).get();
      var uif = userinfo.data();
      Users obj = Users(
          bio: uif['bio'],
          private: uif['private'],
          profilepic: uif["profileurl"],
          username: uif["username"],
          email: uif['email'],
          fullname: uif['name'],
          password: uif['password'],
          userid: userid);
      lst.add(obj);
    });
    print("follower anchi");
    print(lst);
    return lst;
  }
}
