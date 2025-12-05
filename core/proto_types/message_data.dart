import 'field_data.dart';
import 'message_type.dart';

class ProtoMessageData{
  final ProtoMessageDefinition messageDefinition;
  final List<ProtoFieldData> fieldsData;

  ProtoMessageData({required this.messageDefinition,required this.fieldsData});

  String EncodeMessage(){
    StringBuffer buffer = StringBuffer();
    for (var field in fieldsData) {

      buffer.write(field.EncodeData());
    }
    return buffer.toString();
  }
}