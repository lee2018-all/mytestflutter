// lib/utils/rsa_util.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/asymmetric/api.dart';

class RSAUtil {
  static const String TRANSFORMATION = 'RSA/ECB/PKCS1';
  static const int MAX_ENCRYPT_BLOCK = 245;
  static const int MAX_DECRYPT_BLOCK = 256;

  // Base64合法字符正则
  static final RegExp _illegalCharsPattern = RegExp(r'[^A-Za-z0-9+/=]');

  /// 加密方法
  static String encryptSafe(String data, String publicKeyBase64) {
    try {
      print('=== 开始加密过程 ===');

      // 1. 对原始数据进行Base64编码（保持和Java端一致）
      String base64Data = base64.encode(utf8.encode(data));
      print('原始数据Base64编码: $base64Data');

      // 2. 从公钥中提取模数和指数
      var publicKey = _parsePublicKey(publicKeyBase64);
      print('公钥解析成功，模数长度: ${publicKey.modulus!.bitLength} bits');

      // 3. 加密
      AsymmetricBlockCipher cipher = PKCS1Encoding(RSAEngine())
        ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

      Uint8List dataBytes = Uint8List.fromList(utf8.encode(base64Data));
      Uint8List encryptedData = _encryptBySegment(cipher, dataBytes);

      // 4. 返回Base64编码的加密结果
      String result = base64.encode(encryptedData);
      print('加密完成，结果长度: ${result.length}');

      return result;
    } catch (e) {
      print('加密失败: $e');
      rethrow;
    }
  }

