import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomnavBar extends StatefulWidget {
  final int a;
  BottomnavBar(this.a);

  @override
  _BottomnavBarState createState() => _BottomnavBarState();
}

class _BottomnavBarState extends State<BottomnavBar> {
  void change(int val) {
    if (val == 0) {
      Navigator.of(context).pushReplacementNamed('/feed');
    } else if (val == 1) {
      Navigator.of(context).pushReplacementNamed('/explore');
    } else if (val == 4) {
      Navigator.of(context).pushReplacementNamed('/profile', arguments: {
        'no': 0,
        'userid': FirebaseAuth.instance.currentUser.uid
      });
    } else if (val == 2) {
      Navigator.of(context).pushReplacementNamed('/reels');
    } else if (val == 3) {
      Navigator.of(context).pushReplacementNamed('/activity');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (int val) {
        change(val);
      },
      backgroundColor: Colors.black,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.black,
      selectedFontSize: 20,
      unselectedFontSize: 15,
      currentIndex: widget.a,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "Reels"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "activity"),
        BottomNavigationBarItem(icon: Icon(Icons.portrait), label: "Profile")
      ],
    );
  }
}
