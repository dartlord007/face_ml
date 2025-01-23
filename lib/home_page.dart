import 'package:face_ml/face_detector.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detector'),
      ),
      body: _body(context),
    );
  }
}

Widget _body(BuildContext context) {
  return Center(
    child: OutlinedButton(
      style: ButtonStyle(
        side: WidgetStateProperty.all(
          const BorderSide(
              color: Colors.blue, width: 1, style: BorderStyle.solid),
        ),
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FaceDetector())),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 24,
            ),
          ),
          Text(
            'Go to the face detector',
            style: TextStyle(fontSize: 20),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 24,
            ),
          ),
        ],
      ),
    ),
  );
}
