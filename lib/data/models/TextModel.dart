import 'package:flutter/material.dart';
import 'package:learning2/core/constants/fonts.dart';

Widget _buildText(String str) {
  return MediaQuery(
    data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
    child: Text(
      str,
      style: Fonts.bodyBold.copyWith(fontSize: 16),
    ),
  );
}


