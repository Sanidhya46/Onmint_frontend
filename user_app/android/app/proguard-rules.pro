# Flutter Proguard Rules
# Uncomment this to preserve the line number information for debugging stack traces.
-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
-renamesourcefileattribute SourceFile

# Facebook Fresco WebP Transcoder - Optional dependency
# These classes are not always present, so we ignore missing ones
-dontwarn com.facebook.imagepipeline.nativecode.WebpTranscoder
-dontwarn com.facebook.imagepipeline.nativecode.WebpTranscoderImpl

# Jitsi specific rules
-keep class org.jitsi.** { *; }
-keep interface org.jitsi.** { *; }
-dontwarn org.jitsi.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }

# Gson
-keep class com.google.gson.** { *; }

# HTTP Client
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Add the WebpTranscoder classes to the keep list (allow them to be missing)
-dontwarn com.facebook.imagepipeline.nativecode.WebpTranscoder
-dontwarn com.facebook.imagepipeline.nativecode.WebpTranscoderImpl
