import 'dart:async';
import 'package:grpc/grpc.dart';
import 'proto_generated/reflection.pbgrpc.dart';

class ReflectionClient {
  final String _host;
  late int _port = 443;
  late ServerReflectionClient _stub;
  late ClientChannel clientChannel;

  ReflectionClient(this._host, this._port, {bool isSecure = false}) {
    print(_port == 443 ? 'Using secure channel' : 'Using insecure channel');
    clientChannel = ClientChannel(
      _host,
      port: _port,
      options: ChannelOptions(
          credentials: isSecure ? ChannelCredentials.secure() : ChannelCredentials.insecure()
      )
    );
    _stub = ServerReflectionClient(clientChannel);
  }

  Stream<ServerReflectionResponse> listServices() {
    print('Requesting list of services from $_host:$_port');

    final responseStream = _stub.serverReflectionInfo(
      Stream.fromIterable([
        ServerReflectionRequest(listServices: '')
      ]),
    );

    return responseStream;
  }

  Stream<ServerReflectionResponse> getServiceStream(String serviceName) {
    final responseStream = _stub.serverReflectionInfo(
      Stream.fromIterable([
        ServerReflectionRequest(fileContainingSymbol: serviceName)
      ]),
    );

    return responseStream;
  }

  Future<ServerReflectionResponse> getFileByNameStream(String fileName) async{
    final responseStream = _stub.serverReflectionInfo(
      Stream.fromIterable([
        ServerReflectionRequest(fileByFilename: fileName)
      ]),
    );

    return await responseStream.single;
  }

  Future<void> close() async {
    await clientChannel.shutdown();
  }
}
