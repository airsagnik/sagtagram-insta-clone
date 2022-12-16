import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sagtagram/providers/userauthentication.dart';
import '../models/user.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  @override
  EditProfile_State createState() => EditProfile_State();
}

class EditProfile_State extends State<EditProfile> {
  var formkey = GlobalKey<FormState>();
  File imageprofile;
  String name;
  String username;
  String bio;
  bool loading;

  bool private = false;

  void getdata() {
    formkey.currentState.validate();
    formkey.currentState.save();
  }

  Future<void> delimage() async {
    await Provider.of<UserAuth>(context, listen: false).removeimage();
  }

  Future<void> changeprofiledata(String url) async {
    setState(() {
      loading = true;
    });
    await Provider.of<UserAuth>(context, listen: false).updateprofileinfo(
        bio: bio,
        image: imageprofile,
        username: username,
        name: name,
        url: url);
    setState(() {
      loading = false;
    });
  }

  Future<void> setprofileimage(int a) async {
    ImagePicker img = ImagePicker();
    if (a == 1) {
      var image = await img.getImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }
      setState(() {
        imageprofile = File(image.path);
      });
    } else {
      var image = await img.getImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      setState(() {
        imageprofile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Users userinfo = ModalRoute.of(context).settings.arguments as Users;
    private = userinfo.private;
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit profile"),
          actions: [
            IconButton(
                onPressed: () async {
                  getdata();
                  await changeprofiledata(userinfo.profilepic);
                },
                icon: Icon(Icons.check))
          ],
        ),
        body: loading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                height: MediaQuery.of(context).size.height * 0.95,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: imageprofile == null
                              ? userinfo.profilepic.length == 0
                                  ? AssetImage(
                                      'asset/images/profile.png',
                                    )
                                  : NetworkImage(userinfo.profilepic)
                              : FileImage(imageprofile),
                          radius: 100,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue),
                              width: MediaQuery.of(context).size.width * 0.30,
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: MaterialButton(
                                onPressed: () async {
                                  await setprofileimage(1);
                                },
                                child: Text("Camera"),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue),
                              width: MediaQuery.of(context).size.width * 0.30,
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: MaterialButton(
                                onPressed: () async {
                                  await setprofileimage(0);
                                },
                                child: Text("Galary"),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue),
                              width: MediaQuery.of(context).size.width * 0.30,
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: MaterialButton(
                                onPressed: () async {
                                  await delimage();
                                  setState(() {
                                    userinfo.profilepic = "";
                                  });
                                },
                                child: Text("Remove"),
                              ),
                            ),
                          ],
                        ),
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
                                name = val;
                              },
                              validator: (val) {
                                if (val == null) {
                                  return "This is required";
                                } else {
                                  return null;
                                }
                              },
                              initialValue: userinfo.fullname,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  fillColor: Color.fromRGBO(235, 217, 217, 1),
                                  hintText: "Name",
                                  labelText: "Name",
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
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromRGBO(235, 217, 217, 1),
                          ),
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: TextFormField(
                              onSaved: (val) {
                                bio = val;
                              },
                              initialValue: userinfo.bio,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  fillColor: Color.fromRGBO(235, 217, 217, 1),
                                  hintText: "Bio",
                                  labelText: "Edit Bio",
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
                                if (val == null) {
                                  return "This is required";
                                } else {
                                  return null;
                                }
                              },
                              initialValue: userinfo.username,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  fillColor: Color.fromRGBO(235, 217, 217, 1),
                                  hintText: "Username",
                                  labelText: "Username",
                                  hintStyle: TextStyle(fontSize: 20),
                                  labelStyle: TextStyle(fontSize: 28)),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Public"),
                            Switch(
                                value: private,
                                onChanged: (value) {
                                  showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  child: Text("Yes")),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text("No"))
                                            ],
                                            title:
                                                Text("Account status change"),
                                            content: Text(private == true
                                                ? 'Do you want to change acc status to public'
                                                : 'Do you want to change your account status to private?'),
                                          )).then((value) async {
                                    if (value == true) {
                                      await FirebaseFirestore.instance
                                          .collection('user')
                                          .doc(FirebaseAuth
                                              .instance.currentUser.uid)
                                          .update({"private": !private});
                                      setState(() {
                                        private = !private;
                                        userinfo.private = private;
                                      });
                                    }
                                  });
                                }),
                            Text("Private"),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
