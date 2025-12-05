import '../proto_data_convertor/proto_encoder.dart';
import '../proto_types.dart';
import 'field_type.dart';
import 'message_data.dart';

class ProtoFieldData {
  final ProtoFieldDefinition fieldDefinition;
  final dynamic data;

  ProtoFieldData({required this.fieldDefinition, required this.data});

  String EncodeData() {
    if (data == null)
      throw Exception('Accessing null data of a field Definition ${fieldDefinition.fieldName}');

    ProtoEncoder encoder = ProtoEncoder();
    if (fieldDefinition.fieldLabel == ProtoLabel.LABEL_REPEATED) {
      if (fieldDefinition.fieldType == ProtoType.TYPE_MESSAGE) {
        StringBuffer repeatedMessagesBuffer = StringBuffer();
        for (ProtoMessageData message in data) {
          String encodedMessage = message.EncodeMessage();
          repeatedMessagesBuffer.write(encodedMessage);
        }
        return repeatedMessagesBuffer.toString();
      }
      return encoder.EncodeRepeatedData(
        data,
        WireTypeInfo(
          wire_type: Wire_Type.GetWireTypeFromProtoType(
            fieldDefinition.fieldType,
          ),
          specificType: fieldDefinition.fieldType,
        ),
        fieldDefinition.fieldNumber,
      );
    } else {
      if (fieldDefinition.fieldType == ProtoType.TYPE_MESSAGE) {
        ProtoFieldData message = data as ProtoFieldData;
        String encodedMessage = message.EncodeData();
        return encodedMessage;
      }
      return encoder.EncodeData(
        data,
        WireTypeInfo(
          wire_type: Wire_Type.GetWireTypeFromProtoType(fieldDefinition.fieldType),
          specificType: fieldDefinition.fieldType,
        ),
        fieldDefinition.fieldNumber,
      );
    }
  }
}
