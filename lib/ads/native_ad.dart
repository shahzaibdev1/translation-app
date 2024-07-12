import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';

class NativeAdWidget extends StatefulWidget {
  final double width; // Add your props here
  final double height; // Add your props here
  final double maxW; // Add your props here
  final double maxH; // Add your props here
  final TemplateType type;
  final String adId;

  const NativeAdWidget(
      {super.key,
      required this.width,
      required this.height,
      required this.maxW,
      required this.maxH,
      required this.type,
      required this.adId});

  @override
  State<NativeAdWidget> createState() => NativeAdWidgetState();
}

class NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? nativeAd;
  bool _nativeAdIsLoaded = false;

  // This is the test unit ID, only used when testing...

  final String _testAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  /// Loads a native ad.
  void loadAd() async {
    ThemeData currentTheme = Theme.of(context);
    ConsentStatus status = await ConsentInformation.instance.getConsentStatus();

    nativeAd = NativeAd(
        adUnitId: _testAdUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            print('$NativeAd failed to load: $error');
            ad.dispose();
          },
          onAdClicked: (ad) {
            // logEvent("af_ad_click", {"af_adrev_ad_type": "native"});
          },
          onAdImpression: (ad) {
            // logEvent("af_ad_view", {"af_adrev_ad_type": "native"});
          },
        ),
        request: AdRequest(
            nonPersonalizedAds:
                status == ConsentStatus.obtained || status == ConsentStatus.notRequired),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
            // Required: Choose a template.
            templateType: TemplateType.medium,
            // Optional: Customize the ad's style.
            mainBackgroundColor: currentTheme.dialogBackgroundColor,
            // cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.cyan,
                backgroundColor: Colors.red,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: currentTheme.textTheme.bodySmall?.color,
                backgroundColor: currentTheme.focusColor,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)));

    nativeAd?.load();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    loadAd();
  }

  @override
  Widget build(BuildContext context) {
    if (nativeAd != null && _nativeAdIsLoaded) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.width, // minimum recommended width
          minHeight: widget.height, // minimum recommended height
          maxWidth: widget.maxW,
          maxHeight: widget.maxH,
        ),
        child: AdWidget(ad: nativeAd!),
      );
    } else {
      return const SizedBox();
    }
  }
}
