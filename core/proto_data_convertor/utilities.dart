/*

encoding and decoding does not consider handling overflows, there must be a way to handle these later on
*/



import 'dart:typed_data';

String ConvertDecimalToBinary(int decimalNumber) {
  String binary = int.parse(decimalNumber.toString(),radix: 10).toRadixString(2);
  return binary;
}


String ConvertDecimalToBinary64(BigInt decimalNumber) {
  String binary = BigInt.parse(decimalNumber.toString(),radix: 10).toRadixString(2);
  return binary;
}

String ConvertDecimalToTwosComplement32(int n) {
  String binary = ConvertDecimalToBinary(n.abs());
  binary = binary.padLeft(32, '0');

  List<String> result = binary.split('');
  for (int i = 0; i < result.length; i++) {
    if (result[i] == '0') {
      result[i] = '1';
    } else {
      result[i] = '0';
    }
  }
  String invertedBinary = result.join('');
  int invertedDecimal = ConvertBinaryToDecimal(invertedBinary);
  int twosComplementDecimal = invertedDecimal + 1;
  String twosComplementBinary = ConvertDecimalToBinary(twosComplementDecimal);
  twosComplementBinary = twosComplementBinary.padLeft(32, '0');
  return twosComplementBinary;
}

String ConvertDecimalToTwosComplement64(int n) {
  String binary = ConvertDecimalToBinary(n.abs());
  binary = binary.padLeft(64, '0');

  List<String> result = binary.split('');
  for (int i = 0; i < result.length; i++) {
    if (result[i] == '0') {
      result[i] = '1';
    } else {
      result[i] = '0';
    }
  }
  String invertedBinary = result.join('');
  BigInt invertedDecimal = ConvertBinaryToDecimal64(invertedBinary);
  BigInt twosComplementDecimal = invertedDecimal + BigInt.one;
  String twosComplementBinary = ConvertDecimalToBinary64(twosComplementDecimal);
  twosComplementBinary = twosComplementBinary.padLeft(64, '0');
  return twosComplementBinary;
}

int ConvertBinaryToDecimal(String binaryString) {
  int decimalNumber = int.parse(binaryString,radix: 2);
  return decimalNumber;
}

BigInt ConvertBinaryToDecimal64(String binaryString) {
  BigInt decimalNumber = BigInt.parse(binaryString,radix: 2);
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

BigInt EncodeZigZag64(int n) {
  final bigIntN = BigInt.from(n);
  return (bigIntN << 1) ^ (bigIntN >> 63);
}


int DecodeZigZag32(int n) {
  return (n >> 1) ^ -(n & 1);
}