  /// 解析公钥
  static RSAPublicKey _parsePublicKey(String publicKeyBase64) {
    try {
      // 移除可能的头尾标记
      String cleanKey = publicKeyBase64
          .replaceAll('-----BEGIN PUBLIC KEY-----', '')
          .replaceAll('-----END PUBLIC KEY-----', '')
          .replaceAll('-----BEGIN RSA PUBLIC KEY-----', '')
          .replaceAll('-----END RSA PUBLIC KEY-----', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      Uint8List keyBytes = base64.decode(cleanKey);
      print('公钥长度: ${keyBytes.length} 字节');

      // 对于标准的2048位RSA公钥，我们可以直接提取模数和指数
      // 公钥结构: SEQUENCE (2 elements)
      //   SEQUENCE (2 elements)
      //     OBJECT IDENTIFIER 1.2.840.113549.1.1.1 (RSA加密)
      //     NULL
      //   BIT STRING (包含实际公钥)

      // 跳过前面的固定部分，找到BIT STRING中的实际公钥
      int index = 0;

      // 跳过第一个SEQUENCE的标签和长度
      if (keyBytes[index] == 0x30) {
        index++;
        int seqLength = _readLength(keyBytes, index);
        index += _getLengthBytes(keyBytes, index);

        // 跳过算法标识符SEQUENCE
        if (keyBytes[index] == 0x30) {
          index++;
          int algLength = _readLength(keyBytes, index);
          index += _getLengthBytes(keyBytes, index);
          index += algLength;
        }

        // 读取BIT STRING
        if (keyBytes[index] == 0x03) {
          index++;
          int bitStringLength = _readLength(keyBytes, index);
          index += _getLengthBytes(keyBytes, index);

          // 跳过未使用的位数
          index++;

          // 现在index指向BIT STRING的内容，应该是另一个SEQUENCE
          if (keyBytes[index] == 0x30) {
            index++;
            int keySeqLength = _readLength(keyBytes, index);
            index += _getLengthBytes(keyBytes, index);

            // 读取模数
            if (keyBytes[index] == 0x02) {
              index++;
              int modLength = _readLength(keyBytes, index);
              index += _getLengthBytes(keyBytes, index);

              // 处理可能的0x00前缀
              if (keyBytes[index] == 0x00) {
                index++;
                modLength--;
              }

              var modulus = _bytesToBigInt(keyBytes.sublist(index, index + modLength));
              index += modLength;

              // 读取指数
              if (keyBytes[index] == 0x02) {
                index++;
                int expLength = _readLength(keyBytes, index);
                index += _getLengthBytes(keyBytes, index);

                var exponent = _bytesToBigInt(keyBytes.sublist(index, index + expLength));

                return RSAPublicKey(modulus, exponent);
              }
            }
          }
        }
      }

      // 如果上面的解析失败，尝试直接提取
      if (keyBytes.length >= 270) {
        // 最后3字节通常是指数 010001 (65537)
        var modulus = _bytesToBigInt(keyBytes.sublist(keyBytes.length - 259, keyBytes.length - 3));
        var exponent = BigInt.from(65537);
        return RSAPublicKey(modulus, exponent);
      }

      throw Exception('无法解析公钥');
    } catch (e) {
      print('公钥解析失败: $e');
      rethrow;
    }
  }

  /// 解密方法
  static String decryptSafe(String encryptedData, String privateKeyBase64) {
    try {
      print('=== 开始解密过程 ===');
      print('输入数据长度: ${encryptedData.length}');

      // 1. 清理Base64字符串
      String cleanedData = _cleanBase64(encryptedData);
      print('清理后长度: ${cleanedData.length}');

      // 2. 解码加密数据
      Uint8List encryptedBytes = base64.decode(cleanedData);
      print('加密数据解码后长度: ${encryptedBytes.length} 字节');

      // 3. 解码私钥
      String cleanPrivateKey = privateKeyBase64
          .replaceAll('-----BEGIN PRIVATE KEY-----', '')
          .replaceAll('-----END PRIVATE KEY-----', '')
          .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
          .replaceAll('-----END RSA PRIVATE KEY-----', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      Uint8List privateKeyBytes = base64.decode(cleanPrivateKey);
      print('私钥解码后长度: ${privateKeyBytes.length} 字节');

      // 4. 解析私钥
      RSAPrivateKey privateKey = _parsePrivateKey(privateKeyBytes);
      print('私钥解析成功');
      print('模数长度: ${privateKey.modulus!.bitLength} bits');

      // 5. 解密
      AsymmetricBlockCipher cipher = PKCS1Encoding(RSAEngine())
        ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

      Uint8List decryptedBytes = _decryptBySegment(cipher, encryptedBytes);
      print('解密完成，结果长度: ${decryptedBytes.length} 字节');

      // 6. 解析结果（先得到Base64，再解码）
      String base64Result = utf8.decode(decryptedBytes);
      print('Base64中间结果: $base64Result');

      Uint8List finalBytes = base64.decode(base64Result);
      String result = utf8.decode(finalBytes);

      print('最终结果: $result');
      print('=== 解密完成 ===');

      return result;
    } catch (e) {
      print('解密失败: $e');
      rethrow;
    }
  }

  /// 解析PKCS#8私钥
  static RSAPrivateKey _parsePrivateKey(Uint8List keyBytes) {
    int index = 0;

    try {
      // 检查SEQUENCE
      if (keyBytes[index] != 0x30) {
        throw Exception('不是有效的SEQUENCE');
      }
      index++;

      // 读取总长度
      int totalLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);

      // 跳过版本 (INTEGER)
      if (keyBytes[index] == 0x02) {
        index++;
        int verLength = _readLength(keyBytes, index);
        index += _getLengthBytes(keyBytes, index);
        index += verLength;
      }

      // 处理算法标识符
      if (keyBytes[index] == 0x30) {
        index++;
        int algLength = _readLength(keyBytes, index);
        index += _getLengthBytes(keyBytes, index);
        index += algLength; // 跳过整个算法标识符
      }

      // 获取OCTET STRING
      if (keyBytes[index] != 0x04) {
        throw Exception('不是有效的OCTET STRING');
      }
      index++;
      int privateKeyLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);

      // 解析OCTET STRING中的私钥
      Uint8List privateKeyData = keyBytes.sublist(index, index + privateKeyLength);

      // 解析PKCS#1私钥
      return _parsePKCS1PrivateKey(privateKeyData);
    } catch (e) {
      print('PKCS#8解析失败: $e');

      // 尝试直接作为PKCS#1解析
      return _parsePKCS1PrivateKey(keyBytes);
    }
  }

  /// 解析PKCS#1私钥
  static RSAPrivateKey _parsePKCS1PrivateKey(Uint8List keyBytes) {
    int index = 0;

    try {
      // 检查SEQUENCE
      if (keyBytes[index] != 0x30) {
        throw Exception('不是有效的PKCS#1 SEQUENCE');
      }
      index++;

      // 读取总长度
      int totalLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);

      // 解析版本 (应该为0)
      if (keyBytes[index] != 0x02) throw Exception('找不到版本');
      index++;
      int verLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);
      index += verLength;

