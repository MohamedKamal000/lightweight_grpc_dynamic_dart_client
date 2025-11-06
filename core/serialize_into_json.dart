import 'dart:convert';
import 'dart:io';
import '../proto_descriptor/descriptor.pb.dart';
import 'proto_file_container.dart';
import 'proto_types.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_type.dart';

void SerializeProtoFiles(List<FileDescriptorProto> fileDescriptors) {
  List<ProtoFileContainer> containers = [];
  for (final file in fileDescriptors) {
    final messagesMap = ConstructMessages(file.messageType, {});
    containers.add(ProtoFileContainer(fileName: file.name,messages: messagesMap,imports: file.dependency));
  }

  print(containers);
}


void SerializeProtoFile(FileDescriptorProto fileDescriptors) {
  List<ProtoFileContainer> containers = [];
  final messagesMap = ConstructMessages(fileDescriptors.messageType, {});
  containers.add(ProtoFileContainer(fileName: fileDescriptors.name,messages: messagesMap,imports: fileDescriptors.dependency));

  for (final container in containers) {
    print(container.toString());
    print('===================');
    print(jsonEncode(container.toJson()));
    File('./jsonFiles/testingSerialization.json').writeAsString(jsonEncode(container.toJson()));
  }
}


Map<String,ProtoMessage> ConstructMessages(List<DescriptorProto> messageDescriptors,Map<String,ProtoMessage> messageMap) {
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
