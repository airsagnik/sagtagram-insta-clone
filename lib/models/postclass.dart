import 'package:flutter/cupertino.dart';

//posttype can be three types 1.photo 2.reels 3.igtv 4.stories
//category is travel decor diy etc.
class Post extends ChangeNotifier {
  String category;
  int likes;
  String profilepic;
  String username;
  DateTime time;
  String imageurl;
  String caption;
  String postid;
  String userid;
  String postype;
  bool liked;
  Post(
      {this.category,
      this.likes,
      this.profilepic,
      this.username,
      this.caption,
      this.imageurl,
      this.postid,
      this.postype,
      this.time,
      this.userid,
      this.liked});
}
