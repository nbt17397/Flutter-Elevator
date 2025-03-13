// import 'package:elevator/app/data/response/location_response.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';

// class ScadaElevatorScreen extends StatefulWidget {
//   final BoardDB board;
//   const ScadaElevatorScreen({super.key, required this.board});

//   @override
//   State<ScadaElevatorScreen> createState() => _ScadaElevatorScreenState();
// }

// class _ScadaElevatorScreenState extends State<ScadaElevatorScreen> {
//   late VlcPlayerController _vlcController;
//   bool _isStreaming = false;
//   String ipCameraUrl = 'rtsp://mpvss1.sanookhd.com:1935/live/11.stream';

//   @override
//   void initState() {
//     super.initState();
//     _vlcController = VlcPlayerController.network(
//       ipCameraUrl, // URL RTSP hoặc HTTP của camera
//       autoPlay: true, // Chưa phát khi vào
//       options: VlcPlayerOptions(),
//     );
//   }

//   @override
//   void dispose() {
//     _vlcController.stop();
//     _vlcController.dispose();
//     super.dispose();
//   }

//   void _toggleStream() {
//     setState(() {
//       _isStreaming = !_isStreaming;
//       if (_isStreaming) {
//         _vlcController.play();
//       } else {
//         _vlcController.pause();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Camera IP Stream"),
//         backgroundColor: Colors.blue,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             VlcPlayer(
//               controller: _vlcController,
//               aspectRatio: 16 / 9,
//               placeholder: const Center(child: CircularProgressIndicator()),
//             ),

//             // Nút Start/Stop Stream
//             Positioned(
//               child: GestureDetector(
//                 onTap: _toggleStream,
//                 child: Icon(
//                   _isStreaming ? Icons.stop_circle : Icons.play_circle,
//                   size: 50,
//                   color: Colors.white.withOpacity(0.8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
