import '../proto_descriptor/descriptor.pb.dart';
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



void TestDataEncoding(){
  ProtoMessage message = ProtoMessage('TestMessage', fields: [
    ProtoField(fieldNumber: 1,fieldName: 'name',fieldType: ProtoType.TYPE_STRING,fieldLabel: ProtoLabel.LABEL_OPTIONAL,isDataSet: true,data: 'Test Name'),
    ProtoField(fieldNumber: 2,fieldName: 'id',fieldType: ProtoType.TYPE_INT32,fieldLabel: ProtoLabel.LABEL_OPTIONAL,isDataSet: true,data: 3049),
    ProtoField(fieldNumber: 3,fieldName: 'health',fieldType: ProtoType.TYPE_FLOAT,fieldLabel: ProtoLabel.LABEL_OPTIONAL,isDataSet: true,data: 3.14),
    ProtoField(fieldNumber: 4,fieldName: 'type',fieldType: ProtoType.TYPE_ENUM,fieldLabel: ProtoLabel.LABEL_OPTIONAL,isDataSet: true,data: 0),
    ProtoField(fieldNumber: 5,fieldName: 'items',fieldType: ProtoType.TYPE_MESSAGE,fieldLabel: ProtoLabel.LABEL_REPEATED,isDataSet: true, listOfData_if_repeated: [
      ProtoMessage('Item', fields: [ProtoField(fieldNumber: 1,fieldName: 'itemName',fieldType: ProtoType.TYPE_STRING,fieldLabel: ProtoLabel.LABEL_OPTIONAL,isDataSet: true,data: 'Sword'),]),
      ProtoMessage('Item', fields: [ProtoField(fieldNumber: 1,fieldName: 'itemName',fieldType: ProtoType.TYPE_STRING,fieldLabel: ProtoLabel.LABEL_OPTIONAL,isDataSet: true,data: 'Bow'),]),
      ProtoMessage('Item', fields: [ProtoField(fieldNumber: 1,fieldName: 'itemName',fieldType: ProtoType.TYPE_STRING,fieldLabel: ProtoLabel.LABEL_OPTIONAL,isDataSet: true,data: 'Staff'),])
    ]),
  ]);

  String encodedData = message.EncodeMessage();
  print('Encoded Data:\n$encodedData');
}


String TrySendMessageAsRequest(){
  ProtoMessage message = ProtoMessage('PlayerQuery', fields:[
    ProtoField(fieldNumber: 1, fieldName: 'playerId', fieldType: ProtoType.TYPE_INT32, fieldLabel: ProtoLabel.LABEL_OPTIONAL, isDataSet: true, data: 12345),
  ]);

  String encodedData = message.EncodeMessage();
  return encodedData;
}