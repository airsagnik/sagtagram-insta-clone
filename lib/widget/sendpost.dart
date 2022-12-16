import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/models/chatroomstructure.dart';
import '../providers/chatsproviders.dart';
import '../models/postclass.dart';

class SendPost extends StatefulWidget {
  Chatroom obj;
  Post post;

  SendPost(this.obj, this.post);
  @override
  _SendPostState createState() => _SendPostState();
}

class _SendPostState extends State<SendPost> {
  bool issending = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: widget.obj.obj.profilepic.length == 0
              ? AssetImage(
                  'asset/images/profile.png',
                )
              : NetworkImage(widget.obj.obj.profilepic),
        ),
        title: Text(widget.obj.obj.username),
        trailing: issending == true
            ? Text("sending")
            : IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  setState(() {
                    issending = true;
                  });

                  await Provider.of<ChatsProvider>(context, listen: false)
                      .sendmessage(widget.obj.id, "", widget.obj.obj.userid,
                          widget.post);
                  setState(() {
                    issending = false;
                  });
                },
              ),
      ),
    );
  }
}
