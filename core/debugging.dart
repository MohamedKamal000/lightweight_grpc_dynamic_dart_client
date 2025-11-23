import 'dart:convert';
import 'dart:io';

import 'package:grpc/grpc.dart';

import '../grpc_request_sender.dart';
import '../main.dart';
import '../proto_descriptor/descriptor.pb.dart';
import 'grpc_request.dart';
import 'proto_file_container.dart';
import 'proto_types.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_type.dart';

void PrintProtoMessages(List<DescriptorProto> messageDescriptors) {
  for (final msg in messageDescriptors) {
    if (msg.nestedType.isNotEmpty) {
      PrintProtoMessages(msg.nestedType);
    }
    print('message: ${msg.name}');
    print(
      'field: ${msg.field.map((e) => '${e.name} | ${e.type.value == 11 ? e.typeName : ProtoType.fromValue_toProtoType(e.type.value)}}').toList().join(',')}',
    );
  }
}

void TestDataEncoding() {
  ProtoMessage message = ProtoMessage(
    'TestMessage',
    fields: [
      ProtoField(
        fieldNumber: 1,
        fieldName: 'name',
        fieldType: ProtoType.TYPE_STRING,
        fieldLabel: ProtoLabel.LABEL_OPTIONAL,
        isDataSet: true,
        data: 'Test Name',
      ),
      ProtoField(
        fieldNumber: 2,
        fieldName: 'id',
        fieldType: ProtoType.TYPE_INT32,
        fieldLabel: ProtoLabel.LABEL_OPTIONAL,
        isDataSet: true,
        data: 3049,
      ),
      ProtoField(
        fieldNumber: 3,
        fieldName: 'health',
        fieldType: ProtoType.TYPE_FLOAT,
        fieldLabel: ProtoLabel.LABEL_OPTIONAL,
        isDataSet: true,
        data: 3.14,
      ),
      ProtoField(
        fieldNumber: 4,
        fieldName: 'type',
        fieldType: ProtoType.TYPE_ENUM,
        fieldLabel: ProtoLabel.LABEL_OPTIONAL,
        isDataSet: true,
        data: 0,
      ),
      ProtoField(
        fieldNumber: 5,
        fieldName: 'items',
        fieldType: ProtoType.TYPE_MESSAGE,
        fieldLabel: ProtoLabel.LABEL_REPEATED,
        isDataSet: true,
        listOfData_if_repeated: [
          ProtoMessage(
            'Item',
            fields: [
              ProtoField(
                fieldNumber: 1,
                fieldName: 'itemName',
                fieldType: ProtoType.TYPE_STRING,
                fieldLabel: ProtoLabel.LABEL_OPTIONAL,
                isDataSet: true,
                data: 'Sword',
              ),
            ],
          ),
          ProtoMessage(
            'Item',
            fields: [
              ProtoField(
                fieldNumber: 1,
                fieldName: 'itemName',
                fieldType: ProtoType.TYPE_STRING,
                fieldLabel: ProtoLabel.LABEL_OPTIONAL,
                isDataSet: true,
                data: 'Bow',
              ),
            ],
          ),
          ProtoMessage(
            'Item',
            fields: [
              ProtoField(
                fieldNumber: 1,
                fieldName: 'itemName',
                fieldType: ProtoType.TYPE_STRING,
                fieldLabel: ProtoLabel.LABEL_OPTIONAL,
                isDataSet: true,
                data: 'Staff',
              ),
            ],
          ),
        ],
      ),
    ],
  );

  String encodedData = message.EncodeMessage();
  print('Encoded Data:\n$encodedData');
}

String TrySendMessageAsRequest() {
  ProtoMessage message = ProtoMessage(
    'PlayerQuery',
    fields: [
      ProtoField(
        fieldNumber: 1,
        fieldName: 'playerId',
        fieldType: ProtoType.TYPE_INT32,
        fieldLabel: ProtoLabel.LABEL_OPTIONAL,
        isDataSet: true,
        data: 12345,
      ),
    ],
  );

  String encodedData = message.EncodeMessage();
  return encodedData;
}

void TestMessageDesirialization(ProtoFileContainer container) {
  GrpcRequest request = GrpcRequest.fromJson({
    'data': {
      'ids': '[1, 2, 3, 4, 5]',
    },
  }, container, 'GamePlayerManager', 'GetPlayers');

  print('Deserialized GrpcRequest:');
  print('Service: ${request.service}');
  print('Method: ${request.method}');
  print('Message Fields:');
  for (var field in request.message!.fields) {
    print('Field Name: ${field.fieldName}, Field Value: ${field.data}');
  }

}

Future MethodCall(ProtoFileContainer protoFileContainer,String serviceToRequest,String method,String FilePath) async {

  Map<String,dynamic> quickJsonFileDecoder(String jsonFileName){
    String content = File(jsonFileName).readAsStringSync();
    return jsonDecode(content);
  }

  Map<String, dynamic> jsonRequest = {
    'data': quickJsonFileDecoder(FilePath)
  };

  GrpcRequest grpcRequest = GrpcRequest.fromJson(jsonRequest, protoFileContainer,serviceToRequest, method);
  DynamicGrpcClient dynamicGrpcClient = DynamicGrpcClient(
    ClientChannel(
      'localhost',
      port: 50051,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()),
    ),
  );

  await dynamicGrpcClient.MakeCall(grpcRequest);
}

void FullMethodsTest(ProtoFileContainer container,String serviceName) async {
  String basePath = 'jsonFiles/request_tests';
  List<List<String>> methods = [
    ["CreatePlayer",'$basePath/create_player.json'],
    /*["GetPlayer", '$basePath/get_player.json'],
    ["UpdatePlayer", '$basePath/update_player.json'],
    ["DeletePlayer", '$basePath/delete_player.json'],
    ["GetPlayers", '$basePath/get_players.json'],
    ['SearchPlayers', '$basePath/search_players.json']*/
  ];

  for (var method in methods) {
    print('--- Testing Method: ${method[0]} ---');
    await MethodCall(container, serviceName, method[0], method[1]);
    print('--- Finished Method: ${method[0]} ---\n');
  }

}