import 'package:flutter/material.dart';

enum Categories {
  study,
  personalcare,
  cleaning,
  family,
  fitness,
  friends,
  mentalhealth,
  work,
  reading,
  health,
  hobbies,
  selfdevelopment,
  pets,
  social,
  entertainment,
}

class Category {
  const Category({required this.title, required this.icon});
  final String title;
  final IconData icon;
}
