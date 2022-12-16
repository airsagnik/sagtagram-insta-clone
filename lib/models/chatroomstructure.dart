import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:sagtagram/models/user.dart';
import 'package:sagtagram/providers/chatsproviders.dart';

class Chatroom {
  String id;
  Users obj;
  Chatroom({this.id, this.obj});
}
