import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagtagram/providers/userauthentication.dart';
import 'package:email_auth/email_auth.dart';

class Userdetails {
  String email;
  String password;
  String username;
  String fullname;
  Userdetails({this.email, this.fullname, this.password, this.username});
}

class Signup extends StatelessWidget {
  String email;
  String password;
  String username;
  String fullname;
  TextEditingController pass = TextEditingController();
  TextEditingController verpass = TextEditingController();

  final formkey = GlobalKey<FormState>();
  void getdetails(BuildContext ctx) async {
    bool valid = formkey.currentState.validate();

    if (valid == true) {
      formkey.currentState.save();
      if (email == null ||
          password == null ||
          username == null ||
          fullname == null) {
        return;
      }
      print(email);
      print(password);
      print(username);
      EmailAuth.sessionName = "TestSession";
      bool k = await EmailAuth.sendOtp(receiverMail: email);

      Userdetails obj = Userdetails(
          email: email,
          password: password,
          fullname: fullname,
          username: username);

      if (k == true)
        Navigator.of(ctx).pushReplacementNamed('/otppage', arguments: {
          "email": email,
          "password": password,
          "fullname": fullname,
          "username": username,
        });
      //await Provider.of<UserAuth>(ctx, listen: false)
      //.userauthentication(fullname, password, username, email, false)
      //.then((value) => Navigator.of(ctx).popAndPushNamed("/feed"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(210, 161, 161, 1),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: SingleChildScrollView(
            reverse: false,
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('asset/images/signup.png')),
                      )),
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromRGBO(235, 217, 217, 1),
                    ),
                    //height: MediaQuery.of(context).size.height * 0.10,
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
                            return "Enter a valid email";
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
                    //height: MediaQuery.of(context).size.height * 0.10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromRGBO(235, 217, 217, 1),
                    ),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: TextFormField(
                        onSaved: (val) {
                          username = val;
                        },
                        validator: (val) {
                          if (val.isEmpty) {
                            return "This is required";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            fillColor: Color.fromRGBO(235, 217, 217, 1),
                            hintText: "User Name",
                            labelText: "Select Username",
                            hintStyle: TextStyle(fontSize: 20),
                            labelStyle: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      //height: MediaQuery.of(context).size.height * 0.10,
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
                          controller: pass,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "A password is required";
                            } else if (val.length < 6) {
                              return "Min length: 6";
                            } else {
                              return null;
                            }
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
                  SizedBox(height: 20),
                  Container(
                      //height: MediaQuery.of(context).size.height * 0.10,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(235, 217, 217, 1),
                          borderRadius: BorderRadius.circular(20)),
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          controller: verpass,
                          validator: (val) {
                            if (val == pass.text) {
                              return null;
                            } else {
                              return "Password must match";
                            }
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              labelText: "Confirm password",
                              hintText: "Re-enter password",
                              hintStyle: TextStyle(fontSize: 20),
                              labelStyle: TextStyle(fontSize: 28)),
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      //height: MediaQuery.of(context).size.height * 0.10,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(235, 217, 217, 1),
                          borderRadius: BorderRadius.circular(20)),
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          onSaved: (val) {
                            fullname = val;
                          },
                          validator: (val) {
                            if (val.isEmpty) {
                              return "This field is required";
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              labelText: " Full Name",
                              hintText: "Enter your name",
                              hintStyle: TextStyle(fontSize: 20),
                              labelStyle: TextStyle(fontSize: 28)),
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(235, 217, 217, 1),
                          borderRadius: BorderRadius.circular(20)),
                      width: MediaQuery.of(context).size.width * 0.50,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              labelText: "OTP",
                              hintText: "Enter OTP",
                              hintStyle: TextStyle(fontSize: 20),
                              labelStyle: TextStyle(fontSize: 28)),
                        ),
                      )),
                    SizedBox(width: 20,),
                    Column(
                      children: [MaterialButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Text("Verify otp",style: TextStyle(color: Colors.white, fontSize: 20)),
                        onPressed: (){},
                      ),
                      MaterialButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Text("Resend",style: TextStyle(color: Colors.white, fontSize: 20)),
                        onPressed: (){}),
                      ])
                  ],),
                  SizedBox(
                    height: 20,
                  ),*/
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
                      child: Text("Sign up",
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
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: Text(
                        "Have an account! Log in",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
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
