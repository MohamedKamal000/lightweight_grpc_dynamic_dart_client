/*

encoding and decoding does not consider handling overflows, there must be a way to handle these later on
*/



import 'dart:typed_data';

String ConvertDecimalToBinary(int decimalNumber) {
  String binary = int.parse(decimalNumber.toString(),radix: 10).toRadixString(2);
  return binary;
}

int ConvertBinaryToDecimal(String binaryString) {
  int decimalNumber = int.parse(binaryString,radix: 2);
  return decimalNumber;
}


String ConvertDecimalToHexadecimal(int decimalNumber) {
  String hexadecimalString = decimalNumber.toRadixString(16);

  if (hexadecimalString.length % 2 != 0){
    hexadecimalString = '0' + hexadecimalString;
  }

  return hexadecimalString;
}

String ConvertBinaryToHexadecimal(String binaryString) {
  int decimalNumber = int.parse(binaryString,radix: 2);
  String hexadecimalString = decimalNumber.toRadixString(16);

  if (hexadecimalString.length % 2 != 0){
    hexadecimalString = '0' + hexadecimalString;
  }

  return hexadecimalString;
}

String ConvertHexadecimalToBinary(String hexadecimalString) {
  int decimalNumber = int.parse(hexadecimalString,radix: 16);
  String binaryString = decimalNumber.toRadixString(2);
  return binaryString;
}

List<int> ConvertHexadecimalToBytes(String hexadecimalString) {
  List<int> bytes = [];
  for (int i = 0; i < hexadecimalString.length; i += 2) {
    String byteString = hexadecimalString.substring(i, i + 2);
    int byteValue = int.parse(byteString, radix: 16);
    bytes.add(byteValue);
  }
  return bytes;
}

String ConvertBytesToHexadecimal(List<int> bytes) {
  StringBuffer hexadecimalString = StringBuffer();
  for (int byte in bytes) {
    String byteString = byte.toRadixString(16).padLeft(2, '0');
    hexadecimalString.write(byteString);
  }
  return hexadecimalString.toString();
}

String reverseString(String input) {
  return input.split('').reversed.join();
}

List<int> encodeFloat32(double value) {
  final bytes = ByteData(4);
  bytes.setFloat32(0, value, Endian.little);
  return bytes.buffer.asUint8List();
}

List<int> encodeFloat64(double value) {
  final bytes = ByteData(8);
  bytes.setFloat64(0, value, Endian.little);
  return bytes.buffer.asUint8List();
}


int EncodeZigZag32(int n) {
  return (n << 1) ^ (n >> 31);
}

int DecodeZigZag32(int n) {
  return (n >> 1) ^ -(n & 1);
}