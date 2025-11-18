import 'package:grpc/grpc.dart';
import 'proto_generated/reflection.pbgrpc.dart';


class ReflectionClient {
  // final ClientChannel _channel;
  final String _host;
  final int _port;
  late ServerReflectionClient _stub;
  late ClientChannel clientChannel;
  late ChannelOptions _options = ChannelOptions(credentials: ChannelCredentials.insecure());

  ReflectionClient(this._host, this._port) {
    clientChannel = ClientChannel(
      _host,
      port: _port,
      options: _options,
    );
    _stub = ServerReflectionClient(clientChannel);
  }



  /// List all services on the server using reflection.
  Stream<ServerReflectionResponse> getServicesStream() {
    final responseStream = _stub.serverReflectionInfo(
      Stream.fromIterable([
        ServerReflectionRequest(fileContainingSymbol: 'api_design.GamePlayerManager')
      ]),
    );

    return responseStream;
  }

  Future<void> close() async {
    await clientChannel.shutdown();
  }
}
