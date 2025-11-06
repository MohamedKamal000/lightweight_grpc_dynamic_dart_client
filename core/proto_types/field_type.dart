import '../proto_data_convertor/proto_encoder.dart';
import '../proto_types.dart';
import 'message_type.dart';
import 'proto_json_serialization_interface.dart';

class ProtoField implements ProtoJsonSerializationInterface{
  final int fieldNumber;
  final String fieldName;
  final ProtoType fieldType;
  final ProtoLabel fieldLabel;
  final String? typeName;
  final bool isDataSet;
  final dynamic data;
  final dynamic listOfData_if_repeated;

  const ProtoField({
    required this.fieldNumber,
    required this.fieldName,
    required this.fieldType,
    required this.fieldLabel,
    required this.isDataSet,
    this.typeName,
    this.data,
    this.listOfData_if_repeated,
  });

  @override
  String toString() {
    String finalFieldType = fieldType == ProtoType.TYPE_MESSAGE || fieldType == ProtoType.TYPE_ENUM || fieldType == ProtoType.TYPE_GROUP
        ? typeName ?? fieldType.toString()
        : fieldType.toString();

    return 'ProtoField(name: $fieldName, type: $finalFieldType, label: ${fieldLabel.toString()})';
  }

  @override
  Map<String,dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'fieldType': fieldType,
      'fieldLabel': fieldLabel,
    };
  }

  String EncodeData(){
    ProtoEncoder encoder = ProtoEncoder();
    if (fieldLabel == ProtoLabel.LABEL_REPEATED && listOfData_if_repeated != null) {
      if (fieldType == ProtoType.TYPE_MESSAGE) {
        StringBuffer repeatedMessagesBuffer = StringBuffer();
        for (ProtoMessage message in listOfData_if_repeated) {
          String encodedMessage = message.EncodeMessage();
          repeatedMessagesBuffer.write(encodedMessage);
        }
        return repeatedMessagesBuffer.toString();
      }
      return encoder.EncodeRepeatedData(listOfData_if_repeated,WireTypeInfo(wire_type: Wire_Type.GetWireTypeFromProtoType(fieldType), specificType: fieldType),fieldNumber);
    } else if (data != null) {
      if (fieldType == ProtoType.TYPE_MESSAGE) {
        ProtoField message = data as ProtoField;
        String encodedMessage = message.EncodeData();
        return encodedMessage;
      }
      return encoder.EncodeData(data,WireTypeInfo(wire_type: Wire_Type.GetWireTypeFromProtoType(fieldType), specificType: fieldType),fieldNumber);
    } else {
      return '';
    }
  }

}