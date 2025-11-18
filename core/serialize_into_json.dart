import '../proto_descriptor/descriptor.pb.dart';
import 'proto_file_container.dart';
import 'proto_types.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_type.dart';
import 'proto_types/method_type.dart';
import 'proto_types/service_type.dart';

void SerializeProtoFiles(List<FileDescriptorProto> fileDescriptors) {
  List<ProtoFileContainer> containers = [];
  for (final file in fileDescriptors) {
    final messagesMap = ConstructMessages(file.messageType, {});
    containers.add(
      ProtoFileContainer(
        fileName: file.name,
        messages: messagesMap,
        imports: file.dependency,
      ),
    );
  }

  print(containers);
}

ProtoFileContainer ConstructProtoFileContainer(FileDescriptorProto fileDescriptors) {
  final messagesMap = ConstructMessages(fileDescriptors.messageType, {});
  final services = ConstructServices(fileDescriptors.service);
  ProtoFileContainer container = ProtoFileContainer(
    fileName: fileDescriptors.name,
    messages: messagesMap,
    imports: fileDescriptors.dependency,
    services: {
      for (var service in services) service.name: service,
    },
  );

  return container;
}

List<ServiceType> ConstructServices(
  List<ServiceDescriptorProto> serviceDescriptors,
) {
  List<ServiceType> services = [];
  for (final service in serviceDescriptors) {
    final serviceType = ServiceType(name: service.name, methods: {});
    for (final method in service.method) {

      serviceType.methods[method.name] = MethodType(
        methodName: method.name,
        inputType: method.inputType.split('.').last,
        outputType: method.inputType.split('.').last,
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
) {
  for (final msg in messageDescriptors) {
    final protoMessage = ProtoMessage(msg.name, fields: []);
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

    messageMap[msg.name!] = protoMessage;

    if (msg.nestedType.isNotEmpty) {
      ConstructMessages(msg.nestedType, messageMap);
    }
  }

  return messageMap;
}
