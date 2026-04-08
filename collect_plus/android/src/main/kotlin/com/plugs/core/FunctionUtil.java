package com.plugs.core;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.database.Cursor;
import android.net.Uri;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Environment;
import android.provider.CalendarContract;
import android.provider.MediaStore;
import android.provider.Settings;
import android.text.format.DateUtils;
import android.util.Log;

import androidx.core.os.EnvironmentCompat;

import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class FunctionUtil {


    /**
     * no 0
     *
     * @param data double
     * @return
     */
    public static String getnozero(String data) {
        BigDecimal value = new BigDecimal(data);
        BigDecimal noZeros = value.stripTrailingZeros();
        String result = noZeros.toPlainString();

        return result;


    }



    public static boolean isDebugApp(Context context) {
        try {
            ApplicationInfo info = context.getApplicationInfo();
            return (info.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
        } catch (Exception x) {
            return false;
        }
    }

    public static List<ResolveInfo> getBrowserList(Context context) {
        PackageManager packageManager = context.getPackageManager();

        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse("http://"));

        List<ResolveInfo> activities = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL);

        return activities;
    }

    public static List<BrowerInfo> getBrowserList2(Context context) {
        PackageManager packageManager = context.getPackageManager();

        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse("http://"));
            List<BrowerInfo> browerInfoList=new ArrayList<>();
        List<ResolveInfo> activities = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL);
        for (ResolveInfo resolveInfo:activities
             ) {
            String browserName = resolveInfo.loadLabel(packageManager).toString();

            BrowerInfo browerInfo=new BrowerInfo(browserName);
            browerInfoList.add(browerInfo);
        }
        return browerInfoList;
    }

    public static class BrowerInfo implements Serializable {
        public BrowerInfo(String browserName) {
            this.browserName = browserName;
        }

        public String browserName;


    }

    public static boolean isPad(Context context) {
        return (context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_LARGE;
    }

    private static String CALENDER_EVENT_URL = "content://com.android.calendar/events";

    public static Uri remindersUri = CalendarContract.Reminders.CONTENT_URI;

    public static String getAndroid(Context context) {
        String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        return androidId;
    }

    public static long getLong(String s) {
        String date = "2017-01-18 16:50:50";

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");//
        try {
            long dateToSecond = sdf.parse(s).getTime();//sdf.parse()
            return dateToSecond;
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return 0;
    }



    public static String timeStamp2Date(long time) {
        String format = "yyyy-MM-dd HH:mm:ss";
        SimpleDateFormat sdf = new SimpleDateFormat(format);
        return sdf.format(new Date(time));
    }




    public static Uri createImageUri(Context context) {
        String status = Environment.getExternalStorageState();

        if (status.equals(Environment.MEDIA_MOUNTED)) {
            return context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, new ContentValues());
        } else {
            return context.getContentResolver().insert(MediaStore.Images.Media.INTERNAL_CONTENT_URI, new ContentValues());
        }
    }


    public static File createImageFile(String usercode, Context context) throws IOException {
        String imageName = new SimpleDateFormat("yyyyMMdd_HHmmss-" + usercode, Locale.getDefault()).format(new Date());
        File storageDir = context.getCacheDir();
        if (!storageDir.exists()) {
            storageDir.mkdir();
        }
        File tempFile = new File(storageDir, imageName + ".jpg");
        if (!Environment.MEDIA_MOUNTED.equals(EnvironmentCompat.getStorageState(tempFile))) {
            return null;
        }
        return tempFile;
    }


    public static String getJson(Context context, String fileName){
        StringBuilder stringBuilder = new StringBuilder();

        AssetManager assetManager = context.getAssets();

        try {
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(
                    assetManager.open(fileName),"utf-8"));
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                stringBuilder.append(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return stringBuilder.toString();
    }

    public static List<ScanResult> getWifiList(Context context) {
        List<ScanResult> wifiList = new ArrayList<>();

        return wifiList;
    }



    public static String intIP2StringIP(int ip) {
        return (ip & 0xFF) + "." +
                ((ip >> 8) & 0xFF) + "." +
                ((ip >> 16) & 0xFF) + "." +
                (ip >> 24 & 0xFF);
    }
}
