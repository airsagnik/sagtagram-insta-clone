import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:sagtagram/providers/postupload.dart';
import 'package:sagtagram/widget/videoplayerfile.dart';
import 'package:video_player/video_player.dart';

class UploadPost extends StatefulWidget {
  @override
  _UploadPostState createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  List<String> category = [
    "IGTV",
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

  String catselected = "Travel";
  String postopted = "photo";
  File imagereq;
  final formkey = GlobalKey<FormState>();
  bool isuploading = false;
  String caption = "";
  String location = "";
  VideoPlayerController videoplayer;
  bool isvideo = false;

  @override
  void dispose() {
    super.dispose();
    videoplayer.dispose();
  }

  Future<void> uploadpost() async {
    formkey.currentState.save();
    if (imagereq == null) {
      return;
    }
    if (isvideo == true) {
      if (videoplayer.value.duration.inSeconds <= 32) {
        postopted = "reels";
      } else {
        postopted = "sgtv";
      }
    }
    print(postopted);
    setState(() {
      isuploading = true;
    });

    await Provider.of<Upload>(context, listen: false)
        .uploadpost(imagereq, caption, location, postopted, catselected);
    setState(() {
      isuploading = false;
    });
    Navigator.of(context).pop();
  }

  Future<void> selectvideo() async {
    File video;
    ImagePicker pickerobj = ImagePicker();
    var pickedimage = await pickerobj.getVideo(source: ImageSource.gallery);
    if (pickedimage == null) {
      return;
    }

    video = File(pickedimage.path);
    setState(() {
      isvideo = true;
      imagereq = video;
    });
    videoplayer = VideoPlayerController.file(imagereq)
      ..addListener(() {
        setState(() {});
      })
      ..initialize().then((value) => videoplayer.play());
  }

  Future<void> selectimage(int a) async {
    File image;
    ImagePicker pickerobj = ImagePicker();
    if (a == 1) {
      var pickedimage = await pickerobj.getImage(source: ImageSource.camera);
      if (pickedimage == null) {
        return;
      }

      image = File(pickedimage.path);
      setState(() {
        isvideo = false;
        imagereq = image;
      });
    } else {
      var pickedimage = await pickerobj.getImage(source: ImageSource.gallery);
      if (pickedimage == null) {
        return;
      }

      image = File(pickedimage.path);
      setState(() {
        isvideo = false;
        imagereq = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload"),
      ),
      body: isuploading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      color: Colors.amber,
                      height: MediaQuery.of(context).size.height * 0.30,
                      width: double.infinity,
                      child: imagereq == null
                          ? Text("No image/video selected")
                          : isvideo == true
                              ? Videoplayback(videoplayer)
                              : Image.file(imagereq),
                    ),
                    if (isvideo == true)
                      SizedBox(
                        height: 10,
                      ),
                    if (isvideo == true)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                                child: IconButton(
                              icon: Icon(videoplayer.value.volume == 0
                                  ? Icons.volume_off
                                  : Icons.volume_up),
                              onPressed: () {
                                if (videoplayer.value.volume != 0) {
                                  videoplayer.setVolume(0);
                                } else {
                                  videoplayer.setVolume(1);
                                }
                              },
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              child: Text(
                                  videoplayer.value.duration.inSeconds <= 32
                                      ? "Reels"
                                      : "SGTV"),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              child: IconButton(
                                icon: Icon(videoplayer.value.isPlaying == true
                                    ? Icons.pause
                                    : Icons.play_arrow),
                                onPressed: () {
                                  if (videoplayer.value.isPlaying == true) {
                                    videoplayer.pause();
                                  } else {
                                    videoplayer.play();
                                  }
                                },
                              ),
                            ),
                          ]),
                    SizedBox(
                      height: 10,
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
                              await selectimage(1);
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
                              await selectvideo();
                            },
                            child: Text("Select Video"),
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
                              await selectimage(0);
                            },
                            child: Text("Galary"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
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
                            caption = val;
                          },
                          maxLines: 5,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              fillColor: Color.fromRGBO(235, 217, 217, 1),
                              hintText: "Caption",
                              labelText: "Write your caption",
                              hintStyle: TextStyle(fontSize: 20),
                              labelStyle: TextStyle(fontSize: 28)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
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
                            location = val;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              fillColor: Color.fromRGBO(235, 217, 217, 1),
                              hintText: "Location",
                              labelText: "Locate Yourself",
                              hintStyle: TextStyle(fontSize: 20),
                              labelStyle: TextStyle(fontSize: 28)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            child: Text("Select Category"),
                          ),
                          DropdownButton<String>(
                            value: catselected,
                            items: category.map((e) {
                              return DropdownMenuItem<String>(
                                  value: e, child: Text(e));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                catselected = value;
                              });
                            },
                          ),
                        ]),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.blue),
                      width: MediaQuery.of(context).size.width * 0.40,
                      height: MediaQuery.of(context).size.height * 0.08,
                      child: MaterialButton(
                        onPressed: uploadpost,
                        child: Text("Upload"),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
