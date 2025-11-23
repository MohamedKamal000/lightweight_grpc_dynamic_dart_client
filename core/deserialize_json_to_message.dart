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
import 'proto_file_container.dart';
import 'proto_types.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_type.dart';

class DeserializeJsonToMessage {
  final dynamic data;
  final ProtoMessage messageStructure;
  final ProtoFileContainer container;

  DeserializeJsonToMessage({
    required this.data,
    required this.messageStructure,
    required this.container,
  });

  ProtoMessage GetMessageStructureByName(String typeName) {
    // too lazy to make a map inside the protoMessage class :>
    for (var field in messageStructure.fields) {
      if (field.typeName == typeName &&
          field.fieldType == ProtoType.TYPE_MESSAGE) {
        return container.messages![typeName.replaceFirst('.', '')]!;
      }
    }
    throw Exception('Message structure for typeName $typeName not found.');
  }

  ProtoMessage Deserialize() {
    List<ProtoField> deserializedFields = [];

    for (var field in messageStructure.fields) {
      if (data[field.fieldName] == null &&
          field.fieldLabel == ProtoLabel.LABEL_REQUIRED) {
        throw Exception(
          'Required field ${field.fieldName} is missing in the provided data.',
        );
      }

      if (data[field.fieldName] != null) {
        dynamic fieldValue = data[field.fieldName];

        if (field.fieldType == ProtoType.TYPE_MESSAGE && field.typeName != null) {
          ProtoMessage nestedMessageStructure = GetMessageStructureByName(field.typeName!,);
          if (nestedMessageStructure.isMapEntry) {
            ProtoField mapField = HandleMapField(
              nestedMessageStructure,
              field,
              fieldValue,
            );
            deserializedFields.add(mapField);
            continue;
          }

          if (field.fieldLabel == ProtoLabel.LABEL_REPEATED) {
            ProtoField repeatedField = HandleRepeatedField(
              nestedMessageStructure,
              field,
              fieldValue,
            );
            deserializedFields.add(repeatedField);
          } else {
            DeserializeJsonToMessage deserializer = DeserializeJsonToMessage(
              data: fieldValue,
              messageStructure: nestedMessageStructure,
              container: container,
            );
            ProtoMessage nestedMessage = deserializer.Deserialize();
            deserializedFields.add(
              ProtoField(
                fieldNumber: field.fieldNumber,
                fieldName: field.fieldName,
                fieldType: field.fieldType,
                fieldLabel: field.fieldLabel,
                isDataSet: true,
                data: nestedMessage,
              ),
            );
          }
        } else {
          if (field.fieldLabel == ProtoLabel.LABEL_REPEATED) {
            deserializedFields.add(
              ProtoField(
                fieldNumber: field.fieldNumber,
                fieldName: field.fieldName,
                fieldType: field.fieldType,
                fieldLabel: field.fieldLabel,
                isDataSet: true,
                listOfData_if_repeated: fieldValue,
              ),
            );
          } else {
            deserializedFields.add(
              ProtoField(
                fieldNumber: field.fieldNumber,
                fieldName: field.fieldName,
                fieldType: field.fieldType,
                fieldLabel: field.fieldLabel,
                isDataSet: true,
                data: fieldValue,
              ),
            );
          }
        }
      } else {
        throw Exception(
          'Field ${field.fieldName} is not set in the provided data.',
        );
      }
    }

    return ProtoMessage(
      messageStructure.messageName,
      fields: deserializedFields,
    );
  }


  ProtoField HandleMapField(
    ProtoMessage nestedMessageStructure,
    ProtoField field,
    dynamic fieldValue,
  ) {
    List<ProtoMessage> mapEntryMessages = [];
    for (final mapEntry in fieldValue.entries) {
      DeserializeJsonToMessage keyValueDeserializer = DeserializeJsonToMessage(
        data: {
          nestedMessageStructure.fields[0].fieldName: mapEntry.key,
          nestedMessageStructure.fields[1].fieldName: mapEntry.value,
        },
        messageStructure: nestedMessageStructure,
        container: container,
      );
      ProtoMessage mapEntryMessage = keyValueDeserializer.Deserialize();
      mapEntryMessages.add(mapEntryMessage);
    }
    return ProtoField(
      fieldNumber: field.fieldNumber,
      fieldName: field.fieldName,
      fieldType: field.fieldType,
      fieldLabel: field.fieldLabel,
      isDataSet: true,
      listOfData_if_repeated: mapEntryMessages,
    );
  }


  ProtoField HandleRepeatedField(
    ProtoMessage nestedMessageStructure,
    ProtoField field,
    dynamic fieldValue,
  ) {
    List<ProtoMessage> repeatedMessages = [];
    for (final item in fieldValue) {
      DeserializeJsonToMessage itemDeserializer = DeserializeJsonToMessage(
        data: item,
        messageStructure: nestedMessageStructure,
        container: container,
      );
      ProtoMessage itemMessage = itemDeserializer.Deserialize();
      repeatedMessages.add(itemMessage);
    }
    return ProtoField(
      fieldNumber: field.fieldNumber,
      fieldName: field.fieldName,
      fieldType: field.fieldType,
      fieldLabel: field.fieldLabel,
      isDataSet: true,
      listOfData_if_repeated: repeatedMessages,
    );
  }
}
