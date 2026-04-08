import 'dart:convert';
import 'dart:math';
import 'package:pointycastle/export.dart' as pc;
import 'dart:typed_data';

class AESUtil {
  // 密钥（应该从安全的地方获取，不要硬编码）
  static const String _defaultKey = 'dsej326A82h543k5'; // 16字节密钥

  /// AES解密 (CBC模式，PKCS5填充，IV使用密钥前16字节)
  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';

    try {
      return decryptAesCbc(encryptedText, _defaultKey);
    } catch (e) {
      return encryptedText;
    }
  }

  /// AES解密 (CBC模式，PKCS5填充，IV使用密钥前16字节)
  static String decryptAesCbc(String encryptedBase64, String keyString) {
    try {
      // 准备密钥字节
      Uint8List key = _prepareKey(keyString);

      // IV使用密钥的前16字节
      Uint8List iv = Uint8List(16);
      if (key.length >= 16) {
        iv.setAll(0, Uint8List.sublistView(key, 0, 16));
      } else {
        iv.setAll(0, key);
      }

      // Base64解码
      Uint8List encryptedData = base64.decode(encryptedBase64);

      // 创建AES引擎
      pc.AESEngine engine = pc.AESEngine();

      // 初始化密钥
      engine.init(false, pc.KeyParameter(key)); // false = 解密模式

      // CBC模式需要手动处理
      // 创建CBC块密码
      pc.CBCBlockCipher cbcCipher = pc.CBCBlockCipher(engine);

      // 初始化CBC模式
      cbcCipher.init(false, pc.ParametersWithIV(pc.KeyParameter(key), iv));

      // 解密
      int blockSize = cbcCipher.blockSize;
      Uint8List decryptedData = Uint8List(encryptedData.length);

      for (int i = 0; i < encryptedData.length; i += blockSize) {
        int end = i + blockSize;
        if (end > encryptedData.length) {
          end = encryptedData.length;
        }
        Uint8List block = Uint8List.sublistView(encryptedData, i, end);
        Uint8List decryptedBlock = Uint8List(block.length);

        int processed = cbcCipher.processBlock(block, 0, decryptedBlock, 0);
        decryptedData.setAll(i, Uint8List.sublistView(decryptedBlock, 0, processed));
      }

      // 移除PKCS5/PKCS7填充
      int paddingLength = decryptedData[decryptedData.length - 1];
      if (paddingLength > 0 && paddingLength <= blockSize) {
        decryptedData = Uint8List.sublistView(decryptedData, 0, decryptedData.length - paddingLength);
      }

      // 转换为字符串
      return utf8.decode(decryptedData);
    } catch (e, stackTrace) {

      return encryptedBase64;
    }
  }

  /// 使用 ECB 模式解密（备用方案）
  static String decryptAesEcb(String encryptedBase64, String keyString) {
    try {
      // 准备密钥
      Uint8List key = _prepareKey(keyString);

      // Base64解码
      Uint8List encryptedData = base64.decode(encryptedBase64);

      // 创建AES引擎
      pc.AESEngine engine = pc.AESEngine();

      // 初始化密钥
      engine.init(false, pc.KeyParameter(key));

      // ECB模式直接处理
      int blockSize = engine.blockSize;
      Uint8List decryptedData = Uint8List(encryptedData.length);

      for (int i = 0; i < encryptedData.length; i += blockSize) {
        int end = i + blockSize;
        if (end > encryptedData.length) {
          end = encryptedData.length;
        }
        Uint8List block = Uint8List.sublistView(encryptedData, i, end);
        Uint8List decryptedBlock = Uint8List(block.length);

        int processed = engine.processBlock(block, 0, decryptedBlock, 0);
        decryptedData.setAll(i, Uint8List.sublistView(decryptedBlock, 0, processed));
      }

      // 移除PKCS5/PKCS7填充
      int paddingLength = decryptedData[decryptedData.length - 1];
      if (paddingLength > 0 && paddingLength <= blockSize) {
        decryptedData = Uint8List.sublistView(decryptedData, 0, decryptedData.length - paddingLength);
      }

      // 转换为字符串
      return utf8.decode(decryptedData);
    } catch (e) {
      return encryptedBase64;
    }
  }

  /// AES加密 (CBC模式，PKCS5填充，IV使用密钥前16字节)
  static String encryptAesCbc(String plainText, String keyString) {
    try {
      // 准备密钥字节
      Uint8List key = _prepareKey(keyString);

      // IV使用密钥的前16字节
      Uint8List iv = Uint8List(16);
      if (key.length >= 16) {
        iv.setAll(0, Uint8List.sublistView(key, 0, 16));
      } else {
        iv.setAll(0, key);
      }

      // 准备数据并添加PKCS5填充
      Uint8List data = utf8.encode(plainText) as Uint8List;
      int blockSize = 16;
      int paddingLength = blockSize - (data.length % blockSize);
      Uint8List paddedData = Uint8List(data.length + paddingLength);
      paddedData.setAll(0, data);
      for (int i = 0; i < paddingLength; i++) {
        paddedData[data.length + i] = paddingLength;
      }

      // 创建AES引擎
      pc.AESEngine engine = pc.AESEngine();

      // 初始化密钥
      engine.init(true, pc.KeyParameter(key));

      // CBC模式
      pc.CBCBlockCipher cbcCipher = pc.CBCBlockCipher(engine);
      cbcCipher.init(true, pc.ParametersWithIV(pc.KeyParameter(key), iv));

      // 加密
      Uint8List encryptedData = Uint8List(paddedData.length);

      for (int i = 0; i < paddedData.length; i += blockSize) {
        int end = i + blockSize;
        Uint8List block = Uint8List.sublistView(paddedData, i, end);
        Uint8List encryptedBlock = Uint8List(block.length);

        int processed = cbcCipher.processBlock(block, 0, encryptedBlock, 0);
        encryptedData.setAll(i, Uint8List.sublistView(encryptedBlock, 0, processed));
      }

      // Base64编码
      return base64.encode(encryptedData);
    } catch (e) {
      return plainText;
    }
  }

  /// 准备密钥，确保长度为16、24或32字节
  static Uint8List _prepareKey(String keyString) {
    Uint8List keyBytes = utf8.encode(keyString) as Uint8List;

    // AES-128 需要16字节密钥
    if (keyBytes.length < 16) {
      // 如果密钥太短，用0填充到16字节
      Uint8List paddedKey = Uint8List(16);
      paddedKey.setAll(0, keyBytes);
      return paddedKey;
    } else if (keyBytes.length > 16 && keyBytes.length < 24) {
      // 如果密钥在16-24之间，截取前16字节
      return Uint8List.sublistView(keyBytes, 0, 16);
    } else if (keyBytes.length > 24 && keyBytes.length < 32) {
      // 如果密钥在24-32之间，截取前24字节
      return Uint8List.sublistView(keyBytes, 0, 24);
    } else if (keyBytes.length > 32) {
      // 如果密钥大于32字节，截取前32字节
      return Uint8List.sublistView(keyBytes, 0, 32);
    }

    return keyBytes;
  }

  /// 尝试多种方式解密
  static String decryptWithFallback(String encryptedText) {
    if (encryptedText.isEmpty) return '';

    // 方法1: CBC模式
    try {
      String result = decryptAesCbc(encryptedText, _defaultKey);
      if (result != encryptedText && result.isNotEmpty) {
        return result;
      }
    } catch (e) {
    }

    // 方法2: ECB模式
    try {
      String result = decryptAesEcb(encryptedText, _defaultKey);
      if (result != encryptedText && result.isNotEmpty) {
        return result;
      }
    } catch (e) {
    }

    return encryptedText;
  }

  /// 尝试解密（带详细错误日志）
  static String decryptWithDebug(String encryptedText) {
    if (encryptedText.isEmpty) return '';

    try {
      // 准备密钥
      Uint8List key = _prepareKey(_defaultKey);

      // IV使用密钥的前16字节
      Uint8List iv = Uint8List(16);
      if (key.length >= 16) {
        iv.setAll(0, Uint8List.sublistView(key, 0, 16));
      }

      // Base64解码
      Uint8List encryptedData = base64.decode(encryptedText);

      // 创建AES引擎
      pc.AESEngine engine = pc.AESEngine();
      engine.init(false, pc.KeyParameter(key));

      // CBC模式
      pc.CBCBlockCipher cbcCipher = pc.CBCBlockCipher(engine);
      cbcCipher.init(false, pc.ParametersWithIV(pc.KeyParameter(key), iv));

      // 解密
      int blockSize = cbcCipher.blockSize;
      Uint8List decryptedData = Uint8List(encryptedData.length);

      for (int i = 0; i < encryptedData.length; i += blockSize) {
        int end = i + blockSize;
        if (end > encryptedData.length) {
          end = encryptedData.length;
        }
        Uint8List block = Uint8List.sublistView(encryptedData, i, end);
        Uint8List decryptedBlock = Uint8List(block.length);

        int processed = cbcCipher.processBlock(block, 0, decryptedBlock, 0);
        decryptedData.setAll(i, Uint8List.sublistView(decryptedBlock, 0, processed));
      }


      // 移除PKCS5/PKCS7填充
      int paddingLength = decryptedData[decryptedData.length - 1];

      if (paddingLength > 0 && paddingLength <= blockSize) {
        decryptedData = Uint8List.sublistView(decryptedData, 0, decryptedData.length - paddingLength);
      }

      // 转换为字符串
      String result = utf8.decode(decryptedData);

      return result;
    } catch (e, stackTrace) {

      return encryptedText;
    }
  }
}

/// 扩展方法
extension AESUtilExtension on String {
  String get aesDecrypt {
    return AESUtil.decrypt(this);
  }

  String get aesDecryptWithFallback {
    return AESUtil.decryptWithFallback(this);
  }

  String get aesDecryptWithDebug {
    return AESUtil.decryptWithDebug(this);
  }

  String get aesEncrypt {
    return AESUtil.encryptAesCbc(this, AESUtil._defaultKey);
  }
}