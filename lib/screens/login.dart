import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sagtagram/providers/userauthentication.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formkey = GlobalKey<FormState>();

  String email;

  String password;

  void getdetails(BuildContext ctx) async {
    print("Hello");

    bool valid = formkey.currentState.validate();
    if (valid == true) {
      formkey.currentState.save();
      if (email == null || password == null) {
        print("NULL FOUND");
        return;
      }
      print(email);
      print(password);
      ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text("Please wait while we sign you in")));
      try {
        await Provider.of<UserAuth>(ctx, listen: false)
            .userauthentication("", password, "", email, true);
      } on FirebaseException catch (error) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  content: Text(error.message),
                  title: Text("Error!"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text("Okay"))
                  ],
                ));
        return;
      } catch (error) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  content: Text("Some error occured!"),
                  title: Text("Error!"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text("Okay"))
                  ],
                ));
        return;
      }

      Navigator.of(ctx).pushReplacementNamed('/feed');
    } else {
      print("Error occured");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(210, 161, 161, 1),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.98,
          width: double.infinity,
          child: SingleChildScrollView(
            reverse: false,
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Text(
                      "Welcome Back\nWe missed you!",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('asset/images/loginscreen.png')),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromRGBO(235, 217, 217, 1),
                    ),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        onSaved: (val) {
                          email = val;
                        },
                        validator: (val) {
                          if (val.contains('@')) {
                            return null;
                          } else {
                            return "Enter valid address";
                          }
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            fillColor: Color.fromRGBO(235, 217, 217, 1),
                            hintText: "enter email",
                            labelText: "Email",
                            hintStyle: TextStyle(fontSize: 20),
                            labelStyle: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(235, 217, 217, 1),
                          borderRadius: BorderRadius.circular(20)),
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          onSaved: (val) {
                            password = val;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              labelText: "password",
                              hintText: "Enter password",
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
                    onPressed: () {
                      getdetails(context);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Color.fromRGBO(34, 67, 117, 1),
                    splashColor: Colors.red,
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: Text("Log in",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
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
                      Navigator.of(context).pushReplacementNamed('/signup');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: Text(
                        "Dont have an account!Sign up",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
