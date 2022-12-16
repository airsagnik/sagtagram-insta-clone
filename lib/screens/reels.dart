import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sagtagram/models/postclass.dart';
import 'package:sagtagram/providers/reelsprovider.dart';
import 'package:sagtagram/widget/bottombar.dart' as bt;
import 'package:sagtagram/widget/reelelement.dart';
import 'package:provider/provider.dart';

class ReelsPage extends StatefulWidget {
  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  @override
  void initState() {
    super.initState();
    reelscroll.addListener(() {
      double maxextent = reelscroll.position.maxScrollExtent;
      double currentscroll = reelscroll.position.pixels;
      print(currentscroll);
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxextent - currentscroll <= delta) {
        moreels();
      }
    });
    getreels();
  }

  bool more = true;
  bool loadingmore = false;
  ScrollController reelscroll = ScrollController();

  bool isloading = false;

  List<Post> lst = [];

  Future<void> getreels() async {
    setState(() {
      isloading = true;
    });

    lst =
        await Provider.of<Reelsprovider>(context, listen: false).fetchreels(0);
    setState(() {
      isloading = false;
    });
  }

  Future<void> moreels() async {
    print("loading more again");
    if (loadingmore == true) {
      return;
    }

    if (more == false) {
      return;
    }

    loadingmore = true;

    var lst2 =
        await Provider.of<Reelsprovider>(context, listen: false).fetchreels(1);
    if (lst2.length == 0) {
      more = false;
    }
    lst2.forEach((element) {
      lst.add(element);
    });

    setState(() {
      loadingmore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isloading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(children: [
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child: ListView.builder(
                      controller: reelscroll,
                      itemCount: lst.length,
                      itemBuilder: (ctx, i) => Reelitem(lst[i])),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black54),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Reels",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]),
        bottomNavigationBar: bt.BottomnavBar(2),
      ),
    );
  }
}
