import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sagtagram/models/activitymodel.dart';

class LikesNotify extends StatelessWidget {
  Activityload obj;
  LikesNotify(this.obj);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        String userid = obj.comment == true && obj.likes == true
            ? obj.postuserid
            : FirebaseAuth.instance.currentUser.uid;
        print(obj.postid);
        Navigator.of(context).pushNamed('/activitypostd',
            arguments: {"postid": obj.postid, "userid": userid});
      },
      child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Card(
              child: Column(children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: obj.profilepicurl.length == 0
                      ? AssetImage(
                          'asset/images/profile.png',
                        )
                      : NetworkImage(obj.profilepicurl),
                  radius: 30,
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.10,
                  width: MediaQuery.of(context).size.width * 0.70,
                  child: FittedBox(
                    child: Text(
                      obj.comment == false && obj.likes == true
                          ? '${obj.username}  likes your post'
                          : obj.comment == true && obj.likes == false
                              ? '${obj.username}  commented on your post'
                              : '${obj.username} likes your comment',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ]))),
    );
  }
}
