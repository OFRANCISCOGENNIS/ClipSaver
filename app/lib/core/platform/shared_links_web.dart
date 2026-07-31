/// Web adapter for [SharedLinkPort].
///
/// The Web Share Target API needs a manifest entry and a service-worker
/// handler, and it only fires for an installed PWA. Until that exists, an
/// honest no-op: the Analyze screen still accepts a pasted link.
library;

import 'shared_link_port.dart';

/// Creates the shared-link port for the web build.
SharedLinkPort createSharedLinkPort() => const NoopSharedLinkPort();
