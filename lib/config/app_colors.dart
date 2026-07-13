import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color terracotta = Color(0xFF9E3A25);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color creamDarker = Color(0xFFFCF9F2);

  // Category specific colors
  static Color getCategoryCircleColor(String cat) {
    final catLower = cat.toLowerCase();
    if (catLower.contains('kampus') || catLower.contains('school') || catLower.contains('study')) {
      return const Color(0xFF2C5E8A);
    } else if (catLower.contains('organisasi') || catLower.contains('org') || catLower.contains('work')) {
      return const Color(0xFF8A3024);
    } else if (catLower.contains('pribadi') || catLower.contains('personal') || catLower.contains('private')) {
      return const Color(0xFF2C6339);
    }
    return Colors.blueGrey.shade700;
  }

  static Color getCategoryBgColor(String cat) {
    final catLower = cat.toLowerCase();
    if (catLower.contains('kampus') || catLower.contains('school') || catLower.contains('study')) {
      return const Color(0xFFCEE0F4);
    } else if (catLower.contains('organisasi') || catLower.contains('org') || catLower.contains('work')) {
      return const Color(0xFFF9D6D0);
    } else if (catLower.contains('pribadi') || catLower.contains('personal') || catLower.contains('private')) {
      return const Color(0xFFD3EAD8);
    }
    return const Color(0xFFE5E5E5);
  }

  static Color getCategoryTextColor(String cat) {
    final catLower = cat.toLowerCase();
    if (catLower.contains('kampus') || catLower.contains('school') || catLower.contains('study')) {
      return const Color(0xFF2C5E8A);
    } else if (catLower.contains('organisasi') || catLower.contains('org') || catLower.contains('work')) {
      return const Color(0xFF8A3024);
    } else if (catLower.contains('pribadi') || catLower.contains('personal') || catLower.contains('private')) {
      return const Color(0xFF2C6339);
    }
    return Colors.black87;
  }
}
