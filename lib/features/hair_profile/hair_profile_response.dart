import 'dart:convert';

class HairProfileResponse {
  const HairProfileResponse({
    required this.hairType,
    required this.hairLength,
    required this.hairThickness,
    required this.styleRetention,
    required this.stylingExperience,
    required this.stylingGoals,
  });

  final String hairType;
  final String hairLength;
  final String hairThickness;
  final String styleRetention;
  final String stylingExperience;
  final List<String> stylingGoals;

  factory HairProfileResponse.fromJsonString(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return HairProfileResponse(
      hairType: map['hairType'] as String,
      hairLength: map['hairLength'] as String,
      hairThickness: map['hairThickness'] as String,
      styleRetention: map['styleRetention'] as String,
      stylingExperience: map['stylingExperience'] as String,
      stylingGoals: (map['stylingGoals'] as List<dynamic>)
          .cast<String>()
          .toList(growable: false),
    );
  }

  String toJsonString() {
    return jsonEncode(<String, dynamic>{
      'hairType': hairType,
      'hairLength': hairLength,
      'hairThickness': hairThickness,
      'styleRetention': styleRetention,
      'stylingExperience': stylingExperience,
      'stylingGoals': stylingGoals,
    });
  }
}
