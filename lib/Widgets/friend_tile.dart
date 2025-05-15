import 'package:flutter/material.dart';

class FriendTile extends StatelessWidget {
  final String name;
  const FriendTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage: NetworkImage("https://www.w3schools.com/w3images/avatar2.png"),
      ),
      title: Text(name),
    );
  }
}
