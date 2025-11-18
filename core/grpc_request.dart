import 'deserialize_json_to_message.dart';
import 'proto_file_container.dart';
import 'proto_types/message_type.dart';
import 'proto_types/method_type.dart';

class GrpcRequest {
  final String service;
  final String method;
  final ProtoMessage message;

  GrpcRequest({
    required this.service,
    required this.method,
    required this.message
  });

  factory GrpcRequest.fromJson(Map<String, dynamic> json,
      ProtoFileContainer protoFileContainer) {
    if (json['service'] != null &&
        protoFileContainer.services != null &&
        !protoFileContainer.services!.containsKey(json['service'])) {
      throw Exception('Service not found in proto file container');
    }

    String serviceName = json['service'];

    if (json['method'] != null &&
        !protoFileContainer
            .services![serviceName]!.methods
            .containsKey(json['method'])) {
      throw Exception('Method not found in service $serviceName');
    }

    String methodName = json['method'];
    MethodType method = protoFileContainer
        .services![serviceName]!.methods[methodName]!;


    String inputTypeName = method.inputType; // message as Input type

    dynamic dataSent = json['data']; // incoming data

    ProtoMessage messageStructure =
        protoFileContainer.messages![inputTypeName]!;

    DeserializeJsonToMessage deserializer = DeserializeJsonToMessage(
      data: dataSent,
      messageStructure: messageStructure,
    );
    return GrpcRequest(
      service: serviceName,
      method: methodName,
      message: deserializer.Deserialize()
    );
  }
}