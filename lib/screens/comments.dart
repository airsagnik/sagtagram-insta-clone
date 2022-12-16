import 'package:flutter/material.dart';
import '../models/comments.dart';
import '../providers/loadcomments.dart';
import 'package:provider/provider.dart';

class Commentdisplay extends StatefulWidget {
  @override
  _CommentdisplayState createState() => _CommentdisplayState();
}

class _CommentdisplayState extends State<Commentdisplay> {
  List<Comments> lst = [];
  String postuserid = "";
  String postid = "";
  TextEditingController txtctr = TextEditingController();
  ScrollController scroll2 = ScrollController();
  bool isloading;
  bool moredata = true;
  bool loadingmore = false;
  String comment = "";
  bool hasload = false;
  var focusnode = FocusNode();
  bool isreply = false;
  int replycommentindex;
  String replytocmtid;
  String replytouserid;
  String parentid;

  @override
  void dispose() {
    super.dispose();
    txtctr.dispose();
    scroll2.dispose();
  }

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hasload == false) {
      var posidmap =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      postuserid = posidmap["userid"];
      postid = posidmap["postid"];
      print(postuserid);
      print(postid);
      getcomment(postid, 0);

      scroll2.addListener(() async {
        double maxextent = scroll2.position.maxScrollExtent;
        double currentscroll = scroll2.position.pixels;
        double delta = MediaQuery.of(context).size.height * 0.25;
        if (maxextent - currentscroll <= delta) {
          await loadmore();
        }
      });
      hasload = true;
    }
    hasload = true;
  }

  Future<void> addreply(String postid, String comment, String replytouserid,
      String replycmid, String postuserid, String parentcmtid) async {
    var rep = await Provider.of<LoadComments>(context, listen: false).addreply(
        postid, comment, replycmid, replytouserid, postuserid, parentcmtid);
    isreply = false;
    setState(() {
      lst.insert(replycommentindex, rep);
    });
  }

  Future<void> getcomment(String postid, int a) async {
    setState(() {
      isloading = true;
    });
    lst = await Provider.of<LoadComments>(context, listen: false)
        .getcomments(postid, a);
    setState(() {
      isloading = false;
    });
  }

  Future<void> loadmore() async {
    if (loadingmore == true) {
      return;
    }
    if (moredata == false) {
      return;
    }
    loadingmore = true;
    var lst2 = await Provider.of<LoadComments>(context, listen: false)
        .getcomments(postid, 1);
    if (lst.length == 0) moredata = false;
    lst2.forEach((element) {
      lst.add(element);
    });
    loadingmore = false;
  }

  Future<void> addcomment(String postid, String comment, String userid) async {
    var obj = await Provider.of<LoadComments>(context, listen: false)
        .putcomments(postid, comment, userid);
    obj.likesno = 0;
    setState(() {
      lst.insert(0, obj);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar ab = AppBar(
      title: Text("Comments"),
    );
    return Scaffold(
        appBar: ab,
        body: isloading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).size.height * 0.10 -
                          MediaQuery.of(context).padding.top -
                          ab.preferredSize.height,
                      child: ListView.builder(
                          controller: scroll2,
                          itemCount: lst.length,
                          itemBuilder: (ctx, i) {
                            String tme;
                            DateTime cmtme = lst[i].time;
                            DateTime tk = DateTime.now();
                            if (tk.difference(cmtme).inSeconds < 60) {
                              tme = tk.difference(cmtme).inSeconds.toString() +
                                  's';
                            } else if (tk.difference(cmtme).inSeconds < 3600) {
                              tme = tk.difference(cmtme).inMinutes.toString() +
                                  "m";
                            } else if (tk.difference(cmtme).inSeconds < 86400) {
                              tme = tk.difference(cmtme).inHours.toString() +
                                  "hrs";
                            } else if (tk.difference(cmtme).inSeconds <
                                604800) {
                              tme =
                                  tk.difference(cmtme).inDays.toString() + "dy";
                            } else {
                              tme = ((tk.difference(cmtme).inDays ~/ 7).toInt())
                                      .toString() +
                                  "w";
                            }

                            return Row(children: [
                              if (lst[i].isreply == true)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              Expanded(
                                child: ListTile(
                                  key: Key(lst[i].commentid),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text('${lst[i].likesno}  Like'),
                                      TextButton(
                                          onPressed: () {
                                            print(
                                                "replying to ${lst[i].username}");

                                            replycommentindex = i;
                                            replytocmtid = lst[i].commentid;
                                            replytouserid = lst[i].userid;
                                            parentid =
                                                lst[i].parentcmtid == null
                                                    ? lst[i].commentid
                                                    : lst[i].parentcmtid;
                                            focusnode.requestFocus();

                                            isreply = true;
                                          },
                                          child: Text("reply")),
                                      Text(tme) //time
                                    ],
                                  ),
                                  leading: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: lst[i]
                                                  .profilepicurl
                                                  .length ==
                                              0
                                          ? AssetImage(
                                              'asset/images/profile.png',
                                            )
                                          : NetworkImage(lst[i].profilepicurl)),
                                  title: Text(lst[i].isreply == true
                                      ? '@' +
                                          lst[i].replytoname +
                                          '\n' +
                                          lst[i].text
                                      : lst[i].username + '\n' + lst[i].text),
                                  trailing: IconButton(
                                    icon: lst[i].likes == false
                                        ? Icon(Icons.favorite_outline)
                                        : Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          ),
                                    onPressed: () async {
                                      if (lst[i].likes == false) {
                                        setState(() {
                                          lst[i].likesno = lst[i].likesno + 1;
                                          lst[i].likes = !lst[i].likes;
                                        });
                                        await Provider.of<LoadComments>(context,
                                                listen: false)
                                            .likecomment(
                                                lst[i].commentid,
                                                lst[i].userid,
                                                postid,
                                                postuserid);
                                      } else {
                                        setState(() {
                                          lst[i].likes = !lst[i].likes;
                                          lst[i].likesno = lst[i].likesno - 1;
                                        });
                                        await Provider.of<LoadComments>(context,
                                                listen: false)
                                            .dislikecomment(lst[i].commentid,
                                                lst[i].userid, postid);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ]);
                          }),
                    ),
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: TextField(
                            focusNode: focusnode,
                            controller: txtctr,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Comment"),
                          ),
                          height: MediaQuery.of(context).size.height * 0.10,
                          width: MediaQuery.of(context).size.width * 0.86,
                        ),
                        IconButton(
                            onPressed: () async {
                              if (txtctr.text.length != 0) {
                                if (isreply == false) {
                                  print("hello");
                                  comment = txtctr.text;
                                  await addcomment(postid, comment, postuserid);
                                  txtctr.clear();
                                } else {
                                  comment = txtctr.text;
                                  await addreply(postid, comment, replytouserid,
                                      replytocmtid, postuserid, parentid);

                                  isreply = false;
                                  txtctr.clear();
                                }
                              }
                            },
                            icon: Icon(Icons.send))
                      ],
                    )
                  ],
                ),
              ));
  }
}
