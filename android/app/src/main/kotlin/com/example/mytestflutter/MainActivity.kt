package com.example.mytestflutter



import io.flutter.embedding.android.FlutterActivity
import android.annotation.SuppressLint
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


//get device id
import android.provider.Settings

//get call log
import androidx.core.app.ActivityCompat
import android.content.ContentResolver
import android.provider.CallLog
import android.database.Cursor
import java.util.*

//get Battery
import android.content.Context

//get app list
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import java.text.SimpleDateFormat

//DES

import android.Manifest
import android.content.Context.MODE_PRIVATE
import android.os.Bundle
import android.os.PersistableBundle
import android.view.Window
import android.view.WindowManager
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity(){

    private  val scope = CoroutineScope(Dispatchers.Main)


    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }




    @SuppressLint("WrongConstant", "HardwareIds", "QueryPermissionsNeeded")
    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "AndroidId").setMethodCallHandler {call, result ->
            when (call.method) {
                "getAndroidId" -> scope.launch {
                    try {
                        val androidId = withContext(Dispatchers.IO) {
                            Settings.Secure.getString(
                                contentResolver,
                                Settings.Secure.ANDROID_ID
                            )
                        }
                        result.success(androidId)
                    } catch (e: Exception) {
                        result.notImplemented()
                    }
                }

                else -> result.notImplemented()
            }

        }


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "des_encryption").setMethodCallHandler {call, result ->
            when (call.method) {
                "encryptDES" -> scope.launch {
                    val plaintext = call.argument<String>("plaintext")
                    val key = call.argument<String>("key")
                    if (plaintext != null && key != null) {
                        try {
                            val encrypted = withContext(Dispatchers.IO) {
                                DESTool().encrypt(plaintext,key)
                            }
                            result.success(encrypted)

                        } catch (e: Exception) {
                            result.error("ENCRYPTION_FAILED", e.message, null)

                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Plain text or key is null", null)
                    }
                }


                "decryptDES" -> scope.launch {
                    val plaintext = call.argument<String>("plaintext")
                    val key = call.argument<String>("key")
                    if (plaintext != null && key != null) {
                        val plaintextBytes = DESTool().hexStr2ByteArr(plaintext)
                        try {
                            val decrypted = withContext(Dispatchers.IO) {
                                DESTool().decrypt(plaintextBytes,key)
                            }


                            if (decrypted != null) {
                                val resultString = String(decrypted, Charsets.UTF_8)
                                result.success(resultString)
                            } else {
                                result.error("DECRYPTION_FAILED", "Decrypt returned null", null)
                            }


                        } catch (e: Exception) {
                            result.error("ENCRYPTION_FAILED", e.message, null)

                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Plain text or key is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }


        MethodChannel(flutterEngine.dartExecutor, "BatteryCapacity").setMethodCallHandler {call, result ->
            when (call.method) {
                "getBatteryCapacity" -> scope.launch {

                    val capacity = withContext(Dispatchers.IO) {
                        getEstimatedBatteryCapacity(context)
                    }
                    result.success(capacity)

                }
                else -> result.notImplemented()
            }
        }


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "InstalledApps").setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> scope.launch {
                    try {
                        val  apps = withContext(Dispatchers.IO) {
                            loadInstalledApps()
                        }
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ENCRYPTION_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }



        MethodChannel(
            flutterEngine.dartExecutor,
            "native_permission"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isCallLogPermissionGranted" -> {
                    val prefs = getSharedPreferences("CallLogPermissionPrefs", MODE_PRIVATE)
                    val hasRequested = prefs.getBoolean("permission_requested", false)
                    val granted = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_CALL_LOG
                    ) == PackageManager.PERMISSION_GRANTED

                    val shouldShowRationale = shouldShowRequestPermissionRationale(
                        Manifest.permission.READ_CALL_LOG
                    )



                    if (!hasRequested) {
                        result.success(0)
                    } else if (!shouldShowRationale && !granted) {
                        result.success(3)
                    } else if (shouldShowRationale && !granted) {
                        result.success(1)
                    } else {
                        result.success(2)
                    }
                }

                else -> result.notImplemented()
            }
        }





        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "permission_channel").setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPureCallLog" -> {
                    checkAndRequestCallLogPermission(result)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.calllog").setMethodCallHandler { call, result ->
            when (call.method) {
                "getCallLogs" -> scope.launch {
                    try {
                        val  callLogs = withContext(Dispatchers.IO) {
                            val args = call.arguments as Map<*, *>
                            getCallLogsLast30Days(args["index"]as Int)
                        }
                        result.success(callLogs)
                    } catch (e: Exception) {
                        result.error("ENCRYPTION_FAILED", e.message, null)
                    }

                }
                else -> result.notImplemented()
            }
        }

    }

    private fun getCallLogsLast30Days(index: Int): List<Map<String, Any>> {
        val callLogs = mutableListOf<Map<String, Any>>()
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, 0-index) // 30 days ago
        val date30DaysAgo = calendar.timeInMillis
        val contentResolver: ContentResolver = contentResolver
        val cursor: Cursor? = contentResolver.query(
            CallLog.Calls.CONTENT_URI,
            null,
            "${CallLog.Calls.DATE} > ?",
            arrayOf(date30DaysAgo.toString()),
            "${CallLog.Calls.DATE} DESC"
        )
        cursor?.use {
            val nameIndex = it.getColumnIndex(CallLog.Calls.CACHED_NAME)
            val numberIndex = it.getColumnIndex(CallLog.Calls.NUMBER)
            val typeIndex = it.getColumnIndex(CallLog.Calls.TYPE)
            val dateIndex = it.getColumnIndex(CallLog.Calls.DATE)
            val durationIndex = it.getColumnIndex(CallLog.Calls.DURATION)
            while (it.moveToNext()) {
                val name = if (nameIndex != -1) it.getString(nameIndex) ?: "" else ""
                val number = if (numberIndex != -1) it.getString(numberIndex) ?: "" else ""
                val type = if (typeIndex != -1) it.getInt(typeIndex) else 0
                val date = if (dateIndex != -1) it.getLong(dateIndex) else 0L
                val duration = if (durationIndex != -1) it.getLong(durationIndex) else 0L
                val stringBuilder = StringBuilder("")
                when (type) {
                    1 -> {
                        stringBuilder.append("incoming call")
                    }
                    2 -> {
                        stringBuilder.append("outgo call")
                    }
                    3 -> {
                        stringBuilder.append("missed call")
                    }
                    4 -> {
                        stringBuilder.append("voicemail")
                    }
                    5 -> {
                        stringBuilder.append("rejected call")
                    }
                    6 -> {
                        stringBuilder.append("blocked")
                    }
                    else -> {
                        stringBuilder.append("answered_externally")
                    }
                }
                val apptype = stringBuilder.toString()
                callLogs.add(mapOf(
                    "name" to name,
                    "matched_number" to number,
                    "formatted_number" to number,
                    "type" to apptype,
                    "date" to date,
                    "duration" to duration
                ))
            }
        }
        return callLogs
    }


    @SuppressLint("PrivateApi")
    private fun getEstimatedBatteryCapacity(context: Context): Int {
        val powerProfileClass = Class.forName("com.android.internal.os.PowerProfile")

        val mPowerProfile: Any = try {
            powerProfileClass
                .getConstructor(Context::class.java)
                .newInstance(context)

        } catch (e: Exception) {
            return -1


        }

        return try {
            powerProfileClass
                .getMethod("getBatteryCapacity")
                .invoke(mPowerProfile) as Double
        } catch (e: Exception) {
            -1
        }.toInt()
    }


    @Suppress("UNREACHABLE_CODE")
    private fun getInstallTime(packageName: String): String {
        return try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(0)
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, 0)
            }
            val installTime = Date(packageInfo.firstInstallTime)
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
            return dateFormat.format(installTime)
        } catch (e: PackageManager.NameNotFoundException) {
            return  ""
        }
    }


    @SuppressLint("QueryPermissionsNeeded")
    @Suppress("DEPRECATION")
    private suspend fun loadInstalledApps(): List<Map<String, Any?>> = withContext(Dispatchers.IO) {
        val pm = application.packageManager
        val  apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        apps.map { app ->
            val flags = app.flags
            val isSystem = (flags and ApplicationInfo.FLAG_SYSTEM) != 0

            mapOf(
                "name" to pm.getApplicationLabel(app).toString(),
                "id" to app.packageName,
                "isSystem" to isSystem,
                "installTime" to getInstallTime(app.packageName)
            )

        }


    }

    private fun checkAndRequestCallLogPermission(result: MethodChannel.Result) {

        val prefs = getSharedPreferences("CallLogPermissionPrefs", MODE_PRIVATE)
      prefs.edit().putBoolean("permission_requested", true).apply()
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_CALL_LOG
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
        } else {

            permissionResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.READ_CALL_LOG),
                1001
            )
        }
    }


    private var permissionResult: MethodChannel.Result? = null

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == 1001) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                permissionResult?.success(true)
            } else {
                permissionResult?.success(false)
            }
            permissionResult = null
        }
    }



}




//