package com.example.mytestflutter




import android.annotation.SuppressLint
import java.security.Key
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec

class DESTool {

    @Throws(java.lang.Exception::class)
    fun encrypt(strIn: String, key: String): String? {
        return encrypt(strIn.toByteArray(),key)?.let { byteArr2HexStr(it) }
    }

    @Throws(Exception::class)
    fun byteArr2HexStr(arrB: ByteArray): String {
        val iLen = arrB.size
        val sb = StringBuffer(iLen * 2)
        for (i in 0 until iLen) {
            var intTmp = arrB[i].toInt()
            while (intTmp < 0) {
                intTmp += 256
            }
            if (intTmp < 16) {
                sb.append("0")
            }
            sb.append(intTmp.toString(16))
        }
        return sb.toString()
    }

    @SuppressLint("GetInstance")
    @Throws(java.lang.Exception::class)
    fun encrypt(arrB: ByteArray?,strKey: String): ByteArray? {
        val key: Key = getKey(strKey.toByteArray())
        val encryptCipher = Cipher.getInstance("DES")
        encryptCipher.init(Cipher.ENCRYPT_MODE, key)
        return encryptCipher.doFinal(arrB)
    }




    fun hexStr2ByteArr(hexStr: String): ByteArray {
        if (hexStr.isEmpty()) {
            return ByteArray(0)
        }
        //
        var str = hexStr
        if (str.length % 2 != 0) {
            str = "0$str"  //
        }

        val length = str.length / 2
        val byteArray = ByteArray(length)

        for (i in 0 until length) {
            val high = charToByte(str[i * 2])
            val low = charToByte(str[i * 2 + 1])
            byteArray[i] = ((high.toInt() shl 4) or low.toInt()).toByte()
        }

        return byteArray
    }

    private fun charToByte(c: Char): Byte {
        return when (c) {
            in '0'..'9' -> (c - '0').toByte()
            in 'a'..'f' -> (c - 'a' + 10).toByte()
            in 'A'..'F' -> (c - 'A' + 10).toByte()
            else -> throw IllegalArgumentException(" $c")
        }
    }


    @SuppressLint("GetInstance")
    @Throws(java.lang.Exception::class)
    fun decrypt(arrB: ByteArray?, strKey: String): ByteArray? {
        if (arrB == null) return null

        val key: Key = getKey(strKey.toByteArray())
        val decryptCipher = Cipher.getInstance("DES")
        decryptCipher.init(Cipher.DECRYPT_MODE, key)
        return decryptCipher.doFinal(arrB)
    }








    @Throws(java.lang.Exception::class)
    private fun getKey(arrBTmp: ByteArray): Key {
        val arrB = ByteArray(8)

        var i = 0
        while (i < arrBTmp.size && i < arrB.size) {
            arrB[i] = arrBTmp[i]
            i++
        }

        return SecretKeySpec(arrB, "DES")
    }
}