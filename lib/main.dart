import 'package:flutter/material.dart';
import 'speech_recognition.dart'; // Import the speech recognition file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Speech Recognition Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(), // Assuming HomePage contains ContinuousSpeechRecognition
    );
  }
}

// HomePage widget using ContinuousSpeechRecognition
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContinuousSpeechRecognition(); // Use ContinuousSpeechRecognition from speech_recognition.dart
  }
}
