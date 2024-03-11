import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class SpectrogramPage extends StatefulWidget {
  @override
  _SpectrogramPageState createState() => _SpectrogramPageState();
}

class _SpectrogramPageState extends State<SpectrogramPage> {
  late String correctString = ''; // Marked as late and non-nullable

  FlutterSoundPlayer? _player = FlutterSoundPlayer();
  FlutterSoundRecorder? _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isPlaying = false;
  String _filePath = 'test_audio.wav';
  String tempFilePath = '';

  File? _audioFile;
  String _responseData = ""; // Store response data
  bool _isCorrect = false; // Flag to indicate if response matches

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
  }

  //----------------AUDIO RECORDING----------------
  Future<void> _startRecording() async {
    try {
      // Get temporary directory path
      final tempDir = await getTemporaryDirectory();
      final String tempFilePath = '${tempDir.path}/audio_temp.wav';

      await _recorder!.openRecorder();

      await _recorder!.startRecorder(
        toFile: tempFilePath,
      );
      setState(() {
        _isRecording = true;
      });
      print("----------reocrding----------");
      // Schedule stop recording after 1 second
      Timer(Duration(seconds: 1), () => _stopRecording(tempFilePath));
    } catch (e) {
      print('Error while recording: $e');
    }
  }

  Future<void> _stopRecording(String tempFilePath) async {
    try {
      print("----------stopped----------");
      await _recorder!.closeRecorder();
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      _uploadToApi(tempFilePath);

      // Optionally delete the temporary file after use
      // await File(tempFilePath).delete();
    } catch (e) {
      print('Error while stopping recording: $e');
    }
  }

  Future<void> _uploadToApi(String tempFilePath) async {
    // Prepare request details
    final String filePath = tempFilePath;
    final List<String> fileComponents = filePath.split('/');
    final String filename = fileComponents.last;

    // Create multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.4:8080/classify'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', filePath,
        filename: filename));

    // Send request
    var response = await request.send();

    // Check response status and handle accordingly
    if (response.statusCode == 200) {
      _responseData = await response.stream.bytesToString();
      print('Server response: $_responseData');

      // Remove double quotes and backslashes from response
      _responseData = _responseData.replaceAll('"', '').replaceAll('\\', '');

      // Check if trimmed response matches expected string
      _isCorrect = _responseData.trim() == correctString.trim();
    } else {
      print('Failed to upload audio file. Error: ${response.reasonPhrase}');
      _responseData = "Upload failed"; // Set error message
      _isCorrect = false;
    }
  }

  //----------------FILE PLAYBACK----------------

  Future<void> _startPlayback() async {
    try {
      if (_player != null) {
        _player!.startPlayer(
          fromURI: tempFilePath,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
            });
          },
        );
        setState(() {
          _isPlaying = true;
        });
      } else {
        print('Player is not initialized');
      }
    } catch (e) {
      print('Error while playing audio: $e');
      // Show user an error message here (e.g., snackbar)
    }
  }

  Future<void> _stopPlayback() async {
    try {
      _player!.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error while stopping audio playback: $e');
      // Show user an error message here (e.g., snackbar)
    }
  }

  Future<void> _uploadFileSelect() async {
    if (_audioFile == null) {
      print('No audio file selected');
      return;
    }

    //   //----------------FILE SELECTION----------------
    //   // Save the audio file locally (optional)
    //   try {
    //     final Directory appDir = await getApplicationDocumentsDirectory();
    //     final String localAudioFilePath = '${appDir.path}/audio_file.wav';
    //     await _audioFile!.copy(localAudioFilePath);
    //     print('Audio file saved locally: $localAudioFilePath');
    //   } catch (e) {
    //     print('Error saving audio file locally: $e');
    //     // Handle local saving error (optional)
    //   }

    //   // Prepare request details
    //   final String filePath = _audioFile!.path;
    //   final List<String> fileComponents = filePath.split('/');
    //   final String filename = fileComponents.last;

    //   // Create multipart request
    //   var request = http.MultipartRequest(
    //     'POST',
    //     Uri.parse('http://192.168.1.8:8080/classify'),
    //   );
    //   request.files.add(await http.MultipartFile.fromPath('file', filePath,
    //       filename: filename));

    //   // Send request
    //   var response = await request.send();

    //   // Check response status and handle accordingly
    //   if (response.statusCode == 200) {
    //     _responseData = await response.stream.bytesToString();
    //     print('Server response: $_responseData');

    //     // Remove double quotes and backslashes from response
    //     _responseData = _responseData.replaceAll('"', '').replaceAll('\\', '');

    //     // Check if trimmed response matches expected string
    //     _isCorrect = _responseData.trim() == correctString.trim();
    //   } else {
    //     print('Failed to upload audio file. Error: ${response.reasonPhrase}');
    //     _responseData = "Upload failed"; // Set error message
    //     _isCorrect = false;
    //   }

    //   setState(() {}); // Update UI with new response data and correctness flag
    // }

    // Future<void> _pickAudioFile() async {
    //   FilePickerResult? result = await FilePicker.platform.pickFiles(
    //     type: FileType.audio,
    //     allowMultiple: false,
    //   );

    //   if (result != null) {
    //     setState(() {
    //       _audioFile = File(result.files.single.path!);
    //       _responseData = ""; // Clear response data on new file selection
    //       _isCorrect = false; // Reset correctness flag
    //     });
    //   } else {
    //     // Clear response data and reset correctness flag if user cancels file selection
    //     setState(() {
    //       _audioFile = null;
    //       _responseData = "";
    //       _isCorrect = false;
    //     });
    //   }

    @override
    void initState() {
      super.initState();
      _recorder = FlutterSoundRecorder();
      _player = FlutterSoundPlayer();
    }

    @override
    void dispose() {
      // Release resources when widget is disposed
      _recorder?.stopRecorder(); // Stop recording if ongoing
      _recorder?.pauseRecorder(); // Pause recording if ongoing (optional)
      _player?.stopPlayer(); // Stop playback if ongoing
      super.dispose();
    }
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
            // SizedBox(height: 20),
            // _audioFile == null
            //     ? Text('No audio file selected')
            //     : Text('Selected audio file: ${_audioFile!.path}'),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _pickAudioFile,
            //   child: Text('Select Audio File'),
            // ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _uploadFileSelect,
            //   child: Text('Upload Audio File'),
            // ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isRecording) {
                  _stopRecording(tempFilePath);
                } else {
                  _startRecording();
                  _isRecording = true; // Update recording state immediately
                }
              },
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
