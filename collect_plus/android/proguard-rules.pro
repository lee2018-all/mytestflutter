# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

-packageobfuscationdictionary 'output_dict.txt'
-classobfuscationdictionary 'output_dict.txt'
-obfuscationdictionary 'output_dict.txt'
-dontwarn java.lang.invoke.StringConcatFactory

-keep class com.plugs.core.Bridge{*;}

-optimizationpasses 7
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers
-dontpreverify
-verbose
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!code/allocation/variable,!field/,!class/merging/
-keepattributes Annotation

#-assumenosideeffects class android.util.Log {
#
#    public static *** d(...);
#
#    public static *** v(...);
#
#    public static *** i(...);
#
#    public static *** e(...);
#
#    public static *** w(...);
#
#}

-keepattributes Signature
###---------------End: proguard configuration for fastjson  ----------
##如果有引用v4包可以添加下面这行
#-keep public class * extends android.support.v4.app.Fragment
##忽略警告
#-ignorewarning
-dump class_files.txt
-printseeds seeds.txt
##列出从 apk 中删除的代码
#-printusage unused.txt
##混淆前后的映射
#-printmapping mapping.txt


# androidx 混淆
-keep class com.google.android.material.** {*;}
-keep class androidx.** {*;}
-keep public class * extends androidx.**
-keep interface androidx.** {*;}
-dontwarn com.google.android.material.**
-dontnote com.google.android.material.**
-dontwarn androidx.**
-printconfiguration
-keep,allowobfuscation interface androidx.annotation.Keep

-keep @androidx.annotation.Keep class *
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}