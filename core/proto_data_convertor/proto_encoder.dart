import '../proto_types.dart';
import 'proto_encoder_algorithm_matcher.dart';
import 'utilities.dart';

class ProtoEncoder {
  // remember to check for negative values, if it exist do zigzag encoding first
  String encodeVariant(String binaryRepresentation){
    List<String> chuncks = [];
    for (int i = binaryRepresentation.length; i > 0; i -= 7) {
      String nextChunck = i - 7 >= 0 ?  binaryRepresentation.substring(i - 7, i) : binaryRepresentation.substring(0, i);
      if (nextChunck.length < 7){
        nextChunck = nextChunck.padLeft(7, '0');
      }
      chuncks.add(nextChunck);
    }

    for (int i = 0; i < chuncks.length; i++) {
      if (i != chuncks.length - 1){
        chuncks[i] = '1' + chuncks[i];
      } else {
        chuncks[i] = '0' + chuncks[i];
      }
    }

    StringBuffer finalResult = StringBuffer();
    for (var chunck in chuncks) {
      finalResult.write(ConvertBinaryToHexadecimal(chunck));
    }

    return finalResult.toString();
  }

  String GetKey(int fieldNumber, Wire_Type wireType){
    int key = (fieldNumber << 3) | wireType.value;
    String binaryRepresentation = ConvertDecimalToBinary(key);
    return encodeVariant(binaryRepresentation);
  }


  String EncodeI_64_32(double value,List<int> Function(double) encodingFunction){
    final encodedBytes = encodingFunction(value);

    StringBuffer hexString = StringBuffer();
    for (var byte in encodedBytes) {
      String hexByte = ConvertDecimalToHexadecimal(byte);
      hexString.write(hexByte);
    }

    return hexString.toString();
  }

  String EncodeLen_String(String value){
    List<int> utf8Bytes = value.codeUnits;
    StringBuffer hexString = StringBuffer();

    for (var byte in utf8Bytes) {
      String hexByte = ConvertDecimalToHexadecimal(byte);
      hexString.write(hexByte);
    }

    String lengthHex = encodeVariant(ConvertDecimalToBinary(utf8Bytes.length));

    return lengthHex + hexString.toString();
  }

  String EncodeLen_Bytes_RepeatedFields(List<int> byteArray){
    StringBuffer hexString = StringBuffer();
    for (var byte in byteArray) {
      String hexByte = ConvertDecimalToHexadecimal(byte);
      hexString.write(hexByte);
    }

    String lengthHex = encodeVariant(ConvertDecimalToBinary(byteArray.length));

    return lengthHex + hexString.toString();
  }

  String EncodeData(dynamic value,WireTypeInfo wireTypeInfo,int fieldNumber){
    ProtoEncoderAlgorithmMatcher matcher = ProtoEncoderAlgorithmMatcher();
    final encoderAlgorithm = matcher.getEncoderAlgorithm(wireTypeInfo);
    String key = this.GetKey(fieldNumber, wireTypeInfo.wire_type);
    return key + encoderAlgorithm!.Encode(value, this);
  }


  String EncodeRepeatedData(List<dynamic> values,WireTypeInfo wireTypeInfo,int fieldNumber){
    StringBuffer result = StringBuffer();
    for (var item in values) {
      result.write(EncodeData(item, wireTypeInfo, fieldNumber));
    }
    return result.toString();
  }
}





