

import '../proto_types.dart';
import 'proto_encoder.dart';
import 'utilities.dart';

abstract interface class ProtoEncoderAlgorithm<T>{
  String Encode(T value,ProtoEncoder encoder);
}

class ProtoEncoderAlgorithmMatcher {
    late Map<WireTypeInfo, ProtoEncoderAlgorithm> encoderAlgorithms;

    ProtoEncoderAlgorithmMatcher(){
      encoderAlgorithms = {
        WireTypeInfo(wire_type: Wire_Type.I64,specificType: ProtoType.TYPE_DOUBLE): DoubleEncoder(),
        WireTypeInfo(wire_type: Wire_Type.I64,specificType: ProtoType.TYPE_FIXED64): DoubleEncoder(),
        WireTypeInfo(wire_type: Wire_Type.I64,specificType: ProtoType.TYPE_SFIXED64): DoubleEncoder(),
        WireTypeInfo(wire_type: Wire_Type.I32,specificType: ProtoType.TYPE_FLOAT): FloatEncoder(),
        WireTypeInfo(wire_type: Wire_Type.I32,specificType: ProtoType.TYPE_FIXED32): FloatEncoder(),
        WireTypeInfo(wire_type: Wire_Type.I32,specificType: ProtoType.TYPE_SFIXED32): FloatEncoder(),
        WireTypeInfo(wire_type: Wire_Type.VARINT,specificType: ProtoType.TYPE_INT32): IntEncoder(),
        WireTypeInfo(wire_type: Wire_Type.VARINT,specificType: ProtoType.TYPE_INT64): IntEncoder(),
        WireTypeInfo(wire_type: Wire_Type.VARINT,specificType: ProtoType.TYPE_BOOL): IntEncoder(),
        WireTypeInfo(wire_type: Wire_Type.VARINT,specificType: ProtoType.TYPE_ENUM): IntEncoder(),
        WireTypeInfo(wire_type: Wire_Type.VARINT,specificType: ProtoType.TYPE_UINT32): IntEncoder(),
        WireTypeInfo(wire_type: Wire_Type.VARINT,specificType: ProtoType.TYPE_UINT64): IntEncoder(),
        WireTypeInfo(wire_type: Wire_Type.VARINT,specificType: ProtoType.TYPE_SINT32): SIntEncoder(),
        WireTypeInfo(wire_type: Wire_Type.VARINT,specificType: ProtoType.TYPE_SINT64): SIntEncoder(),
        WireTypeInfo(wire_type: Wire_Type.LEN,specificType: ProtoType.TYPE_BYTES): BytesEncoder(),
        WireTypeInfo(wire_type: Wire_Type.LEN,specificType: ProtoType.TYPE_STRING): StringEncoder(),
      };
    }


    ProtoEncoderAlgorithm? getEncoderAlgorithm(WireTypeInfo wireTypeInfo){
      if (!encoderAlgorithms.containsKey(wireTypeInfo)){
        throw Exception('No encoder algorithm found for wire type: ${wireTypeInfo.wire_type} and specific type: ${wireTypeInfo.specificType}');
      }
      return encoderAlgorithms[wireTypeInfo];
    }

}


class DoubleEncoder implements ProtoEncoderAlgorithm<double> {

  @override
  String Encode(double value,ProtoEncoder encoder) {
    return encoder.EncodeI_64_32(value,encodeFloat64);
  }
}

class FloatEncoder implements ProtoEncoderAlgorithm<double> {
  @override
  String Encode(double value,ProtoEncoder encoder) {
    return encoder.EncodeI_64_32(value,encodeFloat32);
  }
}

class StringEncoder implements ProtoEncoderAlgorithm<String> {
  @override
  String Encode(String value,ProtoEncoder encoder) {
    return encoder.EncodeLen_String(value);
  }
}

class IntEncoder implements ProtoEncoderAlgorithm<int> {
  @override
  String Encode(int value,ProtoEncoder encoder) {
    String binaryRepresentation = ConvertDecimalToBinary(value);
    return encoder.encodeVariant(binaryRepresentation);
  }
}

class SIntEncoder implements ProtoEncoderAlgorithm<int> {
  @override
  String Encode(int value,ProtoEncoder encoder) {
    int zigzagValue = EncodeZigZag32(value);
    String binaryRepresentation = ConvertDecimalToBinary(zigzagValue);
    return encoder.encodeVariant(binaryRepresentation);
  }
}

class BytesEncoder implements ProtoEncoderAlgorithm<List<int>> {
  @override
  String Encode(List<int> value,ProtoEncoder encoder) {
    return encoder.EncodeLen_Bytes_RepeatedFields(value);
  }
}

