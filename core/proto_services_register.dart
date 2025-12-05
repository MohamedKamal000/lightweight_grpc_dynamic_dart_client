


import 'proto_file_container.dart';

Map<String, ProtoFileContainer> registeredProtoServices = {};



void RegisterProtoContainer(ProtoFileContainer container) {
  String key = container.package.startsWith('.') ? 'Global' : container.package;
  if (registeredProtoServices.containsKey(container.package)) {
    throw Exception('Proto service for package ${container.package} is already registered.');
  }
  registeredProtoServices[key] = container;
}

ProtoFileContainer GetRegisteredProtoContainer(String packageName) {
  if (!registeredProtoServices.containsKey(packageName.startsWith('.') ? 'Global' : packageName)) {
    throw Exception('Proto service for package $packageName is not registered.');
  }

  String key = packageName.startsWith('.') ? 'Global' : packageName;
  return registeredProtoServices[key]!;
}