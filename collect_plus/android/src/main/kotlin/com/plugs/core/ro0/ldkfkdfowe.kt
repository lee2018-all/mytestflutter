package core.ro0

import androidx.annotation.Keep
import com.google.gson.Gson

@Keep
class kvcxh {
    var dataList: List<messageModel>? = null
    var otherData: String ? = null
    var exception: Exception ? = null

    override fun toString(): String {
        val gson = Gson()
        return gson.toJson(this)
    }
}


@Keep
data class messageModel (
    var content: String,
    var time: String,
    var name: String,
    var TYPE: String
)