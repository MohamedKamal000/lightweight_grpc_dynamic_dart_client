import 'package:grpc/grpc.dart';
import 'core/debugging.dart';
import 'core/proto_data_convertor/proto_encoder.dart';
import 'core/proto_data_convertor/utilities.dart';
import 'core/serialize_into_json.dart';
import 'grpc_request_sender.dart';
import 'proto_descriptor/descriptor.pb.dart';
import 'reflection_client.dart';


Future<void> MakeRequest() async{
  final channel = ClientChannel(
    'localhost',
    port: 50051,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );

  final reflection = ReflectionClient(channel);

  final services = await reflection.getServicesStream();

  services.listen((data) {
    if (data.hasFileDescriptorResponse()) {
      final fdResponse = data.fileDescriptorResponse;
      for (final bytes in fdResponse.fileDescriptorProto) {
        final descriptor = FileDescriptorProto.fromBuffer(bytes);
        SerializeProtoFile(descriptor);
      }
    }
  },
      onError:(err) {
        print('Error: $err');
      },
      onDone: () async{
        await channel.shutdown();
      });


}

Future<void> main(List<String> args) async {
  String encodedShit = TrySendMessageAsRequest();
  var binaryString = ConvertHexadecimalToBytes(encodedShit);
  print('Encoded Request Data (Hex): $encodedShit');
  DynamicGrpcClient dynamicGrpcClient = DynamicGrpcClient(
    ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    ),
  );

  var result = await dynamicGrpcClient.CallMethod('api_design.PlayerManager', 'GetPlayer', binaryString);
  print('Response Data (Hex): ${ConvertBytesToHexadecimal(result)}');
}
