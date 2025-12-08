import '../proto_descriptor/descriptor.pb.dart';
import 'proto_file_container.dart';
import 'proto_types.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_type.dart';
import 'proto_types/method_type.dart';
import 'proto_types/service_type.dart';

final GetFinalFilePackageName = (String package) => package.isEmpty ? 'Global' : package;

Map<String,ProtoFileContainer> ConstructProtoFileContainers(List<FileDescriptorProto> fileDescriptors) {
  Map<String,ProtoFileContainer> containers = {};
  Map<String,String> fileNameToPackage = {};


  for (final file in fileDescriptors) {
    containers[GetFinalFilePackageName(file.package)] = ConstructProtoFileContainer(file);
  }

  for (final file in fileDescriptors) {
    if (fileNameToPackage.containsKey(file.name))
      throw Exception('File ${file.name} already exists as a key');
    fileNameToPackage[file.name] = GetFinalFilePackageName(file.package);
  }

  for (final file in fileDescriptors) {
    final container = containers[GetFinalFilePackageName(file.package)]!;
    Map<String,ProtoFileContainer> importsMap = {};
    for (final import in file.dependency) {
        final importContainer = containers[fileNameToPackage[import]];
        if(importContainer!=null){
          importsMap[file.package] = importContainer;
      }
    }
    container.SetImports(importsMap);
  }

  return containers;
}

ProtoFileContainer ConstructProtoFileContainer(FileDescriptorProto fileDescriptor) {

  final messagesMap = ConstructMessages(fileDescriptor.messageType, {}, GetFinalFilePackageName(fileDescriptor.package));
  final services = ConstructServices(fileDescriptor.service, GetFinalFilePackageName(fileDescriptor.package));
  ProtoFileContainer container = ProtoFileContainer(
    package: GetFinalFilePackageName(fileDescriptor.package),
    fileName: fileDescriptor.name,
    services: {
      for (var service in services) service.name: service,
    },
  );
  container.SetMessages(messagesMap);

  return container;
}

List<ProtoServiceDefinition> ConstructServices(
  List<ServiceDescriptorProto> serviceDescriptors,
  String packageName,
) {
  List<ProtoServiceDefinition> services = [];
  for (final service in serviceDescriptors) {
    final serviceName = packageName.isNotEmpty
        ? '$packageName.${service.name}'
        : service.name;

    final serviceType = ProtoServiceDefinition(name: serviceName, methods: {});
    for (final method in service.method) {
      serviceType.methods[method.name] = ProtoMethodDefinition(
        methodName: method.name,
        inputType: method.inputType.replaceFirst('.', ''),
        outputType: method.outputType.replaceFirst('.', ''),
        clientStreaming: method.clientStreaming,
        serverStreaming: method.serverStreaming,
      );
    }
    services.add(serviceType);
  }
  return services;
}

Map<String, ProtoMessageDefinition> ConstructMessages(
  List<DescriptorProto> messageDescriptors,
  Map<String, ProtoMessageDefinition> messageMap,
    String prefixDefinition ,
) {

  for (final msg in messageDescriptors) {
    final messageName = prefixDefinition.isNotEmpty ? '$prefixDefinition.${msg.name}' : msg.name;
    final protoMessage = ProtoMessageDefinition(messageName, fields: [],isMapEntry: msg.options.mapEntry);
    for (final field in msg.field) {
      final fieldType = ProtoType.fromValue_toProtoType(field.type.value);
      final protoField = ProtoFieldDefinition(
        fieldNumber: field.number,
        fieldName: field.name,
        fieldType: fieldType,
        fieldLabel: ProtoLabel.fromValue(field.label.toString()),
        typeName: field.typeName.isNotEmpty ? field.typeName : null,
      );
      protoMessage.AddField(protoField);
    }

    messageMap[messageName] = protoMessage;

    if (msg.nestedType.isNotEmpty) {
      ConstructMessages(msg.nestedType, messageMap, messageName);
    }
  }

  return messageMap;
}




