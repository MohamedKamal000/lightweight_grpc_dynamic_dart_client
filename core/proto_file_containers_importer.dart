import '../proto_descriptor/descriptor.pb.dart';
import '../reflection_client.dart';
import 'proto_containers_construction.dart';
import 'proto_file_container.dart';
import 'protoc_script_running/protoc_run_script.dart';


class ProtoFileContainersImporting {

  Future<ProtoFileContainer> RequestFileDefinitionViaReflection(
    String service,
    String serverAddress,
    int serverPort,
      bool isSecure
  ) async {
    if (!await _SearchForServiceViaReflection(service,serverAddress,serverPort,isSecure)) {
      throw Exception('Service $service not found via reflection.');
    }

    final reflection = ReflectionClient(serverAddress, serverPort);
    final stream = reflection.getServiceStream(service);

    ProtoFileContainer? container;

    await for (final data in stream) {
      if (data.hasFileDescriptorResponse()) {
        for (final bytes in data.fileDescriptorResponse.fileDescriptorProto) {
          List<FileDescriptorProto> descriptors = [];
          final descriptor = FileDescriptorProto.fromBuffer(bytes);
          for (final desc in descriptor.dependency) {
            final depData = await reflection.getFileByNameStream(desc);
            for (final depBytes in depData.fileDescriptorResponse.fileDescriptorProto) {
              final depDescriptor = FileDescriptorProto.fromBuffer(depBytes);
              descriptors.add(depDescriptor);
            }
          }
          descriptors.add(descriptor);
          final containers = ConstructProtoFileContainers(descriptors);
          container = containers[GetFinalFilePackageName(descriptor.package)];
        }
      }
    }

    await reflection.close();
    if (container == null) {
      throw Exception('Reflection returned no file descriptors.');
    }

    return container!;
  }

  Future<ProtoFileContainer> RequestFileDefinitionViaFileImporting(
    String service,
    String nameOfTheFile,
  ) async {
    final set = await compileProtoAtRuntime(
      nameOfTheFile,
      './protos/importedProtoFile',
    );

    ProtoFileContainer? container;

    for (final file in set.file) {
      for (final serviceDef in file.service) {
        final fullServiceName =
            '${file.package.isEmpty ? 'Global' : file.package}.${serviceDef.name}';
        if (fullServiceName == service) {
          final containers = ConstructProtoFileContainers([file]);
          container = containers[GetFinalFilePackageName(file.package)];
          break;
        }
      }
      if (container != null) {
        break;
      }
    }

    if (container == null) {
      throw Exception('Service $service not found in imported file.');
    }

    return container!;
  }

  Future<Set<String>> RequestAvailableServicesViaReflection(String serverAddress,{int serverPort = 443, bool isSecure = false}) async {
    final reflection = ReflectionClient(serverAddress, serverPort,isSecure: isSecure);
    final responseStream = reflection.listServices();
    Set<String> serviceNames = {};

    await for (final services in responseStream) {
      for (final service in services.listServicesResponse.service){
        if (serviceNames.contains(service)) {
          print('Warning: Duplicate service name found: ${service.name}');
          continue;
        }
        serviceNames.add(service.name);
      }
    }

    reflection.close();
    return serviceNames;
  }

  Future<Set<String>> RequestAvailableServicesViaFileImporting(
    String nameOfTheFile,
  ) async {
    final set = await compileProtoAtRuntime(
      nameOfTheFile,
      './protos/importedProtoFile',
    );

    Set<String> serviceNames = {};
    for (final file in set.file) {
      for (final service in file.service) {
        if (serviceNames.contains(service.name)) {
          print('Warning: Duplicate service name found: ${service.name}');
          continue;
        }
        serviceNames.add(service.name);
      }
    }

    return serviceNames;
  }

  /// services must start with package name e.g (mypackage.MyService)
  /// Full name of a registered service, including its package name.
  /// The format is package.service
  /// if the package is empty, then it must start with Global.service
  Future<bool> _SearchForServiceViaReflection(String serviceName,String serverAddress,int serverPort,bool isSecure) async {
    Set<String> servicesSet = await this
        .RequestAvailableServicesViaReflection(serverAddress, serverPort: serverPort,isSecure: isSecure);
    return servicesSet.contains(serviceName);
  }
}
