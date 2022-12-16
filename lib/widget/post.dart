import 'package:flutter/material.dart';
import 'package:sagtagram/models/postclass.dart';
import 'package:sagtagram/providers/loadfeeds.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/theme/themeapp.dart';
import 'package:sagtagram/widget/sendpost.dart';
import 'package:sagtagram/widget/videoplayerfile.dart';
import 'package:video_player/video_player.dart';
import '../models/chatroomstructure.dart';
import '../providers/chatsproviders.dart';

class PostCard extends StatefulWidget {
  Post obj;
  PostCard(this.obj);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController videoplay;
  void initState() {
    super.initState();
    if (widget.obj.postype != "photo") {
      videoplay = VideoPlayerController.network(widget.obj.imageurl)
        ..addListener(() {
          setState(() {});
        })
        ..initialize();
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
              return SendPost(chats[i], widget.obj);
            }));
  }

  @override
  void dispose() {
    super.dispose();
    if (videoplay != null) {
      videoplay.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.obj.postype != 'photo') {
          if (videoplay.value.volume != 0) {
            videoplay.setVolume(0);
          } else {
            videoplay.setVolume(1);
          }
        }
      },
      onDoubleTap: () async {
        if (widget.obj.liked == false) {
          setState(() {
            widget.obj.liked = true;
            widget.obj.likes = widget.obj.likes + 1;
          });
          await Provider.of<LoadFeed>(context, listen: false)
              .likepost(widget.obj.postid, widget.obj.userid);
        }
      },
      child: Container(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: widget.obj.profilepic.length == 0
                    ? AssetImage(
                        'asset/images/profile.png',
                      )
                    : NetworkImage(widget.obj.profilepic),
              ),
              title: Text(widget.obj.username),
              onTap: () {
                Navigator.of(context).pushNamed('/profile',
                    arguments: {'no': 1, 'userid': widget.obj.userid});
              },
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              constraints: widget.obj.postype == 'photo'
                  ? null
                  : BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.60),
              child:
                  widget.obj.postype == "reels" || widget.obj.postype == 'sgtv'
                      ? AspectRatio(
                          aspectRatio: videoplay.value.aspectRatio,
                          child: Videoplayback(videoplay))
                      : Image.network(
                          widget.obj.imageurl,
                          fit: BoxFit.fill,
                        ),
            ),
            if (widget.obj.postype != "photo")
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      child: IconButton(
                        onPressed: () {
                          if (videoplay.value.isPlaying == true) {
                            videoplay.pause();
                          } else {
                            videoplay.play();
                          }
                        },
                        icon: videoplay.value.isPlaying == true
                            ? Icon(Icons.pause)
                            : Icon(Icons.play_arrow),
                      ),
                    )
                  ],
                ),
              ),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/likesview', arguments: widget.obj.postid);
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text(
                      "Likes",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(widget.obj.likes.toString(),
                        style: TextStyle(fontSize: 20))
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                    icon: Icon(
                      widget.obj.liked == true
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color:
                          widget.obj.liked == true ? Colors.red : Colors.black,
                    ),
                    onPressed: () async {
                      if (widget.obj.liked == false) {
                        setState(() {
                          widget.obj.liked = true;
                          widget.obj.likes = widget.obj.likes + 1;
                        });
                        await Provider.of<LoadFeed>(context, listen: false)
                            .likepost(widget.obj.postid, widget.obj.userid);
                      } else {
                        setState(() {
                          widget.obj.liked = false;
                          widget.obj.likes = widget.obj.likes - 1;
                        });
                        await Provider.of<LoadFeed>(context, listen: false)
                            .dislikepost(widget.obj.postid, widget.obj.userid);
                      }
                    }),
                IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/comments', arguments: {
                        "postid": widget.obj.postid,
                        "userid": widget.obj.userid
                      });
                    }),
                IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () async {
                      await sharewithchat(context);
                    })
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.all(5), child: Text(widget.obj.caption)),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
