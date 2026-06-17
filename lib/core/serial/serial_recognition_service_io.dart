import 'dart:io';

import 'package:flutter_application_1/core/serial/serial_recognition_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

SerialRecognitionService createSerialRecognitionService() {
  return _MobileSerialRecognitionService(
    picker: ImagePicker(),
    recognizer: TextRecognizer(script: TextRecognitionScript.latin),
  );
}

class _MobileSerialRecognitionService implements SerialRecognitionService {
  _MobileSerialRecognitionService({
    required this.picker,
    required this.recognizer,
  });

  final ImagePicker picker;
  final TextRecognizer recognizer;

  @override
  Future<SerialRecognitionResult> captureSerialNumber() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const SerialRecognitionResult.unsupported();
    }

    try {
      final image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
      );

      if (image == null) {
        return const SerialRecognitionResult.cancelled();
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await recognizer.processImage(inputImage);
      final serialNumber = extractSerialNumber(recognizedText.text);

      if (serialNumber == null) {
        return SerialRecognitionResult.noMatch(rawText: recognizedText.text);
      }

      return SerialRecognitionResult.success(
        serialNumber: serialNumber,
        rawText: recognizedText.text,
      );
    } catch (error) {
      final message = error.toString().trim();
      if (message.isEmpty) {
        return const SerialRecognitionResult.error(
          'Unable to recognize the serial number right now.',
        );
      }
      return SerialRecognitionResult.error(message);
    }
  }

  @override
  void dispose() {
    recognizer.close();
  }
}
