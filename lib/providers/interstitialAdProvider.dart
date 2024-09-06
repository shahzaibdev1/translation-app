import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/utils/utils.dart';

const String testAdUnitId = "ca-app-pub-3940256099942544/1033173712";

class InterStitialAdProvider extends ChangeNotifier {
  InterstitialAd? _interstitialAd;
  final String adUnitId = "ca-app-pub-4335977416487659/7155666096";

  // Any other state management logic can go here

  Future<void> loadAd({Function? callback, BuildContext? context}) async {
    // bool? isPaid = !Provider.of<RunningStateProvider>(context, listen: false).isPaid;
    ConsentStatus status = await ConsentInformation.instance.getConsentStatus();

    // if (isPaid != true) {
    return await InterstitialAd.load(
        adUnitId: isTestAd ? testAdUnitId : adUnitId,
        request: AdRequest(
            nonPersonalizedAds:
                status == ConsentStatus.obtained || status == ConsentStatus.notRequired),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {
              print("object showed full screen content");
            },
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {
              // logEvent("af_ad_view", {"af_adrev_ad_type": "Interstitial"});
              print("object had impresion onAdImpression");
            },
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
              print("object failed to show full screen content");
              // Dispose the ad here to free resources.
              ad.dispose();
              _interstitialAd?.dispose();
              // loadAd();
            },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
              print("object dismissed full screen content");
              // Dispose the ad here to free resources.
              ad.dispose();
              _interstitialAd?.dispose();
              if (context != null) {
                Provider.of<InterStitialAdProvider>(context, listen: false)
                    .loadAd(context: context);
              }

              // loadAd();
            },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {
              // logEvent("af_ad_click", {"af_adrev_ad_type": "Interstitial"});
              print("object clicked onAdClicked");
              ad.dispose();
              _interstitialAd?.dispose();

              // loadAd();
            });

            debugPrint('$ad loaded.');

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
            if (callback != null) {
              _interstitialAd?.show();
            }
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  // }

  InterstitialAd? getAd() {
    return _interstitialAd;
  }

  openAd() async {
    // bool? isPaid = !Provider.of<RunningStateProvider>(context, listen: false).isPaid;

    // if (isPaid) {
    try {
      await _interstitialAd?.show();
      debugPrint("object did show up ads");
    } catch (e) {
      loadAd();
      debugPrint("object did not show up ads $e");
    }
    // }
  }
}
