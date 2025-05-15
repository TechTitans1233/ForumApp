import 'package:flutter/material.dart';

class UserPostCard extends StatelessWidget {
  final String content;
  const UserPostCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(content),
      ),
    );
  }
}
