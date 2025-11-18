



/*
  Service =>
  Method =>
  some how get the request input as a json and seralize it using descriptor
  then send the request using grpc client

*/



import 'package:grpc/grpc.dart';

import 'core/grpc_request.dart';
import 'core/proto_data_convertor/utilities.dart';

class DynamicGrpcClient {

  final ClientChannel clientChannel;
  DynamicGrpcClient(this.clientChannel);

  /*
    return a byte list of the response
  */
  Future<List<int>> CallMethod(String serviceName, String methodName, List<int> requestBytes) async {
    final method = ClientMethod<List<int>, List<int>>(
      '/$serviceName/$methodName',
      (List<int> value) => value,
      (List<int> value) => value,
    );

    final client = Client(clientChannel, options: CallOptions());
    final response = await client.$createUnaryCall<List<int>, List<int>>(
      method,
      requestBytes,
    );

    return response;
  }

  Stream<List<int>> MakeResponseStream(String serviceName, String methodName, List<int> requestBytes) {
    final method = ClientMethod<List<int>, List<int>>(
      '/$serviceName/$methodName',
      (List<int> value) => value,
      (List<int> value) => value,
    );

    final client = Client(clientChannel, options: CallOptions());
    final responseStream = client.$createStreamingCall<List<int>, List<int>>(
      method,
      Stream.fromIterable([requestBytes]),
    );

    return responseStream;
  }

  Future<void> MakeCall(GrpcRequest request) async{
    String encodedShit = request.message.EncodeMessage(); // peak naming
    var binaryString = ConvertHexadecimalToBytes(encodedShit);
    print('Encoded Request Data (Hex): $encodedShit');
    DynamicGrpcClient dynamicGrpcClient = DynamicGrpcClient(
      ClientChannel(
        'localhost',
        port: 50051,
        options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
      ),
    );

    var stream = await dynamicGrpcClient.MakeResponseStream(
      'api_design.' + request.service,
      request.method,
      binaryString,
    );

    stream.listen(
          (data) {
        print('Response Data (Hex): ${ConvertBytesToHexadecimal(data)}');
      },
      onDone: () {
        dynamicGrpcClient.close();
      },
      onError: (err) {
        print('Error: $err');
      },
    );
  }


  void close() {
    clientChannel.shutdown();
  }


}