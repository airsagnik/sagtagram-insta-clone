import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/providers/loadfeeds.dart';
import 'package:video_player/video_player.dart';
//import 'package:sagtagram/providers/userauthentication.dart';
import '../models/postclass.dart';
import '../widget/post.dart';

class Explorefeed extends StatefulWidget {
  @override
  _ExplorefeedState createState() => _ExplorefeedState();
}

class _ExplorefeedState extends State<Explorefeed> {
  ScrollController scrollexplore = ScrollController();
  List<Post> lst = [];
  bool isloading = false;
  String s = "";
  bool morefeeds = true;
  bool fetchingmore = false;
  @override
  void didChangeDependencies() {
    var so = ModalRoute.of(context).settings.arguments as String;
    s = so;
    scrollexplore.addListener(() async {
      double maxextent = scrollexplore.position.maxScrollExtent;
      double currentscroll = scrollexplore.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxextent - currentscroll <= delta) {
        await getmoreexplore(s);
      }
    });
    bringpost(s);
    super.didChangeDependencies();
  }

  Future<void> bringpost(String category) async {
    setState(() {
      isloading = true;
    });
    lst = await Provider.of<LoadFeed>(context, listen: false)
        .loadexplorefeed(category, 0);
    setState(() {
      isloading = false;
    });
  }

  Future<void> getmoreexplore(String category) async {
    if (fetchingmore == true) {
      return;
    }
    if (morefeeds == false) {
      return;
    }
    fetchingmore = true;
    var lst2 = await Provider.of<LoadFeed>(context, listen: false)
        .loadexplorefeed(category, 1);
    if (lst2.length == 0) {
      morefeeds = false;
    }
    lst2.forEach((element) {
      lst.add(element);
    });

    setState(() {
      fetchingmore = false;
    });
  }

  @override
  void dispose() {
    scrollexplore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var s = ModalRoute.of(context).settings.arguments as String;
    AppBar ab = AppBar(
      title: Text("$s"),
    );
    return Scaffold(
      appBar: ab,
      body: isloading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  ab.preferredSize.height,
              width: double.infinity,
              child: ListView.builder(
                controller: scrollexplore,
                itemBuilder: (ctx, i) => PostCard(lst[i]),
                itemCount: lst.length,
              ),
            ),
    );
  }
}
