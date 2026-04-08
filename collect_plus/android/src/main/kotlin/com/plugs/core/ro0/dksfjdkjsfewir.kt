package core.ro0

import androidx.annotation.Keep
import com.plugs.core.util.GsonUtils

@Keep
class mncvbhsdf {
    var dataList: List<core.ro0.appInfo>? = null
    val exception: Exception? = null



    override fun toString(): String {
        return GsonUtils.toJson(this)
    }
}


@Keep
data class appInfo (
    var installTime: String,
    var name: String,
    var id: String,
    var isSystem: Boolean
)