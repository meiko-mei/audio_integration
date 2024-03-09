import 'dart:async';
import 'dart:io';
import 'dart:developer' as log;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';

class SpectrogramPage extends StatefulWidget {
  @override
  _SpectrogramPageState createState() => _SpectrogramPageState();
}

class _SpectrogramPageState extends State<SpectrogramPage> {
  late String correctString = ''; // Marked as late and non-nullable

  var recorder = FlutterAudioRecorder2('', audioFormat: AudioFormat.WAV);
  File? _audioFile;
  String result = '';
  String _responseData = ""; // Store response data
  bool _isCorrect = false;
  bool _isRecording = false;
  // bool _isPlaying = false; // Flag to indicate if response matches

  getResponse(String path) async {
    print('============get Response was called=============');
    try {
      var pos = path.split('/');
      //log.log(pos.last);
      print("File name is ${pos.last}");
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.43.113:8080/analyze_emotion'));
      var multiPartData = http.MultipartFile.fromPath(
        'file',
        path,
        filename: pos.first,
      );
      request.files.add(await multiPartData);

      http.StreamedResponse response = await request.send();
      // log.log('Response');
      print('************Response is about to test**********');
      if (response.statusCode == 200) {
        print("==========Status code is 200========");
        try {
          final extractedData =
              json.decode(await response.stream.bytesToString());
          print(extractedData);
          result = extractedData['server_response'].toString();

          print('******** Obtaining Response ********');
          // log.log(extractedData['emotion'].toString());
          print("Response is ${extractedData['server_response'].toString()}");
        } catch (e) {
          print('Exception :( ${e}');
        }
      } else {
        print("======Error is printing====");
        // log.log(response.reasonPhrase.toString());
        print(response.reasonPhrase.toString());
        print("=========Completed with error=======");
      }
    } catch (e) {
      print(e.runtimeType);
    }
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
        _responseData = ""; // Clear response data on new file selection
        _isCorrect = false; // Reset correctness flag
      });
    } else {
      // Clear response data and reset correctness flag if user cancels file selection
      setState(() {
        _audioFile = null;
        _responseData = "";
        _isCorrect = false;
      });
    }
  }

  Future<void> startRecording() async {
    print('Recorder was started======');
    recorder.start();

    // Start a timer to stop recording after 1 second
    Timer(Duration(seconds: 1), () async {
      if (_isRecording) {
        await stopRecording();
      }
    });

    setState(() {
      _isRecording = true;
    });
  }

  Future<String?> stopRecording() async {
    var result = await recorder.stop();
    log.log(result!.path!);
    print('Recording was stoped & path is======== ${result.path}');
    getResponse(result.path!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Audio File'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => setState(() => correctString = 'si'),
                    style: ElevatedButton.styleFrom(
                      primary:
                          correctString == 'si' ? Colors.green : Colors.grey,
                    ),
                    child: Text('si'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => correctString = 'maya'),
                    style: ElevatedButton.styleFrom(
                      primary:
                          correctString == 'maya' ? Colors.green : Colors.grey,
                    ),
                    child: Text('maya'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => correctString = 'uhaw'),
                    style: ElevatedButton.styleFrom(
                      primary:
                          correctString == 'uhaw' ? Colors.green : Colors.grey,
                    ),
                    child: Text('uhaw'),
                  ),
                  // Add more buttons for options as needed
                ],
              ),
            ),
            SizedBox(height: 20),
            _audioFile == null
                ? Text('No audio file selected')
                : Text('Selected audio file: ${_audioFile!.path}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAudioFile,
              child: Text('Select Audio File'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? stopRecording : startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            Text('Response Data: $_responseData'),
            SizedBox(height: 10),
            Text(
              _isCorrect ? 'Correct!' : 'Incorrect. Expected: $correctString',
              style: TextStyle(
                color: _isCorrect ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SpectrogramPage(),
  ));
}
