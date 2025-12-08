import 'proto_types/message_type.dart';
import 'proto_types/proto_json_serialization_interface.dart';
import 'proto_types/service_type.dart';

class ProtoFileContainer implements ProtoJsonDeserializationInterface {
  final String fileName;
  final String package;
  late Map<String, ProtoMessageDefinition>? _messages;
  final Map<String, ProtoFileContainer> imports = {};
  late Map<String, ProtoServiceDefinition>?
  services; // we need services too here (will act as a way to lookup services a server expose)

  ProtoFileContainer({
    required this.fileName,
    required this.package,
    this.services,
  }) {}

  void SetMessages(Map<String, ProtoMessageDefinition> msgs) {
    _messages = msgs;
  }

  void SetImports(Map<String, ProtoFileContainer> imports) {
    this.imports.clear();
    this.imports.addAll(imports);
  }

  ProtoMessageDefinition GetMessageDefinition(String message){
      for (var import in imports.values){
        var msgDef = import.GetMessageDefinition(message);
          return msgDef;
      }

    if (_messages == null || !_messages!.containsKey(message)){
      throw Exception('Message definition for $message not found in file $fileName');
    }
    return _messages![message]!;
  }

  void SetServices(Map<String, ProtoServiceDefinition> services) {
    this.services = services;
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.writeln('File: $fileName');
    if (imports.isNotEmpty) {
      buffer.writeln('Imports: ${imports.keys.join(', ')}');
    }
    buffer.writeln('-----------------------------');
    if (_messages == null || _messages!.isEmpty) {
      buffer.writeln('(No messages)');
    } else {
      buffer.writeln(
        _messages!.values.map((m) => m.toString()).join('\n=========\n'),
      );
    }

    return buffer.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'package' : package,
      'imports': imports.map((k, v) => MapEntry(k, v.toJson())),
      'messages': _messages?.map((key, value) => MapEntry(key, value.toJson())),
      'services': services?.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}
