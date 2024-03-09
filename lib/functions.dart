// import 'dart:async';
// import 'dart:io';
// import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path/path.dart' as path;

// class SpectrogramPage extends StatefulWidget {
//   @override
//   _SpectrogramPageState createState() => _SpectrogramPageState();
// }

// class _SpectrogramPageState extends State<SpectrogramPage> {
//   late String correctString = ''; // Marked as late and non-nullable

//   var recorder = FlutterAudioRecorder2('', audioFormat: AudioFormat.WAV);
//   String _responseData = ""; // Store response data
//   bool _isCorrect = false; // Flag to indicate if response matches
//   bool _isRecording = false;
//   bool _isPlaying = false;
//   String _fileName = 'test_audio.mp4';

//   Future<void> startRecording() async {
//     print('Recoreder was started======');
//     await recorder.start();
//   }

//   Future<String?> stopRecording() async {
//     var result = await recorder.stop();
//     log.log(result!.path!);
//     print('Recording was stoped & path is======== ${result.path}');
//     uploadAudio(result.path!);
//   }

//   Future<void> _startRecording() async {
//     print('Recorder was started======');
//     recorder.start();

//     // Start a timer to stop recording after 1 second
//     Timer(Duration(seconds: 1), () async {
//       if (_isRecording) {
//         await stopRecording();
//       }
//     });

//     setState(() {
//       _isRecording = true;
//     });
//   }

//   // Future<void> _stopRecording() async {
//   //   try {
//   //     await _recorder!.stopRecorder();
//   //     setState(() {
//   //       _isRecording = false;
//   //       uploadAudio();
//   //     });
//   //   } catch (e) {
//   //     print('Error while stopping recording: $e');
//   //     // Show user an error message here (e.g., snackbar)
//   //   }
//   // }

//   Future<String> getFilePath() async {
//     final directory = await getApplicationDocumentsDirectory();
//     // final root = directory+'/'+_fileName;
//     return directory.path; // Get the path
//   }

//   Future<void> uploadAudio() async {
//     try {
//       String filePath = await getFilePath();
//       // String fullPath = path.join(filePath); // Use path package for joining
//       // print(filePath);

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('http://192.168.106.253:8080/classify'),
//       );
//       request.files.add(await http.MultipartFile.fromPath('file', filePath,
//           filename: _fileName));

//       // Send request
//       var response = await request.send();

//       // Check response status and handle accordingly
//       if (response.statusCode == 200) {
//         _responseData = await response.stream.bytesToString();
//         print('Server response: $_responseData');

//         // Remove double quotes and backslashes from response
//         _responseData = _responseData.replaceAll('"', '').replaceAll('\\', '');

//         // Check if trimmed response matches expected string
//         _isCorrect = _responseData.trim() == correctString.trim();
//       } else {
//         print('Failed to upload audio file. Error: ${response.reasonPhrase}');
//         _responseData = "Upload failed"; // Set error message
//         print(response.statusCode);
//         _isCorrect = false;
//       }
//       setState(() {}); // Update UI with new response data and correctness flag
//     } catch (e) {
//       print('Error while uploading audio: $e');
//       // Show user an error message here (e.g., snackbar)
//     }
//   }

//   // Future<void> _startPlayback() async {
//   //   try {
//   //     if (_player != null) {
//   //       await _player!.openPlayer();
//   //       await _player!.startPlayer(
//   //         fromURI: _fileName,
//   //         whenFinished: () {
//   //           setState(() {
//   //             _isPlaying = false;
//   //           });
//   //         },
//   //       );
//   //       setState(() {
//   //         _isPlaying = true;
//   //       });
//   //     } else {
//   //       print('Player is not initialized');
//   //     }
//   //   } catch (e) {
//   //     print('Error while playing audio: $e');
//   //     // Show user an error message here (e.g., snackbar)
//   //   }
//   // }

//   // Future<void> _stopPlayback() async {
//   //   try {
//   //     await _player!.stopPlayer();
//   //     setState(() {
//   //       _isPlaying = false;
//   //     });
//   //   } catch (e) {
//   //     print('Error while stopping audio playback: $e');
//   //     // Show user an error message here (e.g., snackbar)
//   //   }
//   // }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _recorder = FlutterSoundRecorder();
//   //   _player = FlutterSoundPlayer();
//   // }

//   // @override
//   // void dispose() {
//   //   // Release resources when widget is disposed
//   //   _recorder?.stopRecorder(); // Stop recording if ongoing
//   //   _recorder?.pauseRecorder(); // Pause recording if ongoing (optional)
//   //   _player?.stopPlayer(); // Stop playback if ongoing
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Record and Upload Audio'),
//       ),
//       body: Center(
//         child: Column(
//           // Wrap everything in a Column
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Row(
//               // Button row for options
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 ElevatedButton(
//                   onPressed: () => setState(() => correctString = 'si'),
//                   style: ElevatedButton.styleFrom(
//                     primary: correctString == 'si' ? Colors.green : Colors.grey,
//                   ),
//                   child: Text('si'),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () => setState(() => correctString = 'maya'),
//                   style: ElevatedButton.styleFrom(
//                     primary:
//                         correctString == 'maya' ? Colors.green : Colors.grey,
//                   ),
//                   child: Text('maya'),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () => setState(() => correctString = 'uhaw'),
//                   style: ElevatedButton.styleFrom(
//                     primary:
//                         correctString == 'uhaw' ? Colors.green : Colors.grey,
//                   ),
//                   child: Text('uhaw'),
//                 ),
//                 // Add more buttons for options as needed
//               ],
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isRecording ? stopRecording : _startRecording,
//               child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: uploadAudio,
//               child: Text('Upload Audio'),
//             ),
//             SizedBox(height: 20),
//             Text('Response Data: $_responseData'),
//             SizedBox(height: 10),
//             Text(
//               _isCorrect ? 'Correct!' : 'Incorrect. Expected: $correctString',
//               style: TextStyle(
//                 color: _isCorrect ? Colors.green : Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void main() {
//     runApp(MaterialApp(
//       home: SpectrogramPage(),
//     ));
//   }
// }