      // 解析模数 (n)
      if (keyBytes[index] != 0x02) throw Exception('找不到模数');
      index++;
      int modLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);
      if (keyBytes[index] == 0x00) {
        index++;
        modLength--;
      }
      var modulus = _bytesToBigInt(keyBytes.sublist(index, index + modLength));
      index += modLength;

      // 解析公钥指数 (e)
      if (keyBytes[index] != 0x02) throw Exception('找不到公钥指数');
      index++;
      int pubExpLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);
      var publicExponent = _bytesToBigInt(keyBytes.sublist(index, index + pubExpLength));
      index += pubExpLength;

      // 解析私钥指数 (d)
      if (keyBytes[index] != 0x02) throw Exception('找不到私钥指数');
      index++;
      int privExpLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);
      if (keyBytes[index] == 0x00) {
        index++;
        privExpLength--;
      }
      var privateExponent = _bytesToBigInt(keyBytes.sublist(index, index + privExpLength));
      index += privExpLength;

      // 解析质数 p
      if (keyBytes[index] != 0x02) throw Exception('找不到质数p');
      index++;
      int pLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);
      if (keyBytes[index] == 0x00) {
        index++;
        pLength--;
      }
      var p = _bytesToBigInt(keyBytes.sublist(index, index + pLength));
      index += pLength;

      // 解析质数 q
      if (keyBytes[index] != 0x02) throw Exception('找不到质数q');
      index++;
      int qLength = _readLength(keyBytes, index);
      index += _getLengthBytes(keyBytes, index);
      if (keyBytes[index] == 0x00) {
        index++;
        qLength--;
      }
      var q = _bytesToBigInt(keyBytes.sublist(index, index + qLength));

      return RSAPrivateKey(modulus, privateExponent, p, q);
    } catch (e) {
      print('PKCS#1解析失败: $e');
      rethrow;
    }
  }

  /// 读取ASN.1长度
  static int _readLength(Uint8List bytes, int index) {
    if (index >= bytes.length) return 0;

    int length = bytes[index];
    if (length < 0x80) {
      return length;
    }

    int numBytes = length & 0x7F;
    if (numBytes == 0) return 0;

    int result = 0;
    for (int i = 1; i <= numBytes; i++) {
      if (index + i >= bytes.length) break;
      result = (result << 8) | bytes[index + i];
    }
    return result;
  }

  /// 获取长度字段占用的字节数
  static int _getLengthBytes(Uint8List bytes, int index) {
    if (index >= bytes.length) return 1;

    int length = bytes[index];
    if (length < 0x80) {
      return 1;
    }
    return 1 + (length & 0x7F);
  }

  /// 字节数组转BigInt
  static BigInt _bytesToBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    for (int i = 0; i < bytes.length; i++) {
      result = (result << 8) | BigInt.from(bytes[i] & 0xFF);
    }
    return result;
  }

  /// 清理Base64字符串
  static String _cleanBase64(String data) {
    if (data.isEmpty) return data;

    // 移除空白字符
    String cleaned = data.trim();

    // 移除非法字符
    if (_illegalCharsPattern.hasMatch(cleaned)) {
      StringBuffer validChars = StringBuffer();
      for (int i = 0; i < cleaned.length; i++) {
        String char = cleaned[i];
        if (_isValidBase64Char(char)) {
          validChars.write(char);
        }
      }
      cleaned = validChars.toString();
    }

    // 补齐padding
    int padding = 4 - (cleaned.length % 4);
    if (padding < 4) {
      cleaned = cleaned.padRight(cleaned.length + padding, '=');
    }

    return cleaned;
  }

  /// 检查是否为合法Base64字符
  static bool _isValidBase64Char(String char) {
    if (char.length != 1) return false;
    int code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        (code >= 48 && code <= 57) || // 0-9
        code == 43 || // +
        code == 47 || // /
        code == 61; // =
  }

  /// 分段加密
  static Uint8List _encryptBySegment(AsymmetricBlockCipher cipher, Uint8List data) {
    int inputLen = data.length;
    int offset = 0;
    List<int> result = [];

    while (inputLen - offset > 0) {
      int length = (inputLen - offset < MAX_ENCRYPT_BLOCK)
          ? inputLen - offset
          : MAX_ENCRYPT_BLOCK;

      Uint8List segment = data.sublist(offset, offset + length);
      Uint8List encryptedSegment = cipher.process(segment);
      result.addAll(encryptedSegment);

      offset += length;
    }

    return Uint8List.fromList(result);
  }

  /// 分段解密
  static Uint8List _decryptBySegment(AsymmetricBlockCipher cipher, Uint8List data) {
    int inputLen = data.length;
    int offset = 0;
    List<int> result = [];

    while (inputLen - offset > 0) {
      int length = (inputLen - offset < MAX_DECRYPT_BLOCK)
          ? inputLen - offset
          : MAX_DECRYPT_BLOCK;

      Uint8List segment = data.sublist(offset, offset + length);
      Uint8List decryptedSegment = cipher.process(segment);
      result.addAll(decryptedSegment);

      offset += length;
    }

    return Uint8List.fromList(result);
  }
}