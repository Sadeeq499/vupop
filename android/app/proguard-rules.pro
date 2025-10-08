# Keep video_thumbnail plugin
-keep class io.flutter.plugins.videothumbnail.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep plugin registrations
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep Flutter engine
-keep class io.flutter.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep video thumbnail specific classes (conditional)
-if class com.example.video_thumbnail.**
-keep class com.example.video_thumbnail.** { *; }

# Prevent obfuscation of plugin channels (conditional)
-if class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler
-keep class * implements io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }

-if class * implements io.flutter.plugin.common.EventChannel$StreamHandler
-keep class * implements io.flutter.plugin.common.EventChannel$StreamHandler { *; }

# Keep all method channels and event channels
-keep class io.flutter.plugin.common.** { *; }

# More specific Flutter plugin rules
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep plugin platform channels
-keep class * extends io.flutter.plugin.common.MethodChannel { *; }
-keep class * extends io.flutter.plugin.common.EventChannel { *; }