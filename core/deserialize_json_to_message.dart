import 'proto_file_container.dart';
import 'proto_types.dart';
import 'proto_types/field_data.dart';
import 'proto_types/field_type.dart';
import 'proto_types/message_data.dart';
import 'proto_types/message_type.dart';

class DeserializeJsonToMessage {
  final dynamic data;
  final ProtoMessageDefinition messageStructure;
  final ProtoFileContainer container;

  DeserializeJsonToMessage({
    required this.data,
    required this.messageStructure,
    required this.container,
  });

  ProtoMessageDefinition GetMessageStructureByName(String typeName) {
    for (var field in messageStructure.fields) {
      if (field.typeName == typeName &&
          field.fieldType == ProtoType.TYPE_MESSAGE) {
        return container.messages![typeName.replaceFirst('.', '')]!;
      }
    }
    throw Exception('Message structure for typeName $typeName not found.');
  }

  ProtoMessageData Deserialize() {
    List<ProtoFieldData> deserializedFields = [];

    for (var field in messageStructure.fields) {
      if (data[field.fieldName] == null &&
          field.fieldLabel == ProtoLabel.LABEL_REQUIRED) {
        throw Exception(
          'Required field ${field.fieldName} is missing in the provided data.',
        );
      }

      if (data[field.fieldName] != null) {
        dynamic fieldValue = data[field.fieldName];

        if (field.fieldType == ProtoType.TYPE_MESSAGE &&
            field.typeName != null) {
          ProtoMessageDefinition nestedMessageStructure =
              GetMessageStructureByName(field.typeName!);
          if (nestedMessageStructure.isMapEntry) {
            ProtoFieldData mapField = HandleMapField(
              nestedMessageStructure,
              field,
              fieldValue,
            );
            deserializedFields.add(mapField);
            continue;
          }

          if (field.fieldLabel == ProtoLabel.LABEL_REPEATED) {
            ProtoFieldData repeatedField = HandleRepeatedMessagesField(
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
            ProtoMessageData nestedMessage = deserializer.Deserialize();
            deserializedFields.add(
              ProtoFieldData(
                fieldDefinition: ProtoFieldDefinition(
                  fieldNumber: field.fieldNumber,
                  fieldName: field.fieldName,
                  fieldType: field.fieldType,
                  fieldLabel: field.fieldLabel,
                ),
                data: nestedMessage,
              ),
            );
          }
        } else {
            deserializedFields.add(
              ProtoFieldData(fieldDefinition: ProtoFieldDefinition(
                fieldNumber: field.fieldNumber,
                fieldName: field.fieldName,
                fieldType: field.fieldType,
                fieldLabel: field.fieldLabel,
              ),data: fieldValue),
            );
          }
        }
      else {
        throw Exception(
          'Field ${field.fieldName} is not set in the provided data.',
        );
      }
    }

    return ProtoMessageData(
      messageDefinition: messageStructure,
      fieldsData: deserializedFields,
    );
  }

  ProtoFieldData HandleMapField(
    ProtoMessageDefinition nestedMessageStructure,
    ProtoFieldDefinition field,
    dynamic fieldValue,
  ) {
    List<ProtoMessageData> mapEntryMessages = [];
    for (final mapEntry in fieldValue.entries) {
      DeserializeJsonToMessage keyValueDeserializer = DeserializeJsonToMessage(
        data: {
          nestedMessageStructure.fields[0].fieldName: mapEntry.key,
          nestedMessageStructure.fields[1].fieldName: mapEntry.value,
        },
        messageStructure: nestedMessageStructure,
        container: container,
      );
      ProtoMessageData mapEntryMessage = keyValueDeserializer.Deserialize();
      mapEntryMessages.add(mapEntryMessage);
    }
    return ProtoFieldData(
      fieldDefinition: ProtoFieldDefinition(
        fieldNumber: field.fieldNumber,
        fieldName: field.fieldName,
        fieldType: field.fieldType,
        fieldLabel: field.fieldLabel,
      ),
      data: mapEntryMessages,
    );
  }

  ProtoFieldData HandleRepeatedMessagesField(
    ProtoMessageDefinition nestedMessageStructure,
    ProtoFieldDefinition field,
    dynamic fieldValue,
  ) {
    List<ProtoMessageData> repeatedMessages = [];
    for (final item in fieldValue) {
      DeserializeJsonToMessage itemDeserializer = DeserializeJsonToMessage(
        data: item,
        messageStructure: nestedMessageStructure,
        container: container,
      );
      ProtoMessageData itemMessage = itemDeserializer.Deserialize();
      repeatedMessages.add(itemMessage);
    }
    return ProtoFieldData(
      fieldDefinition: ProtoFieldDefinition(
        fieldNumber: field.fieldNumber,
        fieldName: field.fieldName,
        fieldType: field.fieldType,
        fieldLabel: field.fieldLabel,
      ),
      data: repeatedMessages,
    );
  }
}
