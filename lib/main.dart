import 'dart:io';

import 'package:entrada_dados/home_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//+import 'tela_inicial.dart';

void main() async {
  //precisa pegar as informações do GoogleService que é passado do firebase para as pastas app e runner
  const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyDtfD02vXfFDUEZs-j2-x4Gpq6mtr8sjDU", // Linha 18
      appId: "1:449867739897:android:9ccf4ce0451d3e3d356828", //linha 10
      messagingSenderId: "449867739897", //Linha 3
      projectId: "patinhaperdida-4731f", // linha 4
      storageBucket: "patinhaperdida-4731f.appspot.com"); //Linha 5

  const FirebaseOptions ios = FirebaseOptions(
      apiKey: "AIzaSyCL4oOuBRjVsoemSdIKsGLiML-0Mvrd9lU", // Linha 6
      appId: "1:449867739897:ios:3246082633558001356828", //linha 28
      messagingSenderId: "449867739897", //Linha 8
      projectId: "patinhaperdida-4731f", // linha 13
      storageBucket: "patinhaperdida-4731f.appspot.com"); //Linha 16

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: Platform.isAndroid ? android : ios);

  runApp(const MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ],
    supportedLocales: [Locale("pt")],
    home: HomeNavigation(),
    debugShowCheckedModeBanner: false,
  ));
}
