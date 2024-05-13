import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/TextRecognizer.dart';
import 'package:translation_app/conversation_screen/conversation_screen.dart';
import 'package:translation_app/providers/theme_provider.dart';
import 'package:translation_app/text_screen/text_screen.dart';

/// Flutter code sample for [NavigationBar].

void main() =>
    runApp(ChangeNotifierProvider(create: (_) => ThemeProvider(), child: const NavigationBarApp()));

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        theme: themeProvider.isDarkMode
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData(useMaterial3: true),
        home: const NavigationExample(),
      );
    });
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: theme.colorScheme.primary,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Image.asset(
              "assets/images/text.png",
              width: 24,
              height: 24,
            ),
            icon: Image.asset("assets/images/text.png", width: 24, height: 24),
            label: 'Text',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.camera_alt),
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Camera',
          ),
          const NavigationDestination(
            icon: Icon(Icons.messenger_outline_sharp),
            selectedIcon: Icon(Icons.messenger_sharp),
            label: 'Conversation',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        const TextScreen(),

        /// Notifications page
        const TextRecognizerView(),

        const Conversation()

        /// Messages page
      ][currentPageIndex],
    );
  }
}
