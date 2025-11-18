import 'dart:convert';

import 'package:grpc/grpc.dart';
import 'core/debugging.dart';
import 'core/grpc_request.dart';
import 'core/proto_data_convertor/utilities.dart';
import 'core/proto_file_container.dart';
import 'core/serialize_into_json.dart';
import 'grpc_request_sender.dart';
import 'proto_descriptor/descriptor.pb.dart';
import 'reflection_client.dart';



Future<ProtoFileContainer> RequestFileDefinitionViaReflection() async {
  final reflection = ReflectionClient('localhost', 50051);
  final stream = reflection.getServicesStream();

  ProtoFileContainer? container;

  await for (final data in stream) {
    if (data.hasFileDescriptorResponse()) {
      for (final bytes in data.fileDescriptorResponse.fileDescriptorProto) {
        final descriptor = FileDescriptorProto.fromBuffer(bytes);
        container = ConstructProtoFileContainer(descriptor);
      }
    }
  }

  await reflection.close();
  if (container == null) {
    throw Exception('Reflection returned no file descriptors.');
  }

  return container!;
}

Future<void> main(List<String> args) async {
  ProtoFileContainer protoFileContainer = await RequestFileDefinitionViaReflection();

  // needs more work in terms of how i would write the data, i might make it all string based since i will take it from user input
  Map<String, dynamic> jsonRequest = {
    'service': 'GamePlayerManager',
    'method': 'CreatePlayer',
    'data': {
      'name' : '"Hamada"',
      'type' : '1'
    }
  };
  GrpcRequest grpcRequest = GrpcRequest.fromJson(jsonRequest, protoFileContainer);
  DynamicGrpcClient dynamicGrpcClient = DynamicGrpcClient(
    ClientChannel(
      'localhost',
      port: 50051,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()),
    ),
  );

  await dynamicGrpcClient.MakeCall(grpcRequest);


}
