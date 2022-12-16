import 'package:flutter/cupertino.dart';

class Users {
  String bio;
  bool private;
  final String userid;
  final String email;
  final String username;
  final String password;
  final String fullname;
  String profilepic;
  List<String> postid;
  Users(
      {@required this.email,
      @required this.fullname,
      @required this.password,
      @required this.userid,
      this.private,
      this.bio,
      this.username,
      this.postid,
      this.profilepic});
}
