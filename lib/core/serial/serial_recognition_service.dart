abstract class SerialRecognitionService {
  Future<SerialRecognitionResult> captureSerialNumber();

  void dispose();
}

class SerialRecognitionResult {
  const SerialRecognitionResult._({
    required this.status,
    this.serialNumber,
    this.rawText,
    this.errorMessage,
  });

  const SerialRecognitionResult.success({
    required String serialNumber,
    String? rawText,
  }) : this._(
         status: SerialRecognitionStatus.success,
         serialNumber: serialNumber,
         rawText: rawText,
       );

  const SerialRecognitionResult.cancelled()
    : this._(status: SerialRecognitionStatus.cancelled);

  const SerialRecognitionResult.noMatch({String? rawText})
    : this._(status: SerialRecognitionStatus.noMatch, rawText: rawText);

  const SerialRecognitionResult.unsupported()
    : this._(status: SerialRecognitionStatus.unsupported);

  const SerialRecognitionResult.error(String message)
    : this._(
         status: SerialRecognitionStatus.error,
         errorMessage: message,
       );

  final SerialRecognitionStatus status;
  final String? serialNumber;
  final String? rawText;
  final String? errorMessage;

  bool get isSuccess => status == SerialRecognitionStatus.success;
}

enum SerialRecognitionStatus {
  success,
  cancelled,
  noMatch,
  unsupported,
  error,
}

String normalizeSerialNumber(String value) {
  final uppercase = value.toUpperCase();
  final compact = uppercase.replaceAll(RegExp(r'\s+'), '');
  final cleaned = compact.replaceAll(RegExp(r'[^A-Z0-9-]'), '');
  return cleaned.replaceAll(RegExp(r'-{2,}'), '-').replaceAll(
    RegExp(r'^-|-$'),
    '',
  );
}

bool isLikelySerialNumber(String value) {
  final normalized = normalizeSerialNumber(value);
  if (normalized.length < 6 || normalized.length > 24) {
    return false;
  }
  if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(normalized)) {
    return false;
  }

  final digitCount = RegExp(r'\d').allMatches(normalized).length;
  final letterCount = RegExp(r'[A-Z]').allMatches(normalized).length;

  if (digitCount < 3) {
    return false;
  }

  return letterCount > 0 || normalized.length >= 8;
}

String? extractSerialNumber(String recognizedText) {
  final uniqueCandidates = <String>{};

  for (final rawLine in recognizedText.split(RegExp(r'[\r\n]+'))) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }

    final normalizedLine = normalizeSerialNumber(line);
    if (isLikelySerialNumber(normalizedLine)) {
      uniqueCandidates.add(normalizedLine);
    }

    for (final match in RegExp(r'[A-Z0-9-]{6,24}').allMatches(line.toUpperCase())) {
      final candidate = normalizeSerialNumber(match.group(0) ?? '');
      if (isLikelySerialNumber(candidate)) {
        uniqueCandidates.add(candidate);
      }
    }
  }

  if (uniqueCandidates.isEmpty) {
    return null;
  }

  final sortedCandidates = uniqueCandidates.toList(growable: false)
    ..sort((a, b) {
      final scoreA = _serialScore(a);
      final scoreB = _serialScore(b);
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return b.length.compareTo(a.length);
    });

  return sortedCandidates.first;
}

int _serialScore(String candidate) {
  final hasLetter = RegExp(r'[A-Z]').hasMatch(candidate) ? 4 : 0;
  final hasHyphen = candidate.contains('-') ? 1 : 0;
  final digitCount = RegExp(r'\d').allMatches(candidate).length;
  return hasLetter + hasHyphen + digitCount;
}
