import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sagtagram/models/postclass.dart';
import 'package:sagtagram/widget/post.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:provider/provider.dart';
import '../providers/userauthentication.dart';

class Display extends StatefulWidget {
  @override
  _DisplayState createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  List<Post> lst = [];
  int index;
  bool loadingmore = false;
  bool hasmore = true;
  AutoScrollController ownpostscroll = AutoScrollController();
  String userid;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    var info =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    lst = info["lst"];
    index = info["index"];
    userid = info['userid'];
    ownpostscroll.addListener(() async {
      double maxextent = ownpostscroll.position.maxScrollExtent;
      double currentscroll = ownpostscroll.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxextent - currentscroll <= delta) {
        await moreownpost();
      }
    });
    await scrollto();
  }

  @override
  void dispose() {
    super.dispose();
    ownpostscroll.dispose();
  }

  Future<void> moreownpost() async {
    print("Loading more");
    if (loadingmore == true) {
      return;
    }
    if (hasmore == false) {
      return;
    }
    loadingmore = true;
    var lst2 = await Provider.of<UserAuth>(context, listen: false)
        .fetchownpost(userid, 1);
    print(lst2);
    if (lst2.length == 0) {
      hasmore = false;
    }

    lst2.forEach((element) {
      lst.add(element);
    });

    setState(() {
      loadingmore = false;
    });
  }

  Future<void> scrollto() async {
    await ownpostscroll.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
  }

  Future<bool> _willPopCallback() async {
    Navigator.of(context).pop(lst);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(lst);
            },
          ),
          title: Text('Post'),
        ),
        body: ListView.builder(
            controller: ownpostscroll,
            itemCount: lst.length,
            itemBuilder: (ctx, i) => AutoScrollTag(
                key: Key(lst[i].postid),
                controller: ownpostscroll,
                index: i,
                child: PostCard(lst[i]))),
      ),
    );
  }
}
