import 'core/ProtoImporting/protoc_run_script.dart';
import 'core/debugging.dart';
import 'core/proto_file_container.dart';
import 'core/proto_reflection.dart';


Future Test() async{
  ProtoReflection reflection = ProtoReflection();
  String serviceToRequest = 'GameServerDefinition.GamePlayerManager';
  final services = await reflection.RequestAvailableServicesViaReflection();
  print('Available services: ${services.join(',').toString()}');
  if (! (await reflection.SearchForService(serviceToRequest))) {
  throw Exception('Service $serviceToRequest not found among available services.');
  }
  ProtoFileContainer protoFileContainer = await reflection.RequestFileDefinitionViaReflection(serviceToRequest);
  print(protoFileContainer.toString());
  // FullMethodsTest(protoFileContainer, serviceToRequest);
}

Future main(List<String> args) async {
  await Test();
  /*final set = await compileProtoAtRuntime('./protos/game_server_definition.proto', './protos/importedProtoFile.pb');

  for (var fileProto in set.file) {
    print('File: ${fileProto.name}');
    print('Messages: ${fileProto.messageType.map((m) => m.name)}');
    print('Services: ${fileProto.service.map((s) => s.name)}');
  }*/


}
