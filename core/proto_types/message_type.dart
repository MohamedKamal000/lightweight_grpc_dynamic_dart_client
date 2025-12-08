import 'dart:convert';

import 'field_type.dart';
import 'proto_json_serialization_interface.dart';

class ProtoMessageDefinition implements ProtoJsonDeserializationInterface{
  final String messageName;
  final bool isMapEntry;
  final List<ProtoFieldDefinition> fields;

  const ProtoMessageDefinition(this.messageName, {
    required this.fields,
    this.isMapEntry = false,
  });

  void AddField(ProtoFieldDefinition field) {
    fields.add(field);
  }

  @override
  String toString() {
    String fieldsStr = fields.map((f) => f.toString()).join('\n');
    return 'message $messageName {\n$fieldsStr\n}';
  }

  @override
  Map<String,dynamic> toJson() {
    final fieldsJson = fields.map((f) => f.toJson()).toList();
    return {
      '$messageName': fieldsJson,
    };
  }

}