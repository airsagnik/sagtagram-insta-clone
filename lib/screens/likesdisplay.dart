import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/models/activitymodel.dart';
import 'package:sagtagram/providers/loadfeeds.dart';

class LikesPage extends StatefulWidget {
  @override
  _LikesPageState createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  String postid;
  List<Activityload> lst = [];
  ScrollController scroll = ScrollController();
  bool isloading = false;
  bool moredataload = false;
  bool moredatapresent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    postid = ModalRoute.of(context).settings.arguments as String;
    fetchlikedusers(postid, 0);
    scroll.addListener(() {
      double maxextent = scroll.position.maxScrollExtent;
      double currentscroll = scroll.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxextent - currentscroll <= delta) {
        loadagain(postid, 1);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scroll.dispose();
  }

  Future<void> fetchlikedusers(String postid, int a) async {
    setState(() {
      isloading = true;
    });
    lst = await Provider.of<LoadFeed>(context, listen: false)
        .fetchlikedusers(postid, 0);
    setState(() {
      isloading = false;
    });
  }

  Future<void> loadagain(String postid, int a) async {
    if (moredataload == true) {
      return;
    }
    if (moredatapresent == false) {
      return;
    }
    moredataload = true;
    List<Activityload> lst2;
    lst2 = await Provider.of<LoadFeed>(context, listen: false)
        .fetchlikedusers(postid, a);
    if (lst2.length == 0) {
      moredatapresent = false;
    }
    lst2.forEach((element) {
      lst.add(element);
    });
    moredataload = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liked by"),
      ),
      body: isloading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              controller: scroll,
              itemCount: lst.length,
              itemBuilder: (ctx, i) => Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: lst[i].profilepicurl.length == 0
                              ? AssetImage(
                                  'asset/images/profile.png',
                                )
                              : NetworkImage(lst[i].profilepicurl),
                          radius: 50,
                        ),
                        title: Text(
                          lst[i].username,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  )),
    );
  }
}
