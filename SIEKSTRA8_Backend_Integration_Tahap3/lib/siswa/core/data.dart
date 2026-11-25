import 'package:flutter/material.dart';

class Ekskul {
  final String name, category, desc, coach, schedule, place;
  final String? id;
  final int filled, quota; // quota 0 = tanpa kuota
  final IconData icon;
  final Color color, colorBg;
  final List<Color> photo;
  const Ekskul({
    this.id,
    required this.name,
    required this.category,
    required this.desc,
    required this.coach,
    required this.schedule,
    required this.place,
    required this.filled,
    required this.quota,
    required this.icon,
    required this.color,
    required this.colorBg,
    required this.photo,
  });
  double get ratio => quota == 0 ? 1 : filled / quota;
  bool get full => quota != 0 && filled >= quota;
  bool get almostFull => quota != 0 && ratio >= .9;
}
