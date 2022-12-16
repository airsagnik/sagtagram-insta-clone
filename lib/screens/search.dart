import 'package:flutter/material.dart';
import 'package:sagtagram/providers/userauthentication.dart';
import 'package:sagtagram/widget/bottombar.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  void didChangeDependencies() {
    bringusers();
    super.didChangeDependencies();
  }

  List<Users> lst = [];

  var loading = false;

  Future<void> bringusers() async {
    setState(() {
      loading = true;
    });
    lst = await Provider.of<UserAuth>(context, listen: false)
        .bringusersforseach();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> category = [
      "SGTV",
      "Travel",
      "Architecture",
      "Decor",
      "Style",
      "Art",
      "Food",
      "Beauty",
      "DIY",
      "Sports",
      "MusicTv"
    ];

    List<String> catphoto = [
      "asset/images/igtv2.png",
      "asset/images/travel1.gif",
      "asset/images/archeitecture.gif",
      "asset/images/decor.gif",
      "asset/images/style.gif",
      "asset/images/art.gif",
      "asset/images/food.gif",
      "asset/images/beauty.gif",
      "asset/images/diy.gif",
      "asset/images/sports.png",
      "asset/images/musictv.png",
    ];
    return Scaffold(
      bottomNavigationBar: BottomnavBar(1),
      appBar: AppBar(
        title: Text("Explore"),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSeach(lst));
              })
        ],
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.80,
              child: GridView.builder(
                  itemCount: 11,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 2 / 2,
                      crossAxisSpacing: 5,
                      maxCrossAxisExtent: 250),
                  itemBuilder: (ctx, i) => GestureDetector(
                        onTap: () {
                          print(category[i]);
                          Navigator.of(context).pushNamed('/explorefeed',
                              arguments: category[i]);
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.35,
                            height: MediaQuery.of(context).size.height * 0.35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: Column(children: [
                              Expanded(
                                child: Container(
                                    child: Image.asset(catphoto[i],
                                        fit: BoxFit.contain)),
                              ),
                              Text(category[i])
                            ])),
                      )),
            ),
    );
  }
}

class DataSeach extends SearchDelegate<String> {
  List<Users> lst = [];
  DataSeach(this.lst);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Users> uselist = [];
    uselist = query.isEmpty
        ? lst
        : lst.where((element) => element.username.startsWith(query)).toList();
    return ListView.builder(
        itemCount: uselist.length,
        itemBuilder: (ctx, i) => ListTile(
              onTap: () {
                Navigator.of(context).pushNamed('/profile',
                    arguments: {'no': 1, 'userid': uselist[i].userid});
              },
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: uselist[i].profilepic.length == 0
                    ? AssetImage(
                        'asset/images/profile.png',
                      )
                    : NetworkImage(uselist[i].profilepic),
              ),
              title: Text(uselist[i].fullname),
              subtitle: Text(uselist[i].username),
            ));
    throw UnimplementedError();
  }
}
