import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import 'package:sagtagram/screens/signup.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/providers/userauthentication.dart';
import 'dart:async';

class OtpPage extends StatefulWidget {
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String password;
  String str = "";
  Timer timer;
  int count = 60;

  bool buttonon = false;

  void starttimer() {
    setState(() {
      buttonon = false;
    });
    count = 60;
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      print("counting");
      setState(() {
        count--;
        if (count <= 0) {
          print("Hello");
          timer.cancel();
        }
      });
    });
    setState(() {
      buttonon = true;
    });
  }

  @override
  initState() {
    print("hello");
    starttimer();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> verifyotp(String email, String password, String username,
      String fullname, BuildContext ctx) async {
    var res = EmailAuth.validate(receiverMail: email, userOTP: txt.text);
    if (res == true) {
      timer.cancel();
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(
              "Email Verified! Please wait while we set up your account!")));

      await Provider.of<UserAuth>(ctx, listen: false)
          .userauthentication(fullname, password, username, email, false)
          .then((value) => Navigator.of(ctx).popAndPushNamed("/feed"))
          .catchError((val) {
        onerror(val);
      });
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text("OTP is not correct! Please re-enter OTP")));
    }
  }

  void onerror(val) {
    var data;

    if (val == FirebaseException) {
      data = val.message();
    }
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Text(data != null
                  ? data
                  : "Some error occured! Check internet connection or use a different mail"),
              title: Text("Error!"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("Okay"))
              ],
            ));
  }

  Future<void> sendotpagain(String email, BuildContext ctx) async {
    EmailAuth.sessionName = "TestSession";
    bool m = await EmailAuth.sendOtp(receiverMail: email);
    if (m == true) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(SnackBar(content: Text("OTP has been sent again!")));
    }
  }

  TextEditingController txt = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var obj = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    var email = obj["email"];
    var password = obj["password"];
    var username = obj["username"];
    var fullname = obj["fullname"];
    str = "We have sent you an OTP in $email";
    print(username);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(210, 161, 161, 1),
        body: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.95,
          width: double.infinity,
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.32,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('asset/images/otp.png')),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color.fromRGBO(235, 217, 217, 1),
                  ),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "   We have sent an otp in \n $email",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(235, 217, 217, 1),
                        borderRadius: BorderRadius.circular(20)),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: TextField(
                        controller: txt,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            labelText: "OTP",
                            hintText: "Enter OTP",
                            hintStyle: TextStyle(fontSize: 20),
                            labelStyle: TextStyle(fontSize: 28)),
                      ),
                    )),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  focusElevation: 0,
                  elevation: 10,
                  onPressed: () async {
                    await verifyotp(
                        email, password, username, fullname, context);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Color.fromRGBO(34, 67, 117, 1),
                  splashColor: Colors.red,
                  child: Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: Text("Veryfy otp",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                          focusElevation: 0,
                          elevation: 10,
                          onPressed: count <= 0
                              ? () {
                                  starttimer();
                                  sendotpagain(email, context);
                                }
                              : () {},
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: count <= 0
                              ? Color.fromRGBO(34, 67, 117, 1)
                              : Colors.grey,
                          splashColor: Colors.red,
                          child: Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.width * 0.60,
                            child: Text("Resend otp",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                        ),
                        if (count >= 0)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  count.toString(),
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                            ),
                          ),
                      ]),
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Colors.black,
                  thickness: 5,
                ),
                MaterialButton(
                  focusElevation: 0,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  splashColor: Colors.red,
                  color: Color.fromRGBO(34, 67, 117, 1),
                  onPressed: () {
                    timer.cancel();
                    Navigator.of(context).pushReplacementNamed('/signup');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: Text(
                      "Cancel and Re-signup",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
