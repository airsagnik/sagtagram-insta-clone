import 'package:flutter/material.dart';
import 'package:sagtagram/providers/activityprovider.dart';
import 'package:sagtagram/widget/bottombar.dart';
import 'package:sagtagram/widget/followrequest.dart';
import 'package:provider/provider.dart';
import '../models/activitymodel.dart';
import '../widget/likemessage.dart';

class Activity extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  List<Activityload> lst = [];
  bool loading = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadactivity();
  }

  Future<void> loadactivity() async {
    setState(() {
      loading = true;
    });
    lst =
        await Provider.of<Activityfeed>(context, listen: false).fetchrequest();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity"),
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: ListView.builder(
                  itemCount: lst.length,
                  itemBuilder: (ctx, i) =>
                      lst[i].likes == false && lst[i].comment == false
                          ? FollowRequest(lst[i])
                          : LikesNotify(lst[i])),
            ),
      bottomNavigationBar: BottomnavBar(3),
    );
  }
}
