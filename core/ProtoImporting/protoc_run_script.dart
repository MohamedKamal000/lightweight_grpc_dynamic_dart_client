import 'dart:io';
import '../../proto_descriptor/descriptor.pb.dart';

Future<FileDescriptorSet> compileProtoAtRuntime(
  String protoPath,
  String outputPath,
) async {
  final result = await Process.run('cmd', [
    'core/tools/protoc/Windows/protoc.exe',
    'protoc --proto_path=. --include_imports --descriptor_set_out=${outputPath} ${protoPath}',
  ]);
  if (result.exitCode != 0) {
    throw Exception('protoc failed: ${result.stderr}');
  }

  final bytes = await File(outputPath).readAsBytes();
  return FileDescriptorSet.fromBuffer(bytes);
}
