# Keep rules for Google ML Kit text recognition
-keep class com.google.mlkit.** { *; }
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**
