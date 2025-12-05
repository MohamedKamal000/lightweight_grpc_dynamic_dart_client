import 'proto_types/message_type.dart';
import 'proto_types/proto_json_serialization_interface.dart';
import 'proto_types/service_type.dart';

class ProtoFileContainer implements ProtoJsonSerializationInterface {
  final String fileName;
  final String package;
  late Map<String, ProtoMessageDefinition>? messages;
  late List<String>? imports;
  late Map<String, ProtoFileContainer> importedContainers = {};
  late Map<String, ProtoServiceDefinition>?
  services; // we need services too here (will act as a way to lookup services a server expose)

  ProtoFileContainer({
    required this.fileName,
    required this.package,
    this.messages,
    this.imports,
    this.services,
  });

  void SetMessages(Map<String, ProtoMessageDefinition> msgs) {
    messages = msgs;
  }

  void SetServices(Map<String, ProtoServiceDefinition> services) {
    this.services = services;
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.writeln('File: $fileName');
    if (imports != null && imports!.isNotEmpty) {
      buffer.writeln('Imports: ${imports!.join(', ')}');
    }
    buffer.writeln('-----------------------------');
    if (messages == null || messages!.isEmpty) {
      buffer.writeln('(No messages)');
    } else {
      buffer.writeln(
        messages!.values.map((m) => m.toString()).join('\n=========\n'),
      );
    }

    return buffer.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'imports': imports,
      'messages': messages?.map((key, value) => MapEntry(key, value.toJson())),
      'services': services?.map((k,v) => MapEntry(k, v.toJson())),
    };
  }
}
