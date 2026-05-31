import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoLoop extends StatefulWidget {
  final String videoPath;
  const VideoLoop({super.key,
  required this.videoPath,
  });

  @override
  State<VideoLoop> createState() => _VideoLoopState();
}

class _VideoLoopState extends State<VideoLoop> {

  late VideoPlayerController _controller;

  @override
  void initState(){
    super.initState();

  _controller = VideoPlayerController.asset(
    widget.videoPath,
  )
  ..initialize().then((_){
    _controller.setLooping(true);
    _controller.setVolume(0);
    _controller.play();

    if(mounted){
      setState((){});
    }
  });
  }

//   @override
// void initState() {
//   super.initState();

//   print("Iniciando vídeo...");

//   _controller = VideoPlayerController.asset(widget.videoPath);

//   Future(() async {
//     try {
//       await _controller.initialize();

//       print("VIDEO INICIALIZADO");
//       print("Duração: ${_controller.value.duration}");
//       print("Tamanho: ${_controller.value.size}");

//       await _controller.setLooping(true);
//       await _controller.play();

//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e, s) {
//       print("ERRO AO INICIALIZAR VIDEO:");
//       print(e);
//       print(s);
//     }
//   });
// }
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    if(!_controller.value.isInitialized){
       return const SizedBox();
      //  return const Center(
      // child: CircularProgressIndicator(),);
    }
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(12),
      child:FittedBox(
        fit:BoxFit.cover,
        child:SizedBox(
          width:_controller.value.size.width,
          height:_controller.value.size.height,
          child:IgnorePointer(
            child:VideoPlayer(_controller),
          )
        )
      )
    );
  }
}