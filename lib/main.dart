import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translation_app/ads/app_open_ad.dart';
import 'package:translation_app/ads/banner_add.dart';
import 'package:translation_app/conversation_screen/conversation_screen.dart';
import 'package:translation_app/dictionary/dictionary.dart';
import 'package:translation_app/providers/app_state_provider.dart';
import 'package:translation_app/providers/interstitialAdProvider.dart';
import 'package:translation_app/providers/navigation_status.dart';
import 'package:translation_app/providers/speech_to_text.dart';
import 'package:translation_app/providers/theme_provider.dart';
import 'package:translation_app/text_screen/text_screen.dart';
import 'package:translation_app/utils/linear_progress.dart';
import 'package:translation_app/utils/splash_screen.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => NavigationStatus()),
          ChangeNotifierProvider(create: (_) => SpeechToTextProvider()),
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => InterStitialAdProvider()),
        ],
        child: Consumer5<ThemeProvider, NavigationStatus, SpeechToTextProvider, AppStateProvider,
                InterStitialAdProvider>(
            builder: (context, themeProvider, navigationStatus, speachToTextProvider,
                appStateProvider, interStitialAdProvider, child) {
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
              home: const NavigationBarApp());
        })));

class NavigationBarApp extends StatefulWidget {
  const NavigationBarApp({super.key});

  @override
  State<NavigationBarApp> createState() => _NavigationBarAppState();
}

class _NavigationBarAppState extends State<NavigationBarApp> {
  StreamSubscription<dynamic>? _subscription;
  late Future<void> _initialization;

  void loadForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        consentForm.show((formError) {
          print("Some wentt wrong $formError");
        });
        // Present the form
      },
      (FormError formError) {
        // Handle the error
        print("Error something wen wrong $formError");
      },
    );
  }

  // void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  //   purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
  //     if (purchaseDetails.status == PurchaseStatus.pending) {
  //       // _showPendingUI();
  //       print("Pending Payment");
  //     } else {
  //       // print(
  //       //     "${purchaseDetails.productID}, ${purchaseDetails.verificationData.localVerificationData} verificationData");
  //       if (purchaseDetails.status == PurchaseStatus.error) {
  //         // _handleError(purchaseDetails.error!);
  //         Provider.of<AppStateProvider>(context, listen: false).setUnpaid();
  //         print(purchaseDetails.error);
  //       } else if (purchaseDetails.status == PurchaseStatus.purchased ||
  //           purchaseDetails.status == PurchaseStatus.restored) {
  //         // bool valid = await _verifyPurchase(purchaseDetails);
  //         Provider.of<AppStateProvider>(context, listen: false).setPaid();
  //         print("Purchased, verify if required");

  //         // if (valid) {
  //         //   _deliverProduct(purchaseDetails);
  //         // } else {
  //         //   _handleInvalidPurchase(purchaseDetails);
  //         // }
  //       }
  //       if (purchaseDetails.pendingCompletePurchase) {
  //         await InAppPurchase.instance.completePurchase(purchaseDetails);
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load the consent form for EU customers

      final params = ConsentRequestParameters();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            loadForm();
          } else {
            print("consent form is not available");
          }
        },
        (FormError error) {
          print(error);
          // Handle the error
        },
      );
    });
    // InAppPurchase.instance.restorePurchases();

    // final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    // _subscription = purchaseUpdated.listen((purchaseDetailsList) {
    //   _listenToPurchaseUpdated(purchaseDetailsList);
    // }, onDone: () {
    //   _subscription?.cancel();
    // }, onError: (error) {
    //   // handle error here.
    //   Provider.of<AppStateProvider>(context, listen: false).setUnpaid();
    // });

    _initialization = _loadResources();
  }

  loadPaidCheck() async {
    // bool? isPaid = await ConfigStorage.getPaid();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isPaid = prefs.getBool("isPaid");
    if (isPaid == true && mounted) {
      Provider.of<AppStateProvider>(context, listen: false).setPaid();
    } else if (mounted) {
      await MobileAds.instance.initialize();
      await AppOpenAdManager.instance.loadAd(context);
      Provider.of<InterStitialAdProvider>(context, listen: false).loadAd(context: context);
    }
  }

  Future<void> _loadResources() async {
    loadPaidCheck();
    await Future.delayed(const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Language Translator",
                      style: TextStyle(
                          fontSize: 34, fontWeight: FontWeight.bold, fontFamily: "Gordita Bold")),
                  const Text("Communicate with the world",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.black),
                    ),
                    margin: const EdgeInsets.only(top: 60),
                    width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
                    height: MediaQuery.of(context).size.width * 0.7, // Make it a square

                    clipBehavior: Clip.antiAlias,
                    child: const ContinuousSlider(),
                  ),
                  Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      width: 200,
                      // clipBehavior: Clip.antiAlias,
                      child: const LinearProgress()),
                  const Text("Loading...",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Gordita Bold",
                      ))
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
              resizeToAvoidBottomInset: false, // Keeps the bottom bar fixed

              // height: MediaQuery.sizeOf(context).height,
              body: Column(children: [
                Expanded(child: NavigationExample()),
                TranslationBannerAd(size: "full")
              ]));
        }
      },
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  @override
  void initState() {
    super.initState();

    // Load app open ad
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    AppOpenAdManager.instance.showAd();
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    AppOpenAdManager.instance.appOpenAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // print(theme.navigationBarTheme.labelTextStyle);

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
