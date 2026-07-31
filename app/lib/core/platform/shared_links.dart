/// Conditional entry point for the shared-link adapter, mirroring
/// `platform_services.dart`: one import, one implementation per target,
/// and no `dart:io` reaching the web build.
library;

import 'shared_link_port.dart';
import 'shared_links_io.dart'
    if (dart.library.js_interop) 'shared_links_web.dart' as impl;

export 'shared_link_port.dart';

/// Creates the platform's shared-link port.
SharedLinkPort createSharedLinkPort() => impl.createSharedLinkPort();
