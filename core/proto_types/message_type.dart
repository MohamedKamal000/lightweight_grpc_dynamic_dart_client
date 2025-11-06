import 'dart:convert';

import 'field_type.dart';
import 'proto_json_serialization_interface.dart';

class ProtoMessage implements ProtoJsonSerializationInterface{
  final String messageName;
  final List<ProtoField> fields;

  const ProtoMessage(this.messageName, {
    required this.fields,
  });

  void AddField(ProtoField field) {
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

  String EncodeMessage(){
    StringBuffer buffer = StringBuffer();
    for (var field in fields) {

      if (!field.isDataSet)
        continue;

      buffer.write(field.EncodeData());
    }
    return buffer.toString();
  }
}