


import 'method_type.dart';
import 'proto_json_serialization_interface.dart';

class ProtoServiceDefinition implements ProtoJsonDeserializationInterface {
  final String name;
  final Map<String,ProtoMethodDefinition> methods;

  ProtoServiceDefinition({
    required this.name,
    required this.methods,
  });



  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'methods': methods.map((key,method) => MapEntry(key, method.toJson())),
    };
  }
}