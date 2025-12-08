import 'core/debugging.dart';
import 'core/grpc_request.dart';
import 'core/proto_containers_construction.dart';
import 'core/proto_file_container.dart';
import 'core/proto_file_containers_importer.dart';
import 'core/protoc_script_running/protoc_run_script.dart';
import 'reflection_client.dart';

Future Test() async {
  ProtoFileContainersImporting reflection = ProtoFileContainersImporting();
  String serviceToRequest = 'GameServerDefinition.GamePlayerManager';
  ProtoFileContainer protoFileContainer =
      await reflection.RequestFileDefinitionViaFileImporting(
        serviceToRequest,
        './protos/game_server_definition.proto',
      );
  FullMethodsTest(protoFileContainer, serviceToRequest);
}

Future main(List<String> args) async {
  // await Test();
/*
  ProtoFileContainersImporting protoFileContainersImporting = ProtoFileContainersImporting();
  final services = await protoFileContainersImporting.RequestAvailableServicesViaReflection('grpcb.in', serverPort: 9001,isSecure: true);
  for (var service in services) {
    print('Available service: $service');*/

  ProtoFileContainersImporting importer = ProtoFileContainersImporting();
  ProtoFileContainer container = await importer.RequestFileDefinitionViaFileImporting(
    'GameServerDefinition.GamePlayerManager',
    './protos/game_server_definition.proto');
  // print(container.toJson());
  final grpcR = GrpcRequest.fromJson({"data" : {
    "name": {"1" : 50, "2" : 51, "3" : 52},
    "type": 1
  }}, container, 'GameServerDefinition.GamePlayerManager', 'CreatePlayer');


  print(grpcR.message.EncodeMessage());
}
