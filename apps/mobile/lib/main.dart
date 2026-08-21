import 'package:flutter/material.dart';

void main() {
  runApp(const ByteBeamsApp());
}

final class ByteBeamsApp extends StatelessWidget {
  const ByteBeamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByteBeams',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const Scaffold(body: Center(child: Text('ByteBeams'))),
    );
  }
}
