import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';

class TranslationBannerAd extends StatefulWidget {
  final String size; // Add your props here

  const TranslationBannerAd({super.key, required this.size});

  @override
  State<TranslationBannerAd> createState() => _TranslationBannerAdState();

  // Factory constructor to create an instance with size
  factory TranslationBannerAd.fromSize(String size) {
    return TranslationBannerAd(size: size);
  }

  // Static method to get the size without creating an instance
  static int getSize(String size) {
    // Replace with your logic to determine the size
    switch (size) {
      case "full":
        return AdSize.fullBanner.height;
      case "large":
        return AdSize.largeBanner.height;
      case "medRect":
        return AdSize.mediumRectangle.height;
      default:
        return AdSize.fullBanner.height;
    }
  }
}

const String testAdUnitId = "ca-app-pub-3940256099942544/6300978111";

class _TranslationBannerAdState extends State<TranslationBannerAd> {
  BannerAd? _bannerAd;
  AdSize adSize = AdSize.fullBanner;

  // final String adUnitId = "ca-app-pub-4335977416487659/2750151685";

  /// Loads a banner ad.
  Future<void> loadAd() async {
    ConsentStatus status = await ConsentInformation.instance.getConsentStatus();

    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: testAdUnitId,
      size: size,
      request: AdRequest(
          nonPersonalizedAds:
              status == ConsentStatus.obtained || status == ConsentStatus.notRequired),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );

    return _bannerAd!.load();
  }

  // void loadAd() async {
  //   ConsentStatus status = await ConsentInformation.instance.getConsentStatus();

  //   _bannerAd = BannerAd(
  //     adUnitId: isTestAd ? testAdUnitId : adUnitId,
  //     request: AdRequest(
  //         nonPersonalizedAds:
  //             status == ConsentStatus.obtained || status == ConsentStatus.notRequired),
  //     size: adSize,
  //     listener: BannerAdListener(
  //       // Called when an ad is successfully received.
  //       onAdLoaded: (ad) {
  //         print('$ad loaded.');
  //         setState(() {});
  //       },
  //       // Called when an ad request failed.
  //       onAdFailedToLoad: (ad, err) {
  //         print("Banner Ad type: ${ad.adUnitId} ${ad.responseInfo}");
  //         print('BannerAd failed to load: $err');
  //         // Dispose the ad here to free resources.
  //         ad.dispose();
  //       },
  //       onAdClicked: (ad) {
  //         logEvent("af_ad_click", {"af_adrev_ad_type": "Banner"});
  //       },
  //       onAdImpression: (ad) {
  //         logEvent("af_ad_view", {"af_adrev_ad_type": "Banner"});
  //       },
  //     ),
  //   )..load();
  // }

  @override
  void initState() {
    super.initState();
    switch (widget.size) {
      case "full":
        adSize = AdSize.fullBanner;
        break;
      case "large":
        adSize = AdSize.largeBanner;
        break;
      case "medRect":
        adSize = AdSize.mediumRectangle;
        break;
    }

    loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
