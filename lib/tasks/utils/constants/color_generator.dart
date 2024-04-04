import 'dart:math';
import 'package:flutter/material.dart';

// Random Color
class ColorGenerator {
  static Color generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      5,
    );
  }
}

// Random Number
class NumberGenerator {
  static int getRandomNumberInRange(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min);
  }
}

// int randomNumber = NumberGenerator.getRandomNumberInRange(1, 101);
