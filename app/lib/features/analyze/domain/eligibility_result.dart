/// Domain mirror of the backend `EligibilityResult` contract (section 2.2).
///
/// Responsibility: enforce, at construction time, the invariants that make
/// an eligibility decision trustworthy — an eligible result always names a
/// real authorization source; an ineligible one never carries formats.
library;

import '../../../core/domain/value_objects/license.dart';
import '../../../core/domain/value_objects/media_format.dart';
import 'authorization_source.dart';

/// Authorization decision for one analyzed URL.
final class EligibilityResult {
  /// Builds a decision, enforcing the eligible/ineligible invariants.
  EligibilityResult({
    required this.eligible,
    required this.source,
    required this.reason,
    this.license,
    List<MediaFormat> availableFormats = const [],
    List<String> restrictions = const [],
  })  : availableFormats = List.unmodifiable(availableFormats),
        restrictions = List.unmodifiable(restrictions) {
    if (eligible && source == AuthorizationSource.none) {
      throw ArgumentError(
        'an eligible result must name its authorization source',
      );
    }
    if (!eligible && source != AuthorizationSource.none) {
      throw ArgumentError('an ineligible result cannot claim a source');
    }
    if (!eligible && this.availableFormats.isNotEmpty) {
      throw ArgumentError('an ineligible result cannot offer formats');
    }
    if (eligible && this.availableFormats.isEmpty) {
      throw ArgumentError('an eligible result must offer at least one format');
    }
    if (reason.trim().isEmpty) {
      throw ArgumentError('reason is user-facing and must not be empty');
    }
  }

  /// Whether the download is authorized.
  final bool eligible;

  /// Legal basis of the decision; [AuthorizationSource.none] when ineligible.
  final AuthorizationSource source;

  /// Detected license, present when [source] is [AuthorizationSource.openLicense].
  final License? license;

  /// User-readable explanation of the decision (both outcomes).
  final String reason;

  /// Real renditions offered by the origin. Empty when ineligible.
  final List<MediaFormat> availableFormats;

  /// License obligations to surface on the result card, e.g.
  /// "atribuição obrigatória".
  final List<String> restrictions;
}
