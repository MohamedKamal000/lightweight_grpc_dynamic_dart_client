


import 'method_type.dart';
import 'proto_json_serialization_interface.dart';

class ServiceType implements ProtoJsonSerializationInterface {
  final String name;
  final Map<String,MethodType> methods;

  ServiceType({
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