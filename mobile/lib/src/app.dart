import 'package:flutter/material.dart';

class MobileYatzeeApp extends StatelessWidget {
  const MobileYatzeeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const Scaffold(body: Center(child: Text('Generał'))),
  );
}
