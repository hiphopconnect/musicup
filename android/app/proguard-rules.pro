# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter Engine
-dontwarn io.flutter.embedding.**

# Keep plugin classes
-keep class * extends io.flutter.plugin.common.MethodChannel { *; }
-keep class * extends io.flutter.plugin.common.EventChannel { *; }

# Keep JSON serialization classes
-keepattributes *Annotation*
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep HTTP client classes
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Optimize but keep essential classes
-allowaccessmodification
-repackageclasses ''