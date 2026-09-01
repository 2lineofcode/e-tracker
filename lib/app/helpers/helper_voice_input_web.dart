import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

class HelperVoiceInput {
  static JSObject? _recognition;

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
    stopListening();

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
    _recognition = recognition;
    recognition['lang'] = 'id-ID'.toJS;
    recognition['interimResults'] = true.toJS;
    recognition['continuous'] = false.toJS;
    recognition['maxAlternatives'] = 1.toJS;

    recognition['onstart'] = (() {
      onStart?.call();
    }).toJS;

    recognition['onend'] = (() {
      if (identical(_recognition, recognition)) {
        _recognition = null;
        onEnd?.call();
      }
    }).toJS;

    recognition['onerror'] = ((JSAny event) {
      final eventObject = event as JSObject;
      final error = eventObject['error'] as JSString?;
      onError?.call(error?.toDart ?? 'Speech recognition failed.');
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
      _recognition = null;
      onError?.call(e);
      onEnd?.call();
    }
  }

  static void stopListening() {
    final recognition = _recognition;
    if (recognition == null) return;

    try {
      recognition.callMethod<JSAny?>('stop'.toJS);
    } catch (_) {
      _recognition = null;
    }
  }

  static String errorMessage(Object error) {
    return switch (error.toString()) {
      'not-allowed' || 'service-not-allowed' =>
        'Izinkan akses mikrofon di browser',
      'audio-capture' => 'Mikrofon tidak ditemukan',
      'no-speech' => 'Suara tidak terdengar',
      'network' => 'Pengenalan suara butuh koneksi internet',
      _ => 'Pengenalan suara gagal',
    };
  }
}
