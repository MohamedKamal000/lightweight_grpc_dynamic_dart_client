




import '../proto_descriptor/descriptor.pb.dart';
import '../reflection_client.dart';
import 'proto_containers_construction.dart';
import 'proto_file_container.dart';

class ProtoReflection{

  Future<ProtoFileContainer> RequestFileDefinitionViaReflection(String service) async {
    final reflection = ReflectionClient('localhost', 50051);
    final stream = reflection.getServiceStream(service);

    ProtoFileContainer ? container;

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

  Future<Set<String>> _RequestAvailableServicesViaReflection() async {
    final reflection = ReflectionClient('localhost', 50051);
    final services = await reflection.listServices();
    Set<String> serviceNames = {};


    for (final service in services.listServicesResponse.service) {

      if (serviceNames.contains(service.name)) {
        print('Warning: Duplicate service name found: ${service.name}');
        continue;
      }
      serviceNames.add(service.name);
    }

    reflection.close();
    return serviceNames;
  }

  /// services must start with package name e.g (mypackage.MyService)
  /// Full name of a registered service, including its package name.
  /// The format is package.service
  Future<bool> SearchForService(String serviceName) async{
    Set<String> servicesSet = await this._RequestAvailableServicesViaReflection();
    return servicesSet.contains(serviceName);
  }


}