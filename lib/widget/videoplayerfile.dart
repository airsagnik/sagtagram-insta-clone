import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Videoplayback extends StatefulWidget {
  VideoPlayerController videoplayer;
  Videoplayback(this.videoplayer);
  @override
  _VideoplaybackState createState() => _VideoplaybackState();
}

class _VideoplaybackState extends State<Videoplayback> {
  @override
  Widget build(BuildContext context) {
    return widget.videoplayer != null && widget.videoplayer.value.isInitialized
        ? Stack(children: [
            AspectRatio(
                aspectRatio: widget.videoplayer.value.aspectRatio,
                child: VideoPlayer(widget.videoplayer)),
            Positioned.fill(
                child: Stack(children: [
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(widget.videoplayer,
                      allowScrubbing: true))
            ])),
          ])
        : Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
  }
}
