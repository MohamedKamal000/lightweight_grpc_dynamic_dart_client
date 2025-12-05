import '../proto_types.dart';
import 'proto_json_serialization_interface.dart';

class ProtoFieldDefinition implements ProtoJsonSerializationInterface{
  final int fieldNumber;
  final String fieldName;
  final ProtoType fieldType;
  final ProtoLabel fieldLabel;
  final String? typeName; // in case of TYPE_MESSAGE or TYPE_ENUM

  const ProtoFieldDefinition({
    required this.fieldNumber,
    required this.fieldName,
    required this.fieldType,
    required this.fieldLabel,
    this.typeName,
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
      'fieldType': fieldType.toString(),
      'fieldLabel': fieldLabel.toString(),
    };
  }


}