package core


import android.annotation.SuppressLint
import android.content.Context
import android.hardware.input.InputManager
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import android.telephony.SignalStrength
import android.telephony.TelephonyManager
import android.util.Log
import android.view.InputDevice
import com.plugs.core.util.DeviceUtils
import com.plugs.core.util.GsonUtils
import com.plugs.core.util.LanguageUtils
import com.plugs.core.util.NetworkUtils
import com.plugs.core.util.PhoneUtils
import com.plugs.core.util.ScreenUtils
import com.plugs.core.util.Utils
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import core.ro0.batteryInfo
import core.ro0.podkhffueuwior
import core.ro0.DeviceGeneralInfo
import core.ro0.DeviceHardwareInfo
import core.ro0.otherInfo
import core.ro0.DeviceStorageInfo
import core.kutl.BatteryUtils
import core.kutl.DeviceInfoUtils
import com.plugs.core.util.SPUtils
import io.flutter.BuildConfig
import kotlinx.coroutines.*
import java.io.File
import java.text.SimpleDateFormat
import java.util.*


/**
 * @Description:
 */

class CrawlDataUtil {
    companion object {
        private var mSingleton: CrawlDataUtil? = null
            get() {
                if (field == null) {
                    field = CrawlDataUtil()
                }
                return field
            }

        @Synchronized
        fun getInstance(): CrawlDataUtil {
            return mSingleton!!
        }
    }

    /**
     *
     * @return
     */
    suspend fun crawlData(): podkhffueuwior {
        //
        /*  if (!permissionsCheck()) {
              return null
          }*/

        return podkhffueuwior().apply {
            ymgwlIwsbIqzvjOlyoOzg = ArrayList<java.lang.Exception>()

            try {
                zmyFtfwHgds = getBatteryStatus()
            } catch (e: Exception) {
                android.util.Log.d("TAG", "crawlData: "+ e)
                ymgwlIwsbIqzvjOlyoOzg!!.add(e)
            }
            try {
                jqrbAusncYtcmCgap = getBatteryStatus()

            } catch (e: Exception) {
                ymgwlIwsbIqzvjOlyoOzg!!.add(e)
            }
            try {
                zinTwvxGzoVhdaqLtsx = getGenerateData()

            } catch (e: Exception) {
                ymgwlIwsbIqzvjOlyoOzg!!.add(e)
            }
            try {
                bplrVatdiLeptv = getHardware()

            } catch (e: Exception) {
                ymgwlIwsbIqzvjOlyoOzg!!.add(e)
            }
            try {
                kbkfOugBabFyfi = getOtherData()

            } catch (e: Exception) {
                ymgwlIwsbIqzvjOlyoOzg!!.add(e)
            }
            try {
                fctvwUjfejPqumLugWnfw = getStorage()

            } catch (e: Exception) {
                ymgwlIwsbIqzvjOlyoOzg!!.add(e)
            }
        }
    }

}

/**
 * Battery
 */
fun getBatteryStatus(): batteryInfo {

    return batteryInfo(
        ormbUfxhQfmVknx = BatteryUtils.isAcCharge(),
        yhckWbarSlnvUrs = BatteryUtils.getBatteryPct()?.toInt(),
        osgtxUznviJoxZogy = BatteryUtils.isCharging(),
        cgnsYpbtqYvwcGwy = BatteryUtils.isUsbCharge(),
        vozdfAkxooBwpxQmppd = null,
        iqmlYcwkxOasmItmviLgreh = null,
        bkrXfjbKttv = null,
        pcubkWrtFsjiYsp = null,
        flehClwIdnVsagMknzg = null,
    )
}

