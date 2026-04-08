package core.kutl

import android.Manifest
import android.app.ActivityManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import android.text.format.Formatter
import androidx.annotation.RequiresPermission
import androidx.core.app.ActivityCompat
import com.plugs.core.util.Utils
import com.plugs.core.util.PhoneUtils
import com.plugs.core.util.ScreenUtils


object DeviceInfoUtils {


    fun getSDKVersionName(): String {
        return Build.VERSION.RELEASE
    }


    @RequiresPermission(Manifest.permission.READ_PHONE_STATE)
    fun getIMEI(): String {
        return if (ActivityCompat.checkSelfPermission(
                Utils.getApp(), Manifest.permission.READ_PHONE_STATE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ""
        } else {
            PhoneUtils.getIMEI()
        }
    }


    @RequiresPermission(Manifest.permission.READ_PHONE_STATE)
    fun getIMSI(): String? {
        return try {
            return PhoneUtils.getIMSI()
        } catch (e: SecurityException) {
            return ""
        }

    }


    fun getAndroidId(): String {
        var androidId =
            Settings.System.getString(Utils.getApp().contentResolver, Settings.Secure.ANDROID_ID)
        if (androidId == null) {
            androidId = ""
        }
        return androidId
    }


    fun getPhysicsScreenSize(): Double {
        val dpi = ScreenUtils.getScreenXDpi() + ScreenUtils.getScreenYDpi()
        return Math.sqrt(dpi.toDouble())
    }



    fun getSDCardTotalSize(): Long {
        val state = Environment.getExternalStorageState()
        var aaa: Long = 0
        if (Environment.MEDIA_MOUNTED == state) {
            val sdcardDir = Environment.getExternalStorageDirectory()
            val sf = StatFs(sdcardDir.path)
            aaa = sf.totalBytes
        }
        return aaa
    }


    fun getSDCardUsedSize(): Long {
        val state = Environment.getExternalStorageState()
        var aaa: Long = 0
        if (Environment.MEDIA_MOUNTED == state) {
            val sdcardDir = Environment.getExternalStorageDirectory()
            val sf = StatFs(sdcardDir.path)
            val blockSize = sf.blockSizeLong
            val blockCount = sf.blockCountLong
            val availCount = sf.availableBlocksLong
            aaa = (blockCount - availCount) * blockSize
        }
        return aaa
    }


    fun getSDCardAvailSize(): Long {
        val state = Environment.getExternalStorageState()
        var aaa: Long = 0
        if (Environment.MEDIA_MOUNTED == state) {
            val sdcardDir = Environment.getExternalStorageDirectory()
            val sf = StatFs(sdcardDir.path)
            aaa = sf.availableBytes
        }
        return aaa
    }


    fun getAvailableInternalSize(): Long {
        val path = Environment.getDataDirectory()
        val stat = StatFs(path.path)
        val blockSize = stat.blockSizeLong
        val availableBlocks = stat.availableBlocksLong
        return availableBlocks * blockSize
    }


    fun getInternalSize(): Long {
        val path = Environment.getDataDirectory()
        val stat = StatFs(path.path)
        val blockSize = stat.blockSizeLong
        val blockCount = stat.blockCountLong
        return blockCount * blockSize
    }


    fun getRAMTotalMemorySize(context: Context): Long {

        val mActivityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager

        val memoryInfo = ActivityManager.MemoryInfo()

        mActivityManager.getMemoryInfo(memoryInfo)
        var memSize: Long = 0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            memSize = memoryInfo.totalMem
        }

//        String availMemStr = formateFileSize(context, memSize);
        return memSize
    }

    fun getFreeRomSize(): Long{
        val externalStorage = Environment.getExternalStorageDirectory()
        return externalStorage.freeSpace
    }


    fun getTotalRomSize(): Long {
        return try {
            val path = Environment.getDataDirectory()
            val stat = StatFs(path.path)
            stat.blockCountLong * stat.blockSizeLong
        } catch (e: Exception) {
            e.printStackTrace()
            0
        }
    }

    fun Long.formateFileSize(): String {
        return Formatter.formatFileSize(Utils.getApp(), this)
    }


    fun getRAMAvaialbeMemorySize(context: Context): Long {

        val mActivityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()

        mActivityManager.getMemoryInfo(memoryInfo)

//        String availMemStr = formateFileSize(context, memSize);
        return memoryInfo.availMem
    }

}
