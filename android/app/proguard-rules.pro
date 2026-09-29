# Flutter Engine & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

# Play Core & Deferred Components
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# InAppWebView & Stealth Browser Engine
-keep class com.pichillilorenzo.flutter_inappwebview_android.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview_android.**
-keep class androidx.browser.customtabs.** { *; }
-dontwarn androidx.browser.customtabs.**
-keep class * extends android.webkit.WebView { *; }
-keep class * extends android.webkit.WebViewClient { *; }
-keep class * extends android.webkit.WebChromeClient { *; }
-dontwarn android.webkit.**

# Firebase & Google Services
-keepattributes *Annotation*
-keep public class * extends java.lang.Exception
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }

# Kotlin Coroutines & Attributes
-dontwarn kotlinx.coroutines.**
-keepattributes EnclosingMethod,InnerClasses,Signature

# Google Mobile Ads (AdMob)
-keep public class com.google.android.gms.ads.** {
   public *;
}
-keep public class com.google.ads.** {
   public *;
}
-dontwarn com.google.android.gms.ads.**

# Google Play Install Referrer
-keep class com.android.installreferrer.** { *; }
-dontwarn com.android.installreferrer.**
