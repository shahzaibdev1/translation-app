import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/providers/theme_provider.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
          child: ListView(children: [
        ListTile(
          title: Text(Provider.of<ThemeProvider>(context).isDarkMode
              ? "Use light theme"
              : "Use dark theme"),
          onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
        )
      ])),
    );
  }
}
