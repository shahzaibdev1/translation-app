import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/TextRecognizer.dart';
import 'package:translation_app/conversation_screen/conversation_screen.dart';
import 'package:translation_app/dictionary/dictionary.dart';
import 'package:translation_app/providers/navigation_status.dart';
import 'package:translation_app/providers/theme_provider.dart';
import 'package:translation_app/text_screen/text_screen.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => NavigationStatus()),
    ], child: const NavigationBarApp()));

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, NavigationStatus>(
        builder: (context, themeProvider, navigationStatus, child) {
      return MaterialApp(
        theme: themeProvider.isDarkMode
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData(useMaterial3: true),
        home: const Column(children: [
          Expanded(child: NavigationExample()),
        ]),
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
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          Provider.of<NavigationStatus>(context, listen: false).changePageIndex(index);
        },
        indicatorColor: theme.colorScheme.primary,
        selectedIndex: Provider.of<NavigationStatus>(context).currentPageIndex,
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
            icon: Icon(Icons.messenger_outline_sharp),
            selectedIcon: Icon(Icons.messenger_sharp),
            label: 'Conversation',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.format_color_text),
            icon: Icon(Icons.format_color_text_outlined),
            label: 'Dictionary',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.menu_book),
            icon: Icon(Icons.menu_book_outlined),
            label: 'Phrases',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        const TextScreen(),

        const Conversation(),
        const DictionaryScreen(),
        const Conversation(),

        /// Notifications page

        /// Messages page
      ][Provider.of<NavigationStatus>(context).currentPageIndex],
    );
  }
}
