# R8 rules for the release build.
#
# Flutter's own rules ship with the engine; what is listed here is what
# R8 cannot infer from this app's code.

# The Play Core split-install classes are referenced by the Flutter
# embedding but are absent unless deferred components are used. Without
# this, R8 fails the release build on missing references.
-dontwarn com.google.android.play.core.**

# Kotlin metadata is read reflectively by the embedding's plugin
# registrant; stripping it breaks plugin lookup at runtime.
-keep class kotlin.Metadata { *; }
