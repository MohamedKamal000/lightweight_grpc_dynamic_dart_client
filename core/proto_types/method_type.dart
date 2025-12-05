import 'proto_json_serialization_interface.dart';

class ProtoMethodDefinition implements ProtoJsonSerializationInterface {
  final String methodName;
  final String inputType;
  final String outputType;
  final bool clientStreaming = false;
  final bool serverStreaming = false;


  ProtoMethodDefinition({
    required this.methodName,
    required this.inputType,
    required this.outputType,
    clientStreaming,
    serverStreaming,
  });

  @override
  String toString() {
    return 'MethodType{name: $methodName, inputTypes: $inputType, outputTypes: $outputType}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': methodName,
      'inputTypes': inputType,
      'outputTypes': outputType,
    };
  }
}