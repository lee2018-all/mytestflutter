package core.kutl

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import com.plugs.core.util.Utils


object BatteryUtils {

    private val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
        Utils.getApp().registerReceiver(null, ifilter)
    }


    fun isCharging(): Boolean{
        val status: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        return status == BatteryManager.BATTERY_STATUS_CHARGING
                || status == BatteryManager.BATTERY_STATUS_FULL
    }

    fun isUsbCharge(): Boolean {
        val chargePlug: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1
        return chargePlug == BatteryManager.BATTERY_PLUGGED_USB
    }

    fun isAcCharge(): Boolean {
        val chargePlug: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1
        return chargePlug == BatteryManager.BATTERY_PLUGGED_AC
    }

    fun getBatteryPct(): Float? {
        return batteryStatus?.let { intent ->
            val level: Int = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale: Int = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            level * 100 / scale.toFloat()
        }
    }

    fun getBatteryCapacity(activity: Activity): String {
        val asdfcewmPowerProfile: Any
        var asdfcewcapacity = 0.0
        val asdfcewPOWER_PROFILE_CLASS = "com.android.internal.os.PowerProfile"
        try {
            asdfcewmPowerProfile = Class.forName(asdfcewPOWER_PROFILE_CLASS)
                    .getConstructor(Context::class.java)
                    .newInstance(activity)
            asdfcewcapacity = Class.forName(asdfcewPOWER_PROFILE_CLASS)
                    .getMethod("getBatteryCapacity")
                    .invoke(asdfcewmPowerProfile) as Double
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return "$asdfcewcapacity mAh"

    }
}