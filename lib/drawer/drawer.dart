import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    final ThemeData theme = Theme.of(context);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
          child: ListView(
        children: [
          SizedBox(
              height: 250,
              child: DrawerHeader(
                  decoration: BoxDecoration(
                      border: Border.all(
                    width: 0,
                    style: BorderStyle.none,
                  )),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/side_bar_logo.png",
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const Text(
                            "Language Translator",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          )),
                      Container(
                          margin: const EdgeInsets.only(top: 0),
                          child: const Text(
                            "Communicate with the world",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                    ],
                  ))),
          Container(
            height: 120,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: const ListTile(
              title: Text('Get Premium',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              subtitle: Text('Remove ads by upgrading to premium',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              // Other ListTile properties...
            ),
          ),
          ListTile(
            title: Text(
                Provider.of<ThemeProvider>(context).isDarkMode
                    ? "Use light theme"
                    : "Use dark theme",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
            leading: Image.asset("assets/images/history.png", width: 24, height: 24),
            title: const Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
            leading: Image.asset("assets/images/language.png", width: 24, height: 24),
            title: const Text("Language", style: TextStyle(fontWeight: FontWeight.bold)),
            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
            leading: Image.asset("assets/images/rate_us.png", width: 24, height: 24),
            title: const Text("Rate Us", style: TextStyle(fontWeight: FontWeight.bold)),
            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
            leading: Image.asset("assets/images/share.png", width: 24, height: 24),
            title: const Text("Share App", style: TextStyle(fontWeight: FontWeight.bold)),
            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
            leading: Image.asset("assets/images/privacy_policy.png", width: 24, height: 24),
            title: const Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.bold)),
            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
        ],
      )),
    );
  }
}
