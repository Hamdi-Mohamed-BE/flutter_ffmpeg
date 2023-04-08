import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';


class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String audioUrl;

  VideoPlayerScreen({required this.videoUrl, required this.audioUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // the class will take videoUrl and audioUrl as input and will combine them using ffmpeg and play the combined video

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _combineVideoAndAudio();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  _createFolder()async{
    final folderName="Kini";
    final path= Directory("storage/emulated/0/$folderName");
    if ((await path.exists())){
      print("exist");
      return path;
    }else{
      print("not exist");
      path.create();
      return path;
    }
  }

  Future<void> _combineVideoAndAudio() async {
    log('combineVideoAndAudio');
    // this function will combine the video and audio to a temp file in the memory and then play it
    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    final String videoUrl = widget.videoUrl;
    final String audioUrl = widget.audioUrl;
    final String outputFilePath = '/path/to/output.mp4';
    final arguments = '-i $videoUrl -i $audioUrl -c:v copy -c:a aac -shortest $outputFilePath';
    _flutterFFmpeg.execute(arguments).then((rc) {
    if (rc == 0) {
      log('Video and audio combined successfully');
    } else {
      log('Error combining video and audio');
    }
  });
  }


  // getApplicationDocumentsDirectory

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Center(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  
}

void main() {
  runApp(MaterialApp(
    title: 'My App',
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Play Video'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  videoUrl: 'https://storage.googleapis.com/kini_static/exercise/21597cb0/3da0/4b35/90b6/4b7076bb77fe/138c5ab2-bf72-4cfe-ab6d-f73b85eff8ab.mp4',
                  audioUrl: 'https://storage.googleapis.com/kini_static/exercise/78debd09/3138/4abd/9536/60a5384689f3/92f795ac-ed8f-41be-8293-67a231257747.mp3',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


