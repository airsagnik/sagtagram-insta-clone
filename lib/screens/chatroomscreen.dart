import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sagtagram/models/chatroomstructure.dart';
import 'package:sagtagram/providers/chatsproviders.dart';
import 'package:provider/provider.dart';

class ChatroomScreen extends StatefulWidget {
  @override
  _ChatroomScreenState createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  Chatroom obj;
  TextEditingController txt = TextEditingController();
  String text;
  String chatroomid;

  AppBar ab;

  @override
  void didChangeDependencies() {
    obj = ModalRoute.of(context).settings.arguments as Chatroom;
    ab = AppBar(
      leadingWidth: 20,
      title: Container(
          child: Row(children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: obj.obj.profilepic.length == 0
              ? AssetImage('asset/images/profile.png')
              : NetworkImage(obj.obj.profilepic),
        ),
        SizedBox(
          width: 10,
        ),
        Text(obj.obj.username)
      ])),
    );
    super.didChangeDependencies();
  }

  Future<void> sendtext() async {
    await Provider.of<ChatsProvider>(context, listen: false)
        .sendmessage(obj.id, text, obj.obj.userid, null);
  }

  Future<void> sendfirsttext() async {
    chatroomid = await Provider.of<ChatsProvider>(context, listen: false)
        .createnewchatroom(obj.obj.userid, text);
    if (obj.id == null) {
      setState(() {
        obj.id = chatroomid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ab,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  color: Colors.blue,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height -
                      ab.preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).size.height * 0.08,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(obj.id)
                        .collection('messages')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        var v = snapshot.data.docs;
                        print(v);
                        print(obj.id);
                        return ListView.builder(
                            reverse: true,
                            itemCount: v.length,
                            itemBuilder: (ctx, i) => Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                      mainAxisAlignment: v[i]["senderid"] ==
                                              FirebaseAuth
                                                  .instance.currentUser.uid
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(20),
                                                  bottomLeft:
                                                      Radius.circular(20)),
                                              color: v[i]["senderid"] ==
                                                      FirebaseAuth.instance
                                                          .currentUser.uid
                                                  ? Colors.amber
                                                  : Colors.yellow,
                                            ),
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.80),
                                            child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: v[i]["text"] == null
                                                    ? v[i]["sharedpost"]
                                                                ["type"] !=
                                                            "photo"
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      '/activitypostd',
                                                                      arguments: {
                                                                    "postid": v[i]
                                                                            [
                                                                            "sharedpost"]
                                                                        [
                                                                        "postid"],
                                                                    "userid": v[i]
                                                                            [
                                                                            "sharedpost"]
                                                                        [
                                                                        "userid"]
                                                                  });
                                                            },
                                                            child: Image.network(
                                                                'https://cdn.smehost.net/dailyrindblogcom-orchardprod/wp-content/uploads/2020/08/InstagramReels_Banner-scaled.jpg',
                                                                fit: BoxFit
                                                                    .cover),
                                                          )
                                                        : GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      '/activitypostd',
                                                                      arguments: {
                                                                    "postid": v[i]
                                                                            [
                                                                            "sharedpost"]
                                                                        [
                                                                        "postid"],
                                                                    "userid": v[i]
                                                                            [
                                                                            "sharedpost"]
                                                                        [
                                                                        "userid"]
                                                                  });
                                                            },
                                                            child:
                                                                Image.network(
                                                              v[i]["sharedpost"]
                                                                  ["imageurl"],
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                    : Text(
                                                        v[i]["text"],
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ))),
                                      ]),
                                ));
                      }
                    },
                  )),
              Padding(
                padding: EdgeInsets.all(1),
                child: Row(children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.82,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: TextField(
                      onSubmitted: (val) {
                        text = val;
                        print(text);
                        //txt.clear();
                      },
                      controller: txt,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        child: IconButton(
                      icon: Icon(Icons.send),
                      //height: MediaQuery.of(context).size.height * 0.08,
                      color: Colors.green,
                      //shape: CircleBorder(),
                      onPressed: () async {
                        if (txt.text.length != 0) {
                          text = txt.text;
                          if (obj.id == null) {
                            await sendfirsttext();
                          } else {
                            await sendtext();
                          }
                          print(text);
                          txt.clear();
                        }
                      },
                      //child: Icon(Icons.send)
                    )),
                  )
                ]),
              )
            ],
          ),
        ));
  }
}
