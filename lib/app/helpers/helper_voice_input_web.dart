import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

class HelperVoiceInput {
  static bool get isSupported {
    final window = web.window as JSObject;
    return window.has('SpeechRecognition') ||
        window.has('webkitSpeechRecognition');
  }

  static void listenIndonesian({
    required void Function(String text) onResult,
    void Function()? onStart,
    void Function()? onEnd,
    void Function(Object error)? onError,
  }) {
    final window = web.window as JSObject;
    final constructor =
        window['SpeechRecognition'] ?? window['webkitSpeechRecognition'];

    if (constructor == null) {
      onError?.call(
        UnsupportedError('SpeechRecognition is not supported by this browser.'),
      );
      return;
    }

    final recognition = (constructor as JSFunction)
        .callAsConstructor<JSObject>();
    recognition['lang'] = 'id-ID'.toJS;
    recognition['interimResults'] = false.toJS;
    recognition['continuous'] = false.toJS;
    recognition['maxAlternatives'] = 1.toJS;

    recognition['onstart'] = (() {
      onStart?.call();
    }).toJS;

    recognition['onend'] = (() {
      onEnd?.call();
    }).toJS;

    recognition['onerror'] = ((JSAny event) {
      final eventObject = event as JSObject;
      final error = eventObject['error'] as JSString?;
      onError?.call(error?.toDart ?? 'Speech recognition failed.');
      onEnd?.call();
    }).toJS;

    recognition['onresult'] = ((JSAny event) {
      try {
        final eventObject = event as JSObject;
        final results = eventObject['results'] as JSObject;
        final firstResult = results['0'] as JSObject;
        final firstAlternative = firstResult['0'] as JSObject;
        final transcript = firstAlternative['transcript'] as JSString?;
        final text = transcript?.toDart.trim() ?? '';
        if (text.isNotEmpty) onResult(text);
      } catch (e) {
        onError?.call(e);
      }
    }).toJS;

    try {
      recognition.callMethod<JSAny?>('start'.toJS);
    } catch (e) {
      onError?.call(e);
      onEnd?.call();
    }
  }
}
