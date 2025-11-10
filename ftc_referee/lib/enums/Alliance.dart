import 'package:flutter/material.dart';

enum Alliance {
  red,
  blue;

  @override
  String toString() {
    // Capitalize first letter
    return name[0].toUpperCase() + name.substring(1);
  }

  Color get color {
    switch (this) {
      case Alliance.red:
        return Colors.red;
      case Alliance.blue:
        return Colors.blue;
    }
  }
}