@SuppressLint("MissingPermission")
suspend fun getGenerateData(): DeviceGeneralInfo = withContext(Dispatchers.IO) {
    val generalInfo = DeviceGeneralInfo(
        ypsxkJzbfEsueeJnqopDoj = DeviceInfoUtils.getAndroidId(),
        ittHxkkRbsyb = "",
        mzsHvxzArq = DeviceInfoUtils.getIMEI(),
        xfzreRlbanOruYmjvTyso = DeviceInfoUtils.getIMSI(),
        sqcArgazWlpmfTyf = LanguageUtils.getSystemLanguage()?.displayLanguage,
        ymrZgfVyunfIwtZrnj = LanguageUtils.getAppliedLanguage()?.displayLanguage,
        cxuMrbwNfdNji = Locale.getDefault().isO3Country,
        bcsPkdUyu = Locale.getDefault().isO3Language,
        dlrmqEaxdmBcdbjOng = DeviceUtils.getMacAddress(),
        fwhIngvtGsxsa = NetworkUtils.getNetworkOperatorName(),
        uvecOmcosAlo = NetworkUtils.getNetworkType().name,
        lrkaDidRbrFyenc = PhoneUtils.getPhoneType().toString(),
        bjsvwYhkhxSncwjCrzwh = TimeZone.getDefault().id,
        etgzcXuysLjjc = DeviceUtils.getUniqueDeviceId()
    )
    generalInfo
}


//    /**
//     * google id - adjust
//     */
val defaultGoogleAdId = "00000000-0000-0000-0000-000000000000"

