import 'package:flutter/material.dart';
import 'package:sagtagram/providers/userauthentication.dart';
import 'package:sagtagram/theme/themeapp.dart';
import 'package:sagtagram/widget/bottombar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/user.dart';
import '../models/postclass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/chatsproviders.dart';
import '../models/chatroomstructure.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Users userinfo;
  bool loading = false;
  List<Post> lst = [];
  String userid = "";
  int viewmode;
  String following;
  ScrollController scroll = ScrollController();
  bool loadingmore = false;
  bool hasmore = true;
  int followers = 0;
  int followingnumber = 0;

  bool darkmode;

  @protected
  @mustCallSuper
  void didChangeDependencies() {
    var k = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    print(k);
    if (k['no'] == 1) {
      userid = k["userid"];
      viewmode = k["no"];
    } else {
      userid = k["userid"];
      viewmode = k["no"];
      print("Mine");
    }
    getuserdata();
    scroll.addListener(() {
      double maxextent = scroll.position.maxScrollExtent;
      double currentscroll = scroll.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxextent - currentscroll <= delta) {
        moreownpost();
      }
    });
  }

  Future<void> getuserdata() async {
    setState(() {
      loading = true;
    });
    userinfo = await Provider.of<UserAuth>(context, listen: false)
        .fetchusedetails(userid);
    lst = await Provider.of<UserAuth>(context, listen: false)
        .fetchownpost(userid, 0);
    following = await Provider.of<UserAuth>(context, listen: false)
        .followercheck(userid);
    followingnumber = await Provider.of<UserAuth>(context, listen: false)
        .getfollowingcount(userid);
    followers = await Provider.of<UserAuth>(context, listen: false)
        .getfollowerscount(userid);
    await getval();
    setState(() {
      loading = false;
    });
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
    if (lst2.length == 0) {
      hasmore = false;
    }

    lst2.forEach((element) {
      lst.add(element);
    });
    loadingmore = false;
  }

  Future<void> getval() async {
    var pre = await SharedPreferences.getInstance();
    darkmode = pre.getBool("dark");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: loading == true ? Text("Loading") : Text(userinfo.username),
        actions: [
          loading == true
              ? Container()
              : Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Row(children: [
                    Icon(Icons.light_mode),
                    Switch(
                        value: darkmode,
                        onChanged: (value) async {
                          await changetheme();
                          setState(() {
                            darkmode = value;
                          });
                        }),
                    Icon(Icons.dark_mode),
                  ]),
                )
        ],
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: getuserdata,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.80,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 0.23,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      userinfo.profilepic.length == 0
                                          ? AssetImage(
                                              'asset/images/profile.png',
                                            )
                                          : NetworkImage(userinfo.profilepic),
                                  radius: 50,
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          child: Text(lst.length.toString())),
                                      Text("Post")
                                    ]),
                                GestureDetector(
                                  onTap: () {
                                    if (viewmode == 0 ||
                                        (userinfo.private == false &&
                                            viewmode == 1) ||
                                        (userinfo.private == true &&
                                            viewmode == 1 &&
                                            following == "following")) {
                                      Navigator.of(context).pushNamed(
                                          '/followerview',
                                          arguments: {
                                            "no": viewmode,
                                            "userid": userid,
                                            "foll": 1
                                          });
                                    }
                                  },
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            child: Text(followers.toString())),
                                        Text("Followers")
                                      ]),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (viewmode == 0 ||
                                        (userinfo.private == false &&
                                            viewmode == 1) ||
                                        (userinfo.private == true &&
                                            viewmode == 1 &&
                                            following == "following")) {
                                      Navigator.of(context).pushNamed(
                                          '/followerview',
                                          arguments: {
                                            "no": viewmode,
                                            "userid": userid,
                                            "foll": 0
                                          });
                                    }
                                  },
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            child: Text(
                                                followingnumber.toString())),
                                        Text(
                                          "Following",
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (viewmode == 0)
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.blue),
                                      width: MediaQuery.of(context).size.width *
                                          0.40,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                      child: MaterialButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              '/editprofile',
                                              arguments: userinfo);
                                        },
                                        child: Text("Edit Profile",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ]),
                            if (viewmode == 1)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.blue),
                                    width: MediaQuery.of(context).size.width *
                                        0.40,
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    child: MaterialButton(
                                      onPressed: () async {
                                        if (following == "false" &&
                                            userinfo.private == false) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "You started Following")));
                                          await Provider.of<UserAuth>(context,
                                                  listen: false)
                                              .sendfollowrequestpublic(
                                                  userinfo.userid);
                                          setState(() {
                                            following = "Following";
                                          });
                                        } else if (following == "false" &&
                                            userinfo.private == true) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Follow request sent",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))));
                                          await Provider.of<UserAuth>(context,
                                                  listen: false)
                                              .sendfollowrequestprivate(
                                                  userinfo.userid);
                                          setState(() {
                                            following = "Follow Request sent";
                                          });
                                        } else if (following == "following") {
                                          showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(ctx)
                                                                .pop(true);
                                                          },
                                                          child: Text("Yes")),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(ctx)
                                                                .pop(false);
                                                          },
                                                          child: Text("No"))
                                                    ],
                                                    title: Text("Unfollow!"),
                                                    content: Text(
                                                        "Do you want to unfollow?"),
                                                  )).then((value) async {
                                            if (value == true) {
                                              await Provider.of<UserAuth>(
                                                      context,
                                                      listen: false)
                                                  .unfollow(userinfo.userid);
                                              setState(() {
                                                following = "false";
                                              });
                                            }
                                          });
                                        }
                                      },
                                      child: Text(
                                          following == "false"
                                              ? "Follow"
                                              : following,
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  if (userinfo.private == false ||
                                      following == "following")
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.blue),
                                      width: MediaQuery.of(context).size.width *
                                          0.40,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                      child: MaterialButton(
                                        onPressed: () async {
                                          var chatroomid =
                                              await Provider.of<ChatsProvider>(
                                                      context,
                                                      listen: false)
                                                  .findchatroom(userid);
                                          Chatroom obj = Chatroom(
                                              id: chatroomid, obj: userinfo);
                                          Navigator.of(context).pushNamed(
                                              '/chatroom',
                                              arguments: obj);
                                        },
                                        child: Text(
                                          "Message",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: MediaQuery.of(context).size.height * 0.10,
                        child: Row(
                          children: [
                            Container(
                              child: Text(
                                userinfo.bio,
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    if (viewmode == 0 ||
                        (viewmode == 1 && userinfo.private == false) ||
                        following == "following")
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                icon: Icon(Icons.image), onPressed: () {}),
                            IconButton(
                                icon: Icon(Icons.video_call), onPressed: () {}),
                            IconButton(icon: Icon(Icons.tv), onPressed: () {})
                          ],
                        ),
                      ),
                    if (viewmode == 0 ||
                        (viewmode == 1 && userinfo.private == false) ||
                        following == "following")
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: GridView.builder(
                            controller: scroll,
                            itemCount: lst.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 3 / 3,
                              crossAxisSpacing: 0,
                            ),
                            itemBuilder: (ctx, i) => GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/display',
                                        arguments: {
                                          "lst": lst,
                                          "index": i,
                                          "userid": userid
                                        }).then((value) {
                                      setState(() {
                                        lst = value;
                                      });
                                    });
                                  },
                                  child: Container(
                                      color: Colors.orange,
                                      alignment: Alignment.center,
                                      child: lst[i].postype != "photo"
                                          ? Image.network(
                                              'https://cdn.smehost.net/dailyrindblogcom-orchardprod/wp-content/uploads/2020/08/InstagramReels_Banner-scaled.jpg')
                                          : Image.network(
                                              lst[i].imageurl,
                                              fit: BoxFit.fitWidth,
                                            )),
                                )),
                      ),
                    if ((following == "false" ||
                            following == "Follow request sent") &&
                        viewmode == 1 &&
                        userinfo.private == true)
                      Container(
                        child: Text(
                            "This account is private,send a follow request to view post"),
                      )
                  ]),
                ),
              ),
            ),
      bottomNavigationBar: viewmode == 1 ? null : BottomnavBar(4),
    );
  }
}
