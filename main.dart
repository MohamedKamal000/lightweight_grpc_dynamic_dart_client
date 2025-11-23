import 'core/debugging.dart';
import 'core/proto_file_container.dart';
import 'core/proto_reflection.dart';



Future main(List<String> args) async {
  ProtoReflection reflection = ProtoReflection();
  String serviceToRequest = 'GameServerDefinition.GamePlayerManager';
  if (! (await reflection.SearchForService(serviceToRequest))) {
    throw Exception('Service $serviceToRequest not found among available services.');
  }
  ProtoFileContainer protoFileContainer = await reflection.RequestFileDefinitionViaReflection(serviceToRequest);
  FullMethodsTest(protoFileContainer, serviceToRequest);
}
