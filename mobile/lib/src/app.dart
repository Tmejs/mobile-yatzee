import 'package:flutter/material.dart';
import 'package:mobile_yatzee/l10n/app_localizations.dart';

import 'home/home_screen.dart';
import 'theme/modern_tabletop_theme.dart';

class MobileYatzeeApp extends StatelessWidget {
  const MobileYatzeeApp({this.locale, super.key});
  final Locale? locale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    locale: locale ?? const Locale('pl'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: modernTabletopTheme(),
    home: const HomeScreen(),
  );
}
