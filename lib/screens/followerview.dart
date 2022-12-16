import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/models/user.dart';
import 'package:sagtagram/providers/userauthentication.dart';

class Followerview extends StatefulWidget {
  @override
  _FollowerviewState createState() => _FollowerviewState();
}

class _FollowerviewState extends State<Followerview> {
  int viewmode;
  String userid;
  int foll;
  bool isloading = false;
  List<Users> lst = [];
  @override
  void didChangeDependencies() {
    var k = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    viewmode = k['no'];
    userid = k["userid"];
    foll = k["foll"];
    getfollowers();
    super.didChangeDependencies();
  }

  Future<void> getfollowers() async {
    setState(() {
      isloading = true;
    });
    lst = await Provider.of<UserAuth>(context, listen: false)
        .bringallfollowers(userid, foll);
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Follower"),
      ),
      body: isloading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: lst.length,
              itemBuilder: (ctx, i) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: lst[i].profilepic.length == 0
                          ? AssetImage(
                              'asset/images/profile.png',
                            )
                          : NetworkImage(lst[i].profilepic),
                    ),
                    title: Text(lst[i].username),
                    subtitle: Text(lst[i].fullname),
                  )),
    );
  }
}
