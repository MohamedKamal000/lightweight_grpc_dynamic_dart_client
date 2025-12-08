import 'dart:io';
import '../../proto_descriptor/descriptor.pb.dart';

Future<FileDescriptorSet> compileProtoAtRuntime(
  String protoFileName,
  String outputPath,
) async {
  final result = await Process.run(
    'core/tools/protoc/Windows/protoc.exe', // should be adjusted based on OS
    [
      '--proto_path=${Directory(protoFileName).parent.path}',
      '--include_imports',
      '--descriptor_set_out=$outputPath.desc',
      protoFileName, // should receive full path instead and also be a list of files not just one
    ],
  );
  if (result.exitCode != 0) {
    throw Exception('protoc failed: ${result.stderr}');
  }

  final bytes = await File(outputPath + '.desc').readAsBytes();
  return FileDescriptorSet.fromBuffer(bytes);
}
