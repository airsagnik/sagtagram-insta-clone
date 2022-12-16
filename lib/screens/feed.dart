import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/providers/loadfeeds.dart';
import 'package:sagtagram/widget/bottombar.dart';
import 'package:sagtagram/widget/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import '../models/postclass.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Post> feed = [];
  bool loading;
  bool bottomloading = false;
  ScrollController scroll = ScrollController();
  bool loadingmore = false;
  bool moreavailable = true;
  VideoPlayerController vp;

  @override
  void didChangeDependencies() {
    getfeed();
    scroll.addListener(() {
      double maxextent = scroll.position.maxScrollExtent;
      double currentscroll = scroll.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxextent - currentscroll <= delta) {
        getmorefeed();
      }
    });
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    scroll.dispose();
    if (vp != null) {
      vp.dispose();
    }
    super.dispose();
  }

  Future<void> getfeed() async {
    setState(() {
      loading = true;
    });
    feed = await Provider.of<LoadFeed>(context, listen: false).loadfeed(0);
    setState(() {
      loading = false;
    });
  }

  Future<void> getmorefeed() async {
    setState(() {
      bottomloading = true;
    });
    if (loadingmore == true) {
      return;
    }
    if (moreavailable = false) {
      return;
    }

    loadingmore = true;

    var feed2 = await Provider.of<LoadFeed>(context, listen: false).loadfeed(1);
    if (feed2.length < 1) {
      moreavailable = false;
    }
    feed2.forEach((element) {
      feed.add(element);
    });

    loadingmore = false;

    setState(() {
      bottomloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Sagtagram"),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/uploadpost');
            },
            icon: Icon(Icons.add)),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/sagtachat');
              },
              icon: Icon(Icons.chat_bubble)),
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                //await FirebaseAuth.instance.currentUser.reload();
                Navigator.of(context).pushReplacementNamed('/pageone');
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              height: MediaQuery.of(context).size.height * 0.80,
              width: double.infinity,
              child: ListView.builder(
                controller: scroll,
                itemBuilder: (ctx, i) {
                  return PostCard(feed[i]);
                },
                itemCount: feed.length,
              ),
            ),
      bottomNavigationBar: BottomnavBar(0),
    );
  }
}
