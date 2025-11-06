



/*
  Service =>
  Method =>
  some how get the request input as a json and seralize it using descriptor
  then send the request using grpc client

*/



import 'package:grpc/grpc.dart';

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

}