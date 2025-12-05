import 'deserialize_json_to_message.dart';
import 'proto_file_container.dart';
import 'proto_types/message_data.dart';
import 'proto_types/message_type.dart';
import 'proto_types/method_type.dart';

class GrpcRequest {
  final String service;
  final String method;
  final ProtoMessageData message;

  GrpcRequest({
    required this.service,
    required this.method,
    required this.message
  });

  factory GrpcRequest.fromJson(Map<String, dynamic> json,
      ProtoFileContainer protoFileContainer,String service, String methodName) {
    if (protoFileContainer.services != null && !protoFileContainer.services!.containsKey(service)) {
      throw Exception('Service not found in proto file container');
    }

    if (!protoFileContainer.services![service]!.methods.containsKey(methodName)) {
      throw Exception('Method not found in service $service');
    }

    ProtoMethodDefinition methodType = protoFileContainer.services![service]!.methods[methodName]!;
    String inputTypeName = methodType.inputType; // message as Input type

    dynamic dataSent = json['data']; // incoming data

    ProtoMessageDefinition messageStructure =
        protoFileContainer.messages![inputTypeName]!;

    DeserializeJsonToMessage deserializer = DeserializeJsonToMessage(
      data: dataSent,
      messageStructure: messageStructure,
      container: protoFileContainer,
    );
    return GrpcRequest(
      service: service,
      method: methodName,
      message: deserializer.Deserialize()
    );
  }
}