enum ProtoLabel {
  LABEL_OPTIONAL('LABEL_OPTIONAL'),
  LABEL_REQUIRED('LABEL_REQUIRED'),
  LABEL_REPEATED('LABEL_REPEATED');

  final String value;

  const ProtoLabel(this.value);

  static ProtoLabel fromValue(String value) {
    return ProtoLabel.values.firstWhere((l) => l.value == value,orElse: () {throw Exception('Invalid Label value: $value');});
  }
}

enum ProtoType {
  // ignore: constant_identifier_names
  TYPE_DOUBLE(1),
  // ignore: constant_identifier_names
  TYPE_FLOAT(2),
  // Not ZigZag encoded. Negative numbers take 10 bytes. Use TYPE_SINT64 if negative values are likely.
  TYPE_INT64(3),
  TYPE_UINT64(4),
  // Not ZigZag encoded. Negative numbers take 10 bytes. Use TYPE_SINT32 if negative values are likely.
  TYPE_INT32(5),
  TYPE_FIXED64(6),
  TYPE_FIXED32(7),
  TYPE_BOOL(8),
  TYPE_STRING(9),
  // Group type is deprecated and not supported after google.protobuf.
  TYPE_GROUP(10),
  TYPE_MESSAGE(11), // Length-delimited aggregate.
  TYPE_BYTES(12),
  TYPE_UINT32(13),
  TYPE_ENUM(14),
  TYPE_SFIXED32(15),
  TYPE_SFIXED64(16),
  TYPE_SINT32(17), // Uses ZigZag encoding.
  TYPE_SINT64(18); // Uses ZigZag encoding.

  final int value;

  const ProtoType(this.value);

  static ProtoType fromValue_toProtoType(int value) {
    return ProtoType.values.firstWhere((t) => t.value == value,orElse: () {throw Exception('Invalid Type value: $value');});
  }

  /*
  static String? handleTypeName(int fieldValue) {
    final value = field.type.value;
    if (value == 11 || value == 14 || value == 10) {
      return field.typeName;
    }

    return ProtoType.values.firstWhere((t) => t.value == value,orElse: () {throw Exception('Invalid Type value: $value');}).toString();
  }
  */
}



/*
0	VARINT	int32, int64, uint32, uint64, sint32, sint64, bool, enum
1	I64	fixed64, sfixed64, double
2	LEN	string, bytes, embedded messages, packed repeated fields
3	SGROUP	group start (deprecated)
4	EGROUP	group end (deprecated)
5	I32	fixed32, sfixed32, float
*/


enum Wire_Type{
  // the specificType is set as a default, it must be specified
  VARINT(0),
  I64(1),
  LEN(2),
  SGROUP(3),
  EGROUP(4),
  I32(5);

  final int value;
  const Wire_Type(this.value);

  static Wire_Type GetWireTypeFromProtoType(ProtoType protoType){
    switch (protoType) {
      case ProtoType.TYPE_DOUBLE:
      case ProtoType.TYPE_FIXED64:
      case ProtoType.TYPE_SFIXED64:
        return Wire_Type.I64;
      case ProtoType.TYPE_FLOAT:
      case ProtoType.TYPE_FIXED32:
      case ProtoType.TYPE_SFIXED32:
        return Wire_Type.I32;
      case ProtoType.TYPE_INT32:
      case ProtoType.TYPE_INT64:
      case ProtoType.TYPE_UINT32:
      case ProtoType.TYPE_UINT64:
      case ProtoType.TYPE_SINT32:
      case ProtoType.TYPE_SINT64:
      case ProtoType.TYPE_BOOL:
      case ProtoType.TYPE_ENUM:
        return Wire_Type.VARINT;
      case ProtoType.TYPE_STRING:
      case ProtoType.TYPE_BYTES:
      case ProtoType.TYPE_MESSAGE:
        return Wire_Type.LEN;
      case ProtoType.TYPE_GROUP:
        return Wire_Type.SGROUP; // Note: GROUP is deprecated
    }
  }
}

class WireTypeInfo{
  final Wire_Type wire_type;
  final ProtoType specificType;

  const WireTypeInfo({
    required this.wire_type,
    required this.specificType,
  });

  @override
  bool operator ==(Object other) {
    return other is WireTypeInfo &&
        other.wire_type.value == wire_type.value &&
        other.specificType.value == specificType.value;
  }

  @override
  int get hashCode => wire_type.hashCode ^ specificType.hashCode;
}

