import 'package:flutter_application_1/core/serial/serial_recognition_service.dart';
import 'package:flutter_application_1/core/serial/serial_recognition_service_stub.dart'
    if (dart.library.io) 'package:flutter_application_1/core/serial/serial_recognition_service_io.dart'
    as implementation;

SerialRecognitionService createSerialRecognitionService() {
  return implementation.createSerialRecognitionService();
}
