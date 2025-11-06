import 'package:grpc/grpc.dart';
import 'proto_generated/reflection.pbgrpc.dart';


class ReflectionClient {
  final ClientChannel _channel;
  final ServerReflectionClient _stub;

  ReflectionClient(this._channel)
      : _stub = ServerReflectionClient(_channel);

  /// List all services on the server using reflection.
  Stream<ServerReflectionResponse> getServicesStream() {
    final responseStream = _stub.serverReflectionInfo(
      Stream.fromIterable([
        ServerReflectionRequest(fileContainingSymbol: 'api_design.PlayerManager')
      ]),
    );


    return responseStream;
  }
}
