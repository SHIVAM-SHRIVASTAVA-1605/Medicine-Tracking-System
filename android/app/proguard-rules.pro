## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }

## Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }
-dontwarn com.dexterous.**

## Notification Service
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

## Preserve notification receivers
-keep public class * extends android.content.BroadcastReceiver
-keep class com.dexterous.flutterlocalnotifications.** { *; }

## Keep notification models
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

## Hive Database - CRITICAL for delete operations
-keep class * extends com.hivedb.** { *; }
-keep class com.hivedb.** { *; }
-keepclassmembers class * extends com.hivedb.** { *; }
-dontwarn com.hivedb.**

## Keep all model classes for Hive
-keep class * {
    @com.hivedb.HiveField *;
}
-keepclassmembers class * {
    @com.hivedb.HiveField *;
}

## Provider State Management
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * implements androidx.lifecycle.LifecycleObserver { *; }

## Prevent stripping of error handling
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

## Keep generic signature of Dart objects (prevents type erasure issues)
-keepattributes InnerClasses,EnclosingMethod
