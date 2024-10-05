import 'package:flutter/material.dart';

class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage('assets/images/developer.jpg'),
                ),
                const SizedBox(width: 16),
                Text(
                  'Vedant Tiwari',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            const Text(
              'About the Developer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to To-Do App, a productivity companion designed to simplify your task management. As a Software Engineer and B.Tech student in Computer Science and Engineering (2022-2026), I, Vedant Tiwari, created this app to tackle my own struggles with staying organized. Frustrated with forgotten tasks and missed deadlines, I built To-Do App to streamline your to-do list experience. This app aims to make task management effortless, helping you stay focused and productive across all aspects of your life',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            Text(
              "Stay tuned for upcoming updates that will bring new features, design enhancements, and performance improvements to To-Do App. Your feedback is crucial in shaping the app's future, and I'm committed to delivering a seamless and intuitive experience.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
