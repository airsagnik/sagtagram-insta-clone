import 'package:flutter/material.dart';
import 'package:sagtagram/models/postclass.dart';
import 'package:sagtagram/providers/loadfeeds.dart';
import 'package:sagtagram/widget/post.dart';
import 'package:provider/provider.dart';

class Activitypost extends StatefulWidget {
  @override
  _ActivitypostState createState() => _ActivitypostState();
}

class _ActivitypostState extends State<Activitypost> {
  List<Post> lst = [];
  String postid;
  String userid;
  bool isloading = false;
  @override
  void didChangeDependencies() {
    var postinfo =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    postid = postinfo["postid"];
    userid = postinfo["userid"];
    fetchsinglepost(postid, userid);
    super.didChangeDependencies();
  }

  Future<void> fetchsinglepost(String postid, String userid) async {
    setState(() {
      isloading = true;
    });
    lst = await Provider.of<LoadFeed>(context, listen: false)
        .bringsinglepost(postid, userid);

    print(lst.length);
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post"),
      ),
      body: isloading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: lst.length, itemBuilder: (ctx, i) => PostCard(lst[i])),
    );
  }
}