suspend fun getADIDTimeout(): String? {
    return null
    return try {
        withTimeoutOrNull(10 * 1000) {
            getADID()
        }
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

/**
 * get google ads ID
 */
suspend fun getADID(): String? = suspendCancellableCoroutine { coroutine ->
    @OptIn(DelicateCoroutinesApi::class)
    GlobalScope.launch(Dispatchers.IO) {
        try {
            val advertisingIdInfo = AdvertisingIdClient.getAdvertisingIdInfo(Utils.getApp())
            val id = advertisingIdInfo.id
            if (id != null && id != defaultGoogleAdId) {
                //serve id
                coroutine.resume(id, null)
            } else {
                coroutine.resume(null, null)
            }
            Log.i("getGoogleAdId", "Facebook googleAdId $id")
        } catch (e: Exception) {
            coroutine.resume(null, null)
        }

    }
}

/**
 * Hardware
 */
@SuppressLint("MissingPermission")
fun getHardware(): DeviceHardwareInfo {
    val abis = DeviceUtils.getABIs()
    return DeviceHardwareInfo(
        vrplhBrpQnjjqUtrj = if (abis.isNullOrEmpty()) null else abis.toList().toString(),
        iwsvkQabxEctdcCsvv = Build.BRAND,
        tfwwDdzjBgvtQxkltDxyer = Build.SUPPORTED_ABIS.toList().toString(),
        eperkNnuJldrb = Build.DEVICE,
        haydqBjqqPmkedZced = Build.DISPLAY,
        sfdXbwdQzqRzeb = Build.FINGERPRINT,
        tffsBcefwHdpshMpgxr = Build.HOST,
        oegwzWghvlHqlgObl = Build.MANUFACTURER,
        astUxbkFqrVrw = Build.MODEL,
        wknEmqxYebOgmRed = DeviceInfoUtils.getPhysicsScreenSize().toString(),
        dzfxTwhoVfgGipp = Build.PRODUCT,
        zmolEjgStnhBzky = Build.getRadioVersion(),
        baanLyggyAswq = Build.VERSION.RELEASE,
        fvmxVtenEdwoRly = ScreenUtils.getScreenDensity().toString(),
        mynyHftbcZqbbdRpxtm = ScreenUtils.getScreenDensityDpi().toString(),
        nxonEwooTwjCfhelDgwcl = ScreenUtils.getScreenHeight().toString(),
        qgaSpmOox = ScreenUtils.getScreenWidth().toString(),
        hghlhYbxtuAfciMoxhWsls = DeviceInfoUtils.getSDKVersionName(),
        mzsHvxzArq = DeviceInfoUtils.getIMEI(),
        vhjTacLfrp = Build.getRadioVersion(),
    )
}

fun getOtherData(): otherInfo {
    val dbmStr = StringBuilder()
    var signalStrength: SignalStrength? = null
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        signalStrength =
            (Utils.getApp().applicationContext.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager).signalStrength
    }
    if (signalStrength != null) {
        val asu = signalStrength.gsmSignalStrength
        dbmStr.append(-113 + 2 * asu)
    }

    // keyboard
    var keyboardName: String? = null
    val inputManager = Utils.getApp().getSystemService(Context.INPUT_SERVICE) as InputManager?
    if (inputManager != null) {
        val inputDeviceIds: IntArray = inputManager.getInputDeviceIds()
        val list = arrayListOf<String>()
        for (deviceId in inputDeviceIds) {
            val inputDevice: InputDevice = inputManager.getInputDevice(deviceId)!!

            val sources: Int = inputDevice.getSources()

            // iskeyboard
            if (sources and InputDevice.SOURCE_KEYBOARD == InputDevice.SOURCE_KEYBOARD) {
                list.add(inputDevice.name)
                Log.d("KeyboardInfo", "Keyboard Name: " + inputDevice.name);
            }
        }
        keyboardName = list.toString()
    }
    return otherInfo(
        flgsxOpcSjijtCgbge = dbmStr.toString(),
        iymoXhnhSgaIlm = BuildConfig.DEBUG,
        xlrbLqwUzuviTtg = isMockLocationEnabled(Utils.getApp()),
        vfrJlzrcKyjMfgnk = keyboardName,
        fscQhujzJlfjf = (System.currentTimeMillis() - SystemClock.elapsedRealtime()).simple(),
        fxprAmzaJwhKrothOdj = hasRootPrivilege(),
        rxluTtxjuGkph = DeviceUtils.isEmulator()
    )
}

fun isMockLocationEnabled(context: Context): Boolean {
    return Settings.Secure.getString(context.contentResolver, Settings.Secure.LOCATION_MODE)
        .equals("0")
}

/**
 *
 */
fun Long.simple(): String {
    val simpleDateFormat = SimpleDateFormat("yyyy/M/dd HH:mm:ss", Locale.getDefault())
    return simpleDateFormat.format(Date(this))
}

/**
 * is root
 * @return
 */

private val rootRelatedDirs = arrayOf(
    "/su",
    "/su/bin/su",
    "/sbin/su",
    "/data/local/xbin/su",
    "/data/local/bin/su",
    "/data/local/su",
    "/system/xbin/su",
    "/system/bin/su",
    "/system/sd/xbin/su",
    "/system/bin/failsafe/su",
    "/system/bin/cufsdosck",
    "/system/xbin/cufsdosck",
    "/system/bin/cufsmgr",
    "/system/xbin/cufsmgr",
    "/system/bin/cufaevdd",
    "/system/xbin/cufaevdd",
    "/system/bin/conbb",
    "/system/xbin/conbb"
)

fun hasRootPrivilege(): Boolean {
    var hasRootDir = false
    var rootDirs: Array<String>
    val dirCount = rootRelatedDirs.also { rootDirs = it }.size
    for (i in 0 until dirCount) {
        val dir = rootDirs[i]
        if (File(dir).exists()) {
            hasRootDir = true
            break
        }
    }
    return Build.TAGS != null && Build.TAGS.contains("test-keys") || hasRootDir
}


fun getStorage(): DeviceStorageInfo {
    return DeviceStorageInfo(
        yrbOymVmatrSzka = DeviceInfoUtils.getInternalSize().toString(),
        zkkjwIlesrDjcgxSdksFnpx = DeviceInfoUtils.getAvailableInternalSize().toString(),
        yzwzJpaPtuVzm = DeviceInfoUtils.getSDCardTotalSize().toString(),
        ktujTzdGbeze = DeviceInfoUtils.getSDCardAvailSize().toString(),
        oyomTasjBwxEmly = DeviceInfoUtils.getRAMTotalMemorySize(Utils.getApp()).toString(),
        ldrhmBorebJby = DeviceInfoUtils.getRAMAvaialbeMemorySize(Utils.getApp()).toString()
    )


}
