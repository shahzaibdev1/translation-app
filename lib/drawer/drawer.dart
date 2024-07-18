import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/history/history.dart';
import 'package:translation_app/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  handleOpenInBrowser(String url) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Opening URL in browser!'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      130)),
        );
      }
      Uri uri = Uri.parse(url);
      // if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // } else {
      //   throw 'Could not launch $url';
      // }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
          child: ListView(
        children: [
          SizedBox(
              height: 200,
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                      Container(
                          margin: const EdgeInsets.only(top: 0),
                          child: const Text(
                            "Communicate with the world",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ))
                    ],
                  ))),
          Container(
            height: 100,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: const ListTile(
              title: Text('Get Premium',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text('Remove ads by upgrading to premium',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              // Other ListTile properties...
            ),
          ),
          ListTile(
            leading: const Icon(
              color: Color(0xff727272),
              Icons.color_lens_outlined,
              size: 22,
            ),
            title: Text(
                Provider.of<ThemeProvider>(context).isDarkMode
                    ? "Use light theme"
                    : "Use dark theme",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
              leading: Image.asset("assets/images/history.png", width: 22, height: 22),
              title: const Text("History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Builder(
                          builder: (context) {
                            return const History();
                          },
                        );
                      },
                    ),
                  )),
          ListTile(
            leading: Image.asset("assets/images/language.png", width: 22, height: 22),
            title:
                const Text("Language", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
            leading: Image.asset("assets/images/rate_us.png", width: 22, height: 22),
            title:
                const Text("Rate Us", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onTap: () => handleOpenInBrowser(
                "https://play.google.com/store/apps/developer?id=Think+Apps+Lab"),

            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
            // onTap: () => handleOpenInBrowser(
            //     "https://play.google.com/store/apps/developer?id=Think+Apps+Lab"),
            leading: Image.asset("assets/images/share.png", width: 22, height: 22),
            title: const Text("Share App",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
          ListTile(
            onTap: () =>
                handleOpenInBrowser("https://sites.google.com/view/thinkappstudioprivacypolicy"),
            leading: Image.asset("assets/images/privacy_policy.png", width: 22, height: 22),
            title: const Text("Privacy Policy",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            // onTap: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
        ],
      )),
    );
  }
}
