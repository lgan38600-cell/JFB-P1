import 'package:flutter_application_1/core/serial/serial_recognition_service.dart';

SerialRecognitionService createSerialRecognitionService() {
  return const _UnsupportedSerialRecognitionService();
}

class _UnsupportedSerialRecognitionService implements SerialRecognitionService {
  const _UnsupportedSerialRecognitionService();

  @override
  Future<SerialRecognitionResult> captureSerialNumber() async {
    return const SerialRecognitionResult.unsupported();
  }

  @override
  void dispose() {}
}
