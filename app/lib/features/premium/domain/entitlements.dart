/// What the current plan allows (section 14).
///
/// Responsibility: be the single place that answers "can the user do
/// this?". Scattering `if (isPremium)` through the codebase is how a
/// paywall ends up inconsistent — and how a free user silently gets a
/// paid feature, or worse, a paying one gets blocked.
library;

/// Subscription tiers.
enum SubscriptionPlan {
  /// No subscription.
  free,

  /// Paid subscription, including an active trial.
  premium,
}

/// How much of the AI feature set is available (section 15).
enum AiTier {
  /// Free tier: title suggestions and duplicate detection only.
  limited,

  /// Everything, including auto-organization and storage optimization.
  full,
}

/// The 7-day trial (section 14: "teste grátis de 7 dias com aviso antes
/// da cobrança").
final class TrialStatus {
  /// Creates a trial that started at [startedAt].
  TrialStatus({required this.startedAt});

  /// Length of the free trial.
  static const Duration length = Duration(days: 7);

  /// When the trial began.
  final DateTime startedAt;

  /// When the first charge happens.
  DateTime get chargesAt => startedAt.add(length);

  /// Whether the trial still covers [now].
  bool isActive(DateTime now) => now.isBefore(chargesAt);

  /// Days left, floored at zero.
  int daysRemaining(DateTime now) {
    final remaining = chargesAt.difference(now).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Whether the pre-charge warning is due.
  ///
  /// Section 14 forbids dark patterns, so the warning fires while there is
  /// still time to cancel — not on the morning of the charge.
  bool shouldWarnBeforeCharge(DateTime now) =>
      isActive(now) && daysRemaining(now) <= 2;
}

/// The capability set of a plan.
final class Entitlements {
  /// Creates entitlements for [plan].
  const Entitlements({required this.plan, this.trial});

  /// Free-tier entitlements.
  static const Entitlements free = Entitlements(plan: SubscriptionPlan.free);

  /// Premium entitlements.
  static const Entitlements premium =
      Entitlements(plan: SubscriptionPlan.premium);

  /// The active plan.
  final SubscriptionPlan plan;

  /// Trial details, when one is running.
  final TrialStatus? trial;

  /// Whether paid features are unlocked.
  bool get isPremium => plan == SubscriptionPlan.premium;

  /// Parallel downloads allowed (section 14: 2 free, up to 8 premium).
  int get maxConcurrentDownloads => isPremium ? 8 : 2;

  /// Distinct tags allowed across the library (3 free, unlimited premium).
  int get maxTags => isPremium ? unlimitedTags : 3;

  /// Sentinel for "no limit", so callers compare instead of null-checking.
  static const int unlimitedTags = -1;

  /// Items a single batch download may contain (section 14).
  int get maxBatchItems => isPremium ? 100 : 0;

  /// Batch downloads of authorized playlists and feeds.
  bool get canBatchDownload => isPremium;

  /// Scheduled downloads.
  bool get canSchedule => isPremium;

  /// Saved smart searches.
  bool get canSaveSmartSearches => isPremium;

  /// Cross-device library sync (metadata only, never files).
  bool get canSyncLibrary => isPremium;

  /// Encrypted settings and library backup.
  bool get canBackup => isPremium;

  /// Batch conversion.
  bool get canBatchConvert => isPremium;

  /// How much of the AI feature set is on.
  AiTier get aiTier => isPremium ? AiTier.full : AiTier.limited;

  /// Whether [count] tags fit within the plan.
  bool allowsTagCount(int count) =>
      maxTags == unlimitedTags || count <= maxTags;

  /// Clamps a requested concurrency to what the plan allows, so a stale
  /// setting from a lapsed subscription cannot exceed the free limit.
  int clampConcurrency(int requested) {
    if (requested < 1) return 1;
    return requested > maxConcurrentDownloads
        ? maxConcurrentDownloads
        : requested;
  }

  @override
  bool operator ==(Object other) =>
      other is Entitlements && other.plan == plan && other.trial == trial;

  @override
  int get hashCode => Object.hash(plan, trial);
}
