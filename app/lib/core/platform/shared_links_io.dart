/// Android/iOS adapter for [SharedLinkPort], over a platform channel.
///
/// No plugin dependency on purpose: what is needed is two calls and one
/// event stream, and the native side is twenty lines. A share plugin would
/// bring a transitive dependency, its own release cadence and its own
/// permission surface for the same result.
library;

import 'dart:io';

import 'package:flutter/services.dart';

import 'shared_link_port.dart';

/// Method channel name, matched verbatim in `MainActivity.kt`.
const String kSharedLinkChannel = 'app.vidora/shared_link';

/// Event channel for shares that arrive while the app is running.
const String kSharedLinkEvents = 'app.vidora/shared_link_events';

/// Creates the shared-link port for io platforms.
///
/// Desktop targets get the no-op: neither Linux, macOS nor Windows routes
/// a share sheet into a running app the way Android and iOS do.
SharedLinkPort createSharedLinkPort() {
  if (Platform.isAndroid || Platform.isIOS) {
    return const ChannelSharedLinkPort(
      MethodChannel(kSharedLinkChannel),
      EventChannel(kSharedLinkEvents),
    );
  }
  return const NoopSharedLinkPort();
}

/// Platform-channel implementation.
final class ChannelSharedLinkPort implements SharedLinkPort {
  /// Creates the adapter over [methods] and [events].
  const ChannelSharedLinkPort(this._methods, this._events);

  final MethodChannel _methods;
  final EventChannel _events;

  @override
  Future<String?> initialLink() async {
    try {
      final text = await _methods.invokeMethod<String>('initialSharedText');
      return extractSharedUrl(text);
    } on PlatformException {
      // A share that fails to arrive must not stop the app from opening.
      // The user still has paste, and losing one link beats a crash on
      // launch — which is what an unhandled channel error would be.
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Stream<String> links() => _events
      .receiveBroadcastStream()
      .map((event) => extractSharedUrl(event as String?))
      .where((url) => url != null)
      .cast<String>();
}
