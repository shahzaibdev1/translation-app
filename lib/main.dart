import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/conversation_screen/conversation_screen.dart';
import 'package:translation_app/dictionary/dictionary.dart';
import 'package:translation_app/providers/navigation_status.dart';
import 'package:translation_app/providers/theme_provider.dart';
import 'package:translation_app/text_screen/text_screen.dart';
import 'package:translation_app/utils/linear_progress.dart';
import 'package:translation_app/utils/splash_screen.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => NavigationStatus()),
    ], child: const NavigationBarApp()));

class NavigationBarApp extends StatefulWidget {
  const NavigationBarApp({super.key});

  @override
  State<NavigationBarApp> createState() => _NavigationBarAppState();
}

class _NavigationBarAppState extends State<NavigationBarApp> {
  bool isFirst = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isFirst = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, NavigationStatus>(
        builder: (context, themeProvider, navigationStatus, child) {
      return MaterialApp(
        theme: themeProvider.isDarkMode
            ? ThemeData.dark(useMaterial3: true).copyWith(
                textTheme: const TextTheme(
                    bodyLarge: TextStyle(fontFamily: "Gordita"),
                    bodyMedium: TextStyle(fontFamily: "Gordita"),
                    bodySmall: TextStyle(fontFamily: "Gordita")),
                // navigationBarTheme: NavigationBarThemeData(
                //   indicatorColor: Theme.of(context).colorScheme.background,
                //   labelTextStyle: MaterialStateProperty.resolveWith((states) {
                //     if (states.contains(MaterialState.selected)) {
                //       return const TextStyle(color: Colors.blue); // Color when selected
                //     }
                //     return const TextStyle(color: Colors.grey); // Color when not selected
                //   }),
                // ),
              )
            : ThemeData(
                useMaterial3: true,
                textTheme: const TextTheme(
                    bodyLarge: TextStyle(fontFamily: "Gordita"),
                    bodyMedium: TextStyle(fontFamily: "Gordita"),
                    bodySmall: TextStyle(fontFamily: "Gordita")),
                // navigationBarTheme: NavigationBarThemeData(
                //   indicatorColor: Theme.of(context).colorScheme.background,
                //   labelTextStyle: MaterialStateProperty.resolveWith((states) {
                //     final defaultStyle = Theme.of(context).textTheme.bodyMedium;
                //     if (states.contains(MaterialState.selected)) {
                //       return defaultStyle?.copyWith(color: Colors.blue); // Color when selected
                //     }
                //     return defaultStyle?.copyWith(color: Colors.grey);
                //   }),
                // ),
              ),
        home: isFirst
            ? Scaffold(
                body: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Language Translator",
                      style: TextStyle(
                          fontSize: 34, fontWeight: FontWeight.bold, fontFamily: "Gordita Bold")),
                  const Text("Communicate with the world",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    margin: const EdgeInsets.only(top: 60),

                    width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
                    height: MediaQuery.of(context).size.width * 0.7, // Make it a square
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.black),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const ContinuousSlider(),
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      width: 200,
                      child: const LinearProgress()),
                  const Text("Loading...",
                      style: TextStyle(
                        fontSize: 20,
                        // fontWeight: FontWeight.bold,
                        fontFamily: "Gordita Bold",
                      ))
                ]),
              ))
            :
            // Container(width: MediaQuery.of(context).size.width * 0.6, child: ContinuousSlider()),

            const Column(children: [
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
    print(theme.navigationBarTheme.labelTextStyle);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          Provider.of<NavigationStatus>(context, listen: false).changePageIndex(index);
        },
        indicatorColor: theme.colorScheme.primary.withAlpha(100),
        selectedIndex: Provider.of<NavigationStatus>(context).currentPageIndex,
        animationDuration: const Duration(milliseconds: 2000),
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Image.asset(
              "assets/images/home_selected.png",
              width: 24,
              height: 24,
            ),
            icon: Image.asset("assets/images/home.png", width: 24, height: 24),
            label: 'Text',
          ),
          NavigationDestination(
            icon: Image.asset(
              "assets/images/conversation.png",
              width: 24,
              height: 24,
            ),
            selectedIcon: Image.asset(
              "assets/images/conversation_selected.png",
              width: 24,
              height: 24,
            ),
            label: 'Conversation',
          ),
          NavigationDestination(
            selectedIcon: Image.asset(
              "assets/images/dictionary_selected.png",
              width: 24,
              height: 24,
            ),
            icon: Image.asset(
              "assets/images/dictionary.png",
              width: 24,
              height: 24,
            ),
            label: 'Dictionary',
          ),
          // const NavigationDestination(
          //   selectedIcon: Icon(Icons.menu_book),
          //   icon: Icon(Icons.menu_book_outlined),
          //   label: 'Phrases',
          // ),
        ],
      ),
      body:
          //  ContinuousSlider(image1: "assets/images/map1.png", image2: "assets/images/map2.png"),
          <Widget>[
        /// Home page
        const TextScreen(),

        const Conversation(),
        const DictionaryScreen(),
        // const Conversation(),

        /// Notifications page

        /// Messages page
      ][Provider.of<NavigationStatus>(context).currentPageIndex],
    );
  }
}
