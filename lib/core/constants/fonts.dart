import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  // Add your theme customizations here
);

class Fonts {
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: Colors.black,
  );
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: Colors.black,
  );
  static const TextStyle smallBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle italic = TextStyle(
    fontSize: 12,
    fontStyle: FontStyle.italic,
    color: Colors.black,
  );
  // Add more as needed
} 