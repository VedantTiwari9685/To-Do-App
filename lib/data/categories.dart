import 'package:flutter/material.dart';
import 'package:todo_app/models/category.dart';

const categories = {
  Categories.study: Category(
    title: 'Study',
    icon: Icons.school,
  ),
  Categories.personalcare: Category(
    title: 'Personal Care',
    icon: Icons.bathtub_sharp,
  ),
  Categories.cleaning: Category(
    title: 'Cleaning',
    icon: Icons.cleaning_services,
  ),
  Categories.family: Category(
    title: 'Family',
    icon: Icons.family_restroom,
  ),
  Categories.fitness: Category(
    title: 'Fitness',
    icon: Icons.fitness_center,
  ),
  Categories.friends: Category(
    title: 'Friends',
    icon: Icons.emoji_people,
  ),
  Categories.mentalhealth: Category(
    title: 'Mental Health',
    icon: Icons.psychology,
  ),
  Categories.work: Category(
    title: 'Work',
    icon: Icons.work,
  ),
  Categories.reading: Category(
    title: 'Reading',
    icon: Icons.menu_book,
  ),
  Categories.health: Category(
    title: 'Health',
    icon: Icons.self_improvement,
  ),
  Categories.hobbies: Category(
    title: 'Hobbies',
    icon: Icons.palette,
  ),
  Categories.selfdevelopment: Category(
    title: 'Self Development',
    icon: Icons.insights,
  ),
  Categories.pets: Category(
    title: 'Pets',
    icon: Icons.pets,
  ),
  Categories.social: Category(
    title: 'Social',
    icon: Icons.social_distance,
  ),
  Categories.entertainment: Category(
    title: 'Entertainment',
    icon: Icons.movie,
  ),
};
