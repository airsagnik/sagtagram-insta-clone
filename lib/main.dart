import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sagtagram/providers/loadfeeds.dart';
import 'package:sagtagram/providers/postupload.dart';
import 'package:sagtagram/providers/reelsprovider.dart';
import 'package:sagtagram/providers/userauthentication.dart';
import 'package:sagtagram/screens/activity.dart';
import 'package:sagtagram/screens/activitypostshow.dart';
import 'package:sagtagram/screens/chatroomscreen.dart';
import 'package:sagtagram/screens/chatscreen.dart';
import 'package:sagtagram/screens/displayscreen.dart';
import 'package:sagtagram/screens/editprofile.dart';
import 'package:sagtagram/screens/explorefeed.dart';
import 'package:sagtagram/screens/feed.dart';
import 'package:sagtagram/screens/followerview.dart';
import 'package:sagtagram/screens/likesdisplay.dart';
import 'package:sagtagram/screens/login.dart';
import 'package:sagtagram/screens/otppage.dart';
import 'package:sagtagram/screens/postuload.dart';
import 'package:sagtagram/screens/profile.dart';
import 'package:sagtagram/screens/reels.dart';
import 'package:sagtagram/screens/search.dart';
import 'package:sagtagram/screens/pageone.dart';
import 'package:sagtagram/screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './theme/themeapp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './providers/activityprovider.dart';
import './screens/likelist.dart';
import './screens/comments.dart';
import './providers/loadcomments.dart';
import './providers/chatsproviders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

ThemeData a = ThemeData.light();
bool darktheme;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void reloadtheme(bool val) {
    setState(() {
      darktheme = val;
    });
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  Future<void> setup() async {
    print("checking theme");
    var pre = await SharedPreferences.getInstance();
    if (pre.containsKey('dark') == false) {
      await pre.setBool("dark", false);
      darktheme = false;
    } else {
      darktheme = pre.getBool('dark');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Reelsprovider()),
        ChangeNotifierProvider(create: (ctx) => ChatsProvider()),
        ChangeNotifierProvider(create: (ctx) => LoadComments()),
        ChangeNotifierProvider(create: (ctx) => Activityfeed()),
        ChangeNotifierProvider(create: (ctx) => Upload()),
        ChangeNotifierProvider(create: (ctx) => LoadFeed()),
        ChangeNotifierProvider(
            create: (
          ctx,
        ) =>
                UserAuth()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: playtheme(reloadtheme, darktheme),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, obj) {
              if (obj.hasData) {
                print("Hullo");
                return FeedPage();
              } else {
                return PageOne();
              }
            }), //PageOne(),
        routes: {
          '/explorefeed': (ctx) => Explorefeed(),
          '/uploadpost': (ctx) => UploadPost(),
          '/pageone': (ctx) => PageOne(),
          '/otppage': (ctx) => OtpPage(),
          '/signup': (ctx) => Signup(),
          '/login': (ctx) => Login(),
          '/feed': (ctx) => FeedPage(),
          '/profile': (ctx) => ProfilePage(),
          '/explore': (ctx) => Search(),
          '/reels': (ctx) => ReelsPage(),
          '/activity': (ctx) => Activity(),
          '/editprofile': (ctx) => EditProfile(),
          '/likesview': (ctx) => LikesPage(),
          '/comments': (ctx) => Commentdisplay(),
          '/sagtachat': (ctx) => Sagtachat(),
          '/chatroom': (ctx) => ChatroomScreen(),
          '/followerview': (ctx) => Followerview(),
          '/display': (ctx) => Display(),
          '/activitypostd': (ctx) => Activitypost(),
        },
      ),
    );
  }
}

/*class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.fun}) : super(key: key);
  final String title;
  Function fun;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool val = false;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Switch(
              value: darktheme,
              onChanged: (bool f) {
                if (f == true) {
                  setState(() {});
                  print("On");
                  widget.fun(f);
                } else {
                  setState(() {});
                  print("Of");
                  widget.fun(f);
                }
              }),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}*/
