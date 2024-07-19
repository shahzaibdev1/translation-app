// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:translation_app/utils/utils.dart';
// import 'package:provider/provider.dart';

const String testAdId = 'ca-app-pub-3940256099942544/9257395921';

class AppOpenAdManager {
  AppOpenAd? appOpenAd;
  bool hasShownAd = false;

  BuildContext? ctx;

  // Private constructor
  AppOpenAdManager._privateConstructor();

  // The single instance of the class
  static final AppOpenAdManager _instance = AppOpenAdManager._privateConstructor();

  // Public getter to access the instance
  static AppOpenAdManager get instance => _instance;

  /// Load an AppOpenAd.
  Future<void> loadAd(BuildContext context) async {
    ConsentStatus status = await ConsentInformation.instance.getConsentStatus();

    // We will implement this below.
    // showDialog(
    //     context: context,
    //     builder: (BuildContext ctt) {
    //       ctx = ctt;
    //       return Dialog.fullscreen(
    //           // backgroundColor: Colors.transparent,
    //           // shape: BeveledRectangleBorder(),

    //           child: Stack(alignment: Alignment.center, children: [
    //         Container(
    //             height: MediaQuery.of(context).size.height,
    //             width: MediaQuery.of(context).size.width,
    //             color: Colors.black,
    //             child: const Column(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 CircularProgressIndicator(),
    //                 Text(
    //                   "Loading...",
    //                   textAlign: TextAlign.center,
    //                 )
    //               ],
    //             ))
    //       ]));
    //     });

    // Set a timeout of 3 seconds for ad loading
    const timeout = Duration(seconds: 4);

    const String adUnitId = 'ca-app-pub-4335977416487659/4272738451';
    try {
      // Attempt to load the ad within the timeout
      await Future.any([
        AppOpenAd.load(
          adUnitId: isTestAd ? testAdId : adUnitId,
          request: AdRequest(
            nonPersonalizedAds:
                status == ConsentStatus.obtained || status == ConsentStatus.notRequired,
          ),
          adLoadCallback: AppOpenAdLoadCallback(
            onAdLoaded: (ad) {
              print("App open ad loaded");
              appOpenAd = ad;
            },
            onAdFailedToLoad: (error) {
              hasShownAd = true;
              if (ctx != null) {
                Navigator.pop(ctx!);
              }
              Navigator.pop(ctx!);

              print('AppOpenAd failed to load: $error, ${error.message}');
            },
          ),
        ),
        Future.delayed(timeout, () => throw TimeoutException('Ad load timed out')),
      ]);
    } on TimeoutException {
      print('Ad load timed out after $timeout');
      // Handle the timeout case (e.g., show a no-ad UI)
      if (ctx != null) {
        hasShownAd = true;

        Navigator.pop(ctx!);
      }
    }
  }

  showAd() {
    appOpenAd?.show().then((value) async {
      hasShownAd = true;
      if (ctx != null) {
        Navigator.pop(ctx!);
      }
      // bool? isFirst = await ConfigStorage.getIsFirstTime();
      // if (!Provider.of<RunningStateProvider>(context, listen: false).isPaid &&
      //     isFirst == false) {
      //   showProVersionDialog(context);
      // }
    });
  }

  // void showAdIfAvailable() {
  //   // Set the fullScreenContentCallback and show the ad.
  //   appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       print('$ad onAdShowedFullScreenContent');
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       print('$ad onAdFailedToShowFullScreenContent: $error');

  //       ad.dispose();
  //       appOpenAd = null;
  //     },
  //     onAdDismissedFullScreenContent: (ad) {
  //       print('$ad onAdDismissedFullScreenContent');

  //       ad.dispose();
  //       appOpenAd = null;
  //       // loadAd();
  //     },
  //     onAdWillDismissFullScreenContent: (ad) {
  //       print('$ad onAdWillDismissFullScreenContent');
  //     },
  //     onAdImpression: (ad) {
  //       logEvent("af_ad_view", {"af_adrev_ad_type": "App_Open"});
  //     },
  //     onAdClicked: (ad) {
  //       logEvent("af_ad_click", {"af_adrev_ad_type": "App_Open"});
  //     },
  //   );
  // }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return appOpenAd != null;
  }
}

// final appOpenAdManager = AppOpenAdManager();
