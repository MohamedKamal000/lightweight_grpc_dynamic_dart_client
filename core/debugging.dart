import 'dart:convert';
import 'dart:io';

import 'package:grpc/grpc.dart';

import '../grpc_request_sender.dart';
import '../main.dart';
import '../proto_descriptor/descriptor.pb.dart';
import 'grpc_request.dart';
import 'proto_file_container.dart';
import 'proto_types.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_type.dart';

void PrintProtoMessages(List<DescriptorProto> messageDescriptors) {
  for (final msg in messageDescriptors) {
    if (msg.nestedType.isNotEmpty) {
      PrintProtoMessages(msg.nestedType);
    }
    print('message: ${msg.name}');
    print(
      'field: ${msg.field.map((e) => '${e.name} | ${e.type.value == 11 ? e.typeName : ProtoType.fromValue_toProtoType(e.type.value)}}').toList().join(',')}',
    );
  }
}

Future MethodCall(ProtoFileContainer protoFileContainer,String serviceToRequest,String method,String FilePath) async {

  Map<String,dynamic> quickJsonFileDecoder(String jsonFileName){
    String content = File(jsonFileName).readAsStringSync();
    return jsonDecode(content);
  }

  Map<String, dynamic> jsonRequest = {
    'data': quickJsonFileDecoder(FilePath)
  };

  GrpcRequest grpcRequest = GrpcRequest.fromJson(jsonRequest, protoFileContainer,serviceToRequest, method);
  DynamicGrpcClient dynamicGrpcClient = DynamicGrpcClient(
    ClientChannel(
      'localhost',
      port: 50051,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()),
    ),
  );

  await dynamicGrpcClient.MakeCall(grpcRequest);
}

void FullMethodsTest(ProtoFileContainer container,String serviceName) async {
  String basePath = 'jsonFiles/request_tests';
  List<List<String>> methods = [
    // ["CreatePlayer",'$basePath/create_player.json'],
    // ["GetPlayer", '$basePath/get_player.json'],
    // ["UpdatePlayer", '$basePath/update_player.json'],
    // ["DeletePlayer", '$basePath/delete_player.json'],
    // ["GetPlayers", '$basePath/get_players.json'],
    // ['SearchPlayers', '$basePath/search_players.json'],
    ['TestNegativeValues', '$basePath/test_negative_values.json']
  ];

  for (var method in methods) {
    print('--- Testing Method: ${method[0]} ---');
    await MethodCall(container, serviceName, method[0], method[1]);
    print('--- Finished Method: ${method[0]} ---\n');
  }

}