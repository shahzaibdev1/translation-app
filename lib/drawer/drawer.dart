import 'package:flutter/material.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
          child: ListView(
        children: [
          ListTile(
            tileColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.only(bottom: 8, top: 8),
            title: const Text('Translate app',
                style: TextStyle(fontFamily: "Arial", fontSize: 24, color: Colors.white)),
            leading: IconButton(
                iconSize: 30,
                icon: const Icon(Icons.arrow_circle_left_outlined),
                onPressed: () => Navigator.pop(context),
                color: Colors.white),
          ),
        ],
      )),
    );
  }
}
