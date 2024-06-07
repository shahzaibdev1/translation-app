import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeachToTextProvider extends ChangeNotifier {
  String status = "notListening";
  final SpeechToText _speechToText = SpeechToText();
  int idx = 0;

  SpeachToTextProvider() {
    initialize();
  }

  void initialize() async {
    await _speechToText.initialize(
        onStatus: (status) {
          this.status = status;
          print("$status, status");
          notifyListeners();
        },
        onError: (errorNotification) {
          print(errorNotification.errorMsg);
          idx = 0;
        },
        debugLogging: true);
  }

  void startListening({required onResult, required int idx}) async {
    this.idx = idx;
    await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          print(result.recognizedWords);
          // this.status = "listening";
          notifyListeners();
        },
        listenOptions: SpeechListenOptions(
            cancelOnError: true, partialResults: false, listenMode: ListenMode.confirmation));
  }

  void stopListening() async {
    idx = 0;
    await _speechToText.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
