class HelperVoiceInput {
  static bool get isSupported => false;

  static void stopListening() {}

  static String errorMessage(Object error) => 'Pengenalan suara tidak didukung';

  static void listenIndonesian({
    required void Function(String text) onResult,
    void Function()? onStart,
    void Function()? onEnd,
    void Function(Object error)? onError,
  }) {
    onError?.call(
      UnsupportedError(
        'Voice input is only available on supported web browsers.',
      ),
    );
  }
}
