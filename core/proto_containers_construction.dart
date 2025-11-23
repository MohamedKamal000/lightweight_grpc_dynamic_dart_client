import '../proto_descriptor/descriptor.pb.dart';
import 'proto_file_container.dart';
import 'proto_types.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_type.dart';
import 'proto_types/method_type.dart';
import 'proto_types/service_type.dart';

Map<String,ProtoFileContainer> ConstructProtoFileContainers(List<FileDescriptorProto> fileDescriptors) {
  Map<String,ProtoFileContainer> containers = {};
  for (final file in fileDescriptors) {
    containers[file.package] = ConstructProtoFileContainer(file);
  }

  return containers;
}

ProtoFileContainer ConstructProtoFileContainer(FileDescriptorProto fileDescriptor) {
  final messagesMap = ConstructMessages(fileDescriptor.messageType, {}, fileDescriptor.package.isEmpty ? '' : fileDescriptor.package);
  final services = ConstructServices(fileDescriptor.service, fileDescriptor.package.isEmpty ? '' : fileDescriptor.package);
  ProtoFileContainer container = ProtoFileContainer(
    package: fileDescriptor.package,
    fileName: fileDescriptor.name,
    messages: messagesMap,
    imports: fileDescriptor.dependency,
    services: {
      for (var service in services) service.name: service,
    },
  );

  return container;
}

List<ServiceType> ConstructServices(
  List<ServiceDescriptorProto> serviceDescriptors,
  String packageName,
) {
  List<ServiceType> services = [];
  for (final service in serviceDescriptors) {
    final serviceName = packageName.isNotEmpty
        ? '$packageName.${service.name}'
        : service.name;

    final serviceType = ServiceType(name: serviceName, methods: {});
    for (final method in service.method) {
      serviceType.methods[method.name] = MethodType(
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

Map<String, ProtoMessage> ConstructMessages(
  List<DescriptorProto> messageDescriptors,
  Map<String, ProtoMessage> messageMap,
    String prefixDefinition ,
) {

  for (final msg in messageDescriptors) {
    final messageName = prefixDefinition.isNotEmpty ? '$prefixDefinition.${msg.name}' : msg.name;
    final protoMessage = ProtoMessage(messageName, fields: [],isMapEntry: msg.options.mapEntry);
    for (final field in msg.field) {
      final fieldType = ProtoType.fromValue_toProtoType(field.type.value);
      final protoField = ProtoField(
        fieldNumber: field.number,
        fieldName: field.name,
        fieldType: fieldType,
        isDataSet: false,
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




