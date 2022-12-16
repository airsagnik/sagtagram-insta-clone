import 'package:flutter/material.dart';
import 'package:sagtagram/models/activitymodel.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/providers/activityprovider.dart';
import '../providers/userauthentication.dart';

class FollowRequest extends StatefulWidget {
  Activityload obj;
  FollowRequest(this.obj);

  @override
  _FollowRequestState createState() => _FollowRequestState();
}

class _FollowRequestState extends State<FollowRequest> {
  String str = "follow back";
  bool flag = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/profile',
            arguments: {"no": 1, "userid": widget.obj.userid});
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Card(
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: widget.obj.profilepicurl.length == 0
                        ? AssetImage(
                            'asset/images/profile.png',
                          )
                        : NetworkImage(widget.obj.profilepicurl),
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
                        widget.obj.status == "pending"
                            ? "${widget.obj.username} sent you follow request"
                            : widget.obj.status != "decline"
                                ? "${widget.obj.username} started following you"
                                : 'You declined ${widget.obj.username}\'s request',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.obj.status == "pending")
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () async {
                        await Provider.of<Activityfeed>(context, listen: false)
                            .acceptrequest(widget.obj.userid);
                        setState(() {
                          widget.obj.status = "following";
                        });
                      },
                      child: Text("Accept"),
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text("Decline"),
                      onPressed: () async {
                        await Provider.of<Activityfeed>(context, listen: false)
                            .declinerequest(widget.obj.userid);
                        setState(() {
                          widget.obj.status = "decline";
                        });
                      },
                      color: Colors.blue,
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
