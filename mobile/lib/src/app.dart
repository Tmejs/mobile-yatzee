import 'package:flutter/material.dart';
import 'package:mobile_yatzee/src/localization/app_strings.dart';

class MobileYatzeeApp extends StatelessWidget {
  const MobileYatzeeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(child: Text(AppStrings.polish(AppStringKey.homeTitle))),
    ),
  );
}
