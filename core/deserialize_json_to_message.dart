/*

  methodName
   "GetPlayers" : {
      "field" : "value"
      // field may be a protoMessage sometime
      "field" : {
        "field" : "value"
        ....
      }
   }


   {
   "service" : "PlayerService",
   "method" : "GetPlayers",
   "data" :{

   }
   }
*/

// i need a way to extract fields information from json and create protoMessage objects
import 'dart:convert';

import 'proto_types.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_type.dart';

class DeserializeJsonToMessage {
  final dynamic data;
  final ProtoMessage messageStructure;

  DeserializeJsonToMessage({
    required this.data,
    required this.messageStructure,
  });


  ProtoMessage GetMessageStructureByName(String typeName) { // too lazy to make a map inside the protoMessage class :>
   for (var field in messageStructure.fields) {
     if (field.typeName == typeName && field.fieldType == ProtoType.TYPE_MESSAGE) {
       return messageStructure;
     }
   }
   throw Exception('Message structure for typeName $typeName not found.');
  }


  ProtoMessage Deserialize(){
    List<ProtoField> deserializedFields = [];

    for (var field in messageStructure.fields) {

      if (data[field.fieldName] == null && field.fieldLabel == ProtoLabel.LABEL_REQUIRED) {
        throw Exception('Required field ${field.fieldName} is missing in the provided data.');
      }

      if (data[field.fieldName] != null) {
        dynamic fieldValue = data[field.fieldName];

        if (field.fieldType == ProtoType.TYPE_MESSAGE && field.typeName != null) {
          // Assuming we have a way to get the ProtoMessage structure by typeName
          ProtoMessage nestedMessageStructure = GetMessageStructureByName(field.typeName!);

          if (field.fieldLabel == ProtoLabel.LABEL_REPEATED) {
            List<ProtoMessage> nestedMessages = [];
            for (var item in fieldValue) {
              DeserializeJsonToMessage deserializer = DeserializeJsonToMessage(
                data: item,
                messageStructure: nestedMessageStructure,
              );
              nestedMessages.add(deserializer.Deserialize());
            }
            deserializedFields.add(ProtoField(
              fieldNumber: field.fieldNumber,
              fieldName: field.fieldName,
              fieldType: field.fieldType,
              fieldLabel: field.fieldLabel,
              isDataSet: true,
              listOfData_if_repeated: nestedMessages,
            ));
          } else {
            DeserializeJsonToMessage deserializer = DeserializeJsonToMessage(
              data: fieldValue,
              messageStructure: nestedMessageStructure,
            );
            ProtoMessage nestedMessage = deserializer.Deserialize();
            deserializedFields.add(ProtoField(
              fieldNumber: field.fieldNumber,
              fieldName: field.fieldName,
              fieldType: field.fieldType,
              fieldLabel: field.fieldLabel,
              isDataSet: true,
              data: nestedMessage,
            ));
          }
        } else {
          if (field.fieldLabel == ProtoLabel.LABEL_REPEATED) {
            deserializedFields.add(ProtoField(
              fieldNumber: field.fieldNumber,
              fieldName: field.fieldName,
              fieldType: field.fieldType,
              fieldLabel: field.fieldLabel,
              isDataSet: true,
              listOfData_if_repeated: jsonDecode(fieldValue),
            ));
          }
          else{
            deserializedFields.add(ProtoField(
              fieldNumber: field.fieldNumber,
              fieldName: field.fieldName,
              fieldType: field.fieldType,
              fieldLabel: field.fieldLabel,
              isDataSet: true,
              data: jsonDecode(fieldValue),
            ));
          }
        }
      }
      else{
        throw Exception('Field ${field.fieldName} is not set in the provided data.');
      }
    }

    return ProtoMessage(
      messageStructure.messageName,
      fields: deserializedFields,
    );
  }

}
