import 'proto_types/message_type.dart';
import 'proto_types/proto_json_serialization_interface.dart';

class ProtoFileContainer implements ProtoJsonSerializationInterface {
  final String fileName;
  late Map<String, ProtoMessage>? messages;
  late List<String> ?imports;

  ProtoFileContainer({required this.fileName, this.messages,this.imports});

  void SetMessages(Map<String, ProtoMessage> msgs) {
    messages = msgs;
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
          messages!.values.map((m) => m.toString()).join('\n=========\n'));
    }

    return buffer.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'imports': imports,
      'messages': messages?.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
