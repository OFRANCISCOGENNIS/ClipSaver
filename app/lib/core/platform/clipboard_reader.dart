/// Clipboard port (section 7.1: "detecção automática de URL no clipboard").
///
/// Responsibility: keep the ViewModel free of platform channels so the
/// paste-suggestion behavior is unit-testable.
library;

import 'package:flutter/services.dart';

/// Reads plain text from the system clipboard.
abstract interface class ClipboardReader {
  /// Current clipboard text, or null when empty/unavailable.
  Future<String?> readText();
}

/// Platform implementation backed by Flutter's [Clipboard].
final class SystemClipboardReader implements ClipboardReader {
  /// Creates the reader.
  const SystemClipboardReader();

  @override
  Future<String?> readText() async {
    // Reading the clipboard can throw on platforms where the channel is
    // unavailable (some Linux/Web setups); a suggestion is optional, so a
    // failure degrades to "no suggestion" rather than an error state.
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } on Object {
      return null;
    }
  }
}
