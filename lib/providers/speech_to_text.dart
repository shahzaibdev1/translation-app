import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextProvider extends ChangeNotifier {
  String status = "notListening";
  final SpeechToText _speechToText = SpeechToText();
  int idx = 0;

  SpeechToTextProvider() {
    initialize();
  }

  void initialize() async {
    await _speechToText.initialize(
        onStatus: (status) {
          this.status = status;
          print("Status: $status");

          notifyListeners();
        },
        onError: (errorNotification) {
          print("Error: ${errorNotification.errorMsg}");
          idx = 0;
        },
        debugLogging: true);
  }

  void startListening({required onResult, required int idx}) async {
    this.idx = idx;
    await _speechToText.listen(
        onResult: (result) {
          print(result.recognizedWords);
          onResult(result);
          notifyListeners();
        },
        pauseFor: const Duration(seconds: 10),
        listenOptions: SpeechListenOptions(
            cancelOnError: true, partialResults: false, listenMode: ListenMode.dictation));
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
