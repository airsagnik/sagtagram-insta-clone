import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/postclass.dart';
import '../providers/loadfeeds.dart';
import 'package:provider/provider.dart';
import '../providers/chatsproviders.dart';
import '../widget/sendpost.dart';
import '../models/chatroomstructure.dart';

class Reelitem extends StatefulWidget {
  Post reelobj;
  Reelitem(this.reelobj);
  @override
  _ReelitemState createState() => _ReelitemState();
}

class _ReelitemState extends State<Reelitem> {
  VideoPlayerController videoplayer;
  @override
  void initState() {
    super.initState();
    videoplayer = VideoPlayerController.network(widget.reelobj.imageurl);
    videoplayer.addListener(() {
      setState(() {});
    });
    videoplayer.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    if (videoplayer != null) {
      videoplayer.dispose();
    }
  }

  Future<void> sharewithchat(context) async {
    List<Chatroom> chats = [];
    chats = await Provider.of<ChatsProvider>(context, listen: false)
        .loadchatrooms();

    showModalBottomSheet(
        context: context,
        builder: (ctx) => ListView.builder(
            itemCount: chats.length,
            itemBuilder: (ctx, i) {
              return SendPost(chats[i], widget.reelobj);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (videoplayer.value.volume != 0) {
          videoplayer.setVolume(0);
        } else {
          videoplayer.setVolume(1);
        }
      },
      onDoubleTap: () async {
        if (widget.reelobj.liked == false) {
          setState(() {
            widget.reelobj.liked = true;
            widget.reelobj.likes = widget.reelobj.likes + 1;
          });
          await Provider.of<LoadFeed>(context, listen: false)
              .likepost(widget.reelobj.postid, widget.reelobj.userid);
        }
      },
      child: Container(
          alignment: Alignment.bottomCenter,
          height: MediaQuery.of(context).size.height * 0.83,
          width: double.infinity,
          child: Stack(children: [
            Container(
              alignment: Alignment.center,
              child:
                  videoplayer != null && videoplayer.value.isInitialized == true
                      ? AspectRatio(
                          aspectRatio: videoplayer.value.aspectRatio,
                          child: VideoPlayer(videoplayer))
                      : CircularProgressIndicator(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  CircleAvatar(
                    child: IconButton(
                        onPressed: () {
                          if (videoplayer.value.isPlaying) {
                            videoplayer.pause();
                          } else {
                            videoplayer.play();
                          }
                        },
                        icon: Icon(videoplayer.value.isPlaying == true
                            ? Icons.pause
                            : Icons.play_arrow)),
                  ),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Column(children: [
                    IconButton(
                      onPressed: () async {
                        if (widget.reelobj.liked == false) {
                          setState(() {
                            widget.reelobj.liked = true;
                            widget.reelobj.likes = widget.reelobj.likes + 1;
                          });
                          await Provider.of<LoadFeed>(context, listen: false)
                              .likepost(
                                  widget.reelobj.postid, widget.reelobj.userid);
                        } else {
                          setState(() {
                            widget.reelobj.liked = false;
                            widget.reelobj.likes = widget.reelobj.likes - 1;
                          });
                          await Provider.of<LoadFeed>(context, listen: false)
                              .dislikepost(
                                  widget.reelobj.postid, widget.reelobj.userid);
                        }
                      },
                      icon: Icon(
                        widget.reelobj.liked == false
                            ? Icons.favorite_outline
                            : Icons.favorite,
                      ),
                      color: widget.reelobj.liked == true
                          ? Colors.red
                          : Colors.black,
                    ),
                    Text(widget.reelobj.likes.toString())
                  ])
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/comments',
                            arguments: {
                              "postid": widget.reelobj.postid,
                              "userid": widget.reelobj.userid
                            });
                      },
                      icon: Icon(Icons.comment)),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () async {
                          await sharewithchat(context);
                        },
                        icon: Icon(Icons.send)),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: widget.reelobj.profilepic.length == 0
                        ? AssetImage(
                            'asset/images/profile.png',
                          )
                        : NetworkImage(widget.reelobj.profilepic),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/profile', arguments: {
                          'no': FirebaseAuth.instance.currentUser.uid ==
                                  widget.reelobj.userid
                              ? 0
                              : 1,
                          'userid': widget.reelobj.userid
                        });
                      },
                      child: Text(widget.reelobj.username)),
                ]),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Text(widget.reelobj.caption)])),
              ],
            ),
          ])),
    );
  }
}
