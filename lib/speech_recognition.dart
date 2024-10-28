import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';

class ContinuousSpeechRecognition extends StatefulWidget {
  @override
  _ContinuousSpeechRecognitionState createState() =>
      _ContinuousSpeechRecognitionState();
}

class _ContinuousSpeechRecognitionState
    extends State<ContinuousSpeechRecognition> {
  late SpeechToText _speech;
  bool _isListening = false;
  String _text = ""; // Stores recognized text
  Timer? _restartTimer;
  Set<String> _recognizedWords = {}; // Set to track recognized words

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
  }

  // Function to request microphone permission
  Future<void> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  // Function to start listening
  Future<void> _startListening() async {
    await _requestPermission(); // Ensure permission is granted

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _text = ""; // Clear previous text when starting a new session
        _recognizedWords.clear(); // Clear the recognized words set
      });

      // Start the speech-to-text conversion
      _convertSpeechToText();

      // Start checking if listening stops automatically
      _checkAndRestartListening();
    }
  }

  // Function to stop listening
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      // Do NOT clear the text here to keep the previous words visible
    });
    _restartTimer?.cancel(); // Cancel the restart timer when stopping
  }

  // Function to handle speech-to-text conversion
  void _convertSpeechToText() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          // Process recognized words only if they are new
          for (String word in result.recognizedWords.split(' ')) {
            if (!_recognizedWords.contains(word)) {
              _recognizedWords.add(word); // Add to the set
              _text += word + ' '; // Append recognized words
            }
          }
        });
      },
      partialResults: true,
      cancelOnError: false,
    );
  }

  // Function to check if listening has stopped, and restart it if necessary
  void _checkAndRestartListening() {
    _restartTimer?.cancel(); // Cancel any existing timer
    _restartTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isListening && !_speech.isListening) { // Check if listening has stopped
        // Restart listening if it was stopped automatically
        _convertSpeechToText(); // Automatically restart listening
      }
      // Recursively check for the next loop
      if (_isListening) {
        _checkAndRestartListening(); // Keep checking as long as _isListening is true
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Continuous Speech Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _text.isEmpty ? 'Press the button and start speaking!' : _text,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple,foregroundColor: Colors.white),
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening',style: TextStyle(fontSize: 17),),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _restartTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }
}
