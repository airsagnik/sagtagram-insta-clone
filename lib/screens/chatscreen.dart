import 'package:flutter/material.dart';
import 'package:sagtagram/models/chatroomstructure.dart';
import '../models/user.dart';
import '../providers/userauthentication.dart';
import 'package:provider/provider.dart';
import '../providers/chatsproviders.dart';

class Sagtachat extends StatefulWidget {
  @override
  _SagtachatState createState() => _SagtachatState();
}

class _SagtachatState extends State<Sagtachat> {
  @override
  void didChangeDependencies() {
    bringusers();
    super.didChangeDependencies();
  }

  List<Chatroom> chats = [];
  List<Users> lst = [];

  var loading = false;

  Future<void> bringusers() async {
    setState(() {
      loading = true;
    });
    lst = await Provider.of<UserAuth>(context, listen: false)
        .bringusersforseach();
    chats = await Provider.of<ChatsProvider>(context, listen: false)
        .loadchatrooms();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: DataSeach(lst));
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (ctx, i) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/chatroom', arguments: chats[i]);
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: chats[i].obj.profilepic.length == 0
                        ? AssetImage('asset/images/profile.png')
                        : NetworkImage(chats[i].obj.profilepic),
                  ),
                  title: Text(chats[i].obj.username),
                  subtitle: Text(chats[i].obj.fullname),
                );
              },
              itemCount: chats.length,
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
              onTap: () async {
                var chatroomid =
                    await Provider.of<ChatsProvider>(context, listen: false)
                        .findchatroom(uselist[i].userid);
                Chatroom obj = Chatroom(id: chatroomid, obj: uselist[i]);
                Navigator.of(context).pushNamed('/chatroom', arguments: obj);
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
