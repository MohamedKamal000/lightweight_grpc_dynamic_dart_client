import 'package:grpc/grpc.dart';
import 'core/grpc_request.dart';
import 'core/proto_data_convertor/utilities.dart';

class DynamicGrpcClient {

  final ClientChannel clientChannel;
  DynamicGrpcClient(this.clientChannel);

  Future<List<int>> _CallMethod(String serviceName, String methodName, List<int> requestBytes) async {
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

  Future MakeCall(GrpcRequest request) async{
    String encodedMessage = request.message.EncodeMessage();
    var binaryString = ConvertHexadecimalToBytes(encodedMessage);
    print('Encoded Request Data (Hex): $encodedMessage'); // debugging

    var result = await this._CallMethod(
      request.service,
      request.method,
      binaryString,
    );


      print('Response Data (Hex): ${ConvertBytesToHexadecimal(result)}');
      this.close();
  }


  void close() {
    clientChannel.shutdown();
  }


}