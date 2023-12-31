import 'dart:ui';
import 'package:flutter/material.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}

int calculateAge(DateTime birthdate) {
  final DateTime today = DateTime.now();
  int age = today.year - birthdate.year;
  final int monthDifference = today.month - birthdate.month;

  // Adjust age if birth month hasn't occurred this year or if it's the birth month but the day hasn't occurred
  if (monthDifference < 0 ||
      (monthDifference == 0 && today.day < birthdate.day)) {
    age--;
  }

  return age;
}

List<double> getColumnFromMatrix(List<List<double>> matrix, int colIdx) {
  final List<double> col = [];
  for (int i = 0; i < matrix.length; i++) {
    col.add(matrix[i][colIdx]);
  }
  return col;
}

double getPercentile(List<double> values, double percent) {
  final int percentileIdx = (values.length * percent).floor();
  return values[percentileIdx];
}
