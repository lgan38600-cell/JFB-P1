import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/hair_profile/hair_profile_response.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class HairProfileQuestionnairePage extends StatefulWidget {
  const HairProfileQuestionnairePage({super.key, this.initialResponse});

  final HairProfileResponse? initialResponse;

  @override
  State<HairProfileQuestionnairePage> createState() =>
      _HairProfileQuestionnairePageState();
}

class _HairProfileQuestionnairePageState
    extends State<HairProfileQuestionnairePage> {
  int _stepIndex = 0;
  String? _hairType;
  String? _hairLength;
  String? _hairThickness;
  String? _styleRetention;
  String? _stylingExperience;
  final Set<String> _stylingGoals = <String>{};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initialResponse = widget.initialResponse;
    if (initialResponse == null) {
      return;
    }
    _hairType = initialResponse.hairType;
    _hairLength = initialResponse.hairLength;
    _hairThickness = initialResponse.hairThickness;
    _styleRetention = initialResponse.styleRetention;
    _stylingExperience = initialResponse.stylingExperience;
    _stylingGoals.addAll(initialResponse.stylingGoals);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final steps = _buildSteps(localizations);
    final step = steps[_stepIndex];

    return PopScope(
      canPop: _stepIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _stepIndex == 0) {
          return;
        }
        setState(() {
          _stepIndex -= 1;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Text(localizations.hairProfileTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 12),
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: step.type == _QuestionType.imageSingle
                      ? _HairTypeGrid(
                          step: step,
                          selectedValue: _hairType,
                          onSelected: (value) =>
                              setState(() => _hairType = value),
                        )
                      : _ChoicePanel(
                          step: step,
                          selectedValue: step.type == _QuestionType.multiChoice
                              ? null
                              : step.selectedValue!(this),
                          selectedValues: step.type == _QuestionType.multiChoice
                              ? _stylingGoals
                              : null,
                          onSingleSelected: (value) => setState(() {
                            step.assignSingle!(this, value);
                          }),
                          onMultiToggled: (value) => setState(() {
                            if (_stylingGoals.contains(value)) {
                              _stylingGoals.remove(value);
                            } else {
                              _stylingGoals.add(value);
                            }
                          }),
                        ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4452F2),
                      disabledBackgroundColor: const Color(
                        0xFF4452F2,
                      ).withValues(alpha: 0.7),
                    ),
                    onPressed: _canSaveStep(step) && !_isSaving
                        ? () => _saveStep(steps.length)
                        : null,
                    child: Text(localizations.saveButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_QuestionStep> _buildSteps(AppLocalizations localizations) {
    return <_QuestionStep>[
      _QuestionStep.imageSingle(
        title: localizations.hairTypeQuestion,
        description: localizations.hairTypeDescription,
        options: <_QuestionOption>[
          _QuestionOption(
            value: 'straight',
            title: localizations.hairTypeStraight,
            assetPath: 'assets/hair_profile/straight.jpg',
          ),
          _QuestionOption(
            value: 'wavy',
            title: localizations.hairTypeWavy,
            assetPath: 'assets/hair_profile/wavy.jpg',
          ),
          _QuestionOption(
            value: 'curly',
            title: localizations.hairTypeCurly,
            assetPath: 'assets/hair_profile/curly.jpg',
          ),
          _QuestionOption(
            value: 'coily',
            title: localizations.hairTypeCoily,
            assetPath: 'assets/hair_profile/coily.jpg',
          ),
        ],
      ),
      _QuestionStep.singleChoice(
        title: localizations.hairLengthQuestion,
        description: localizations.hairLengthDescription,
        selectedValue: (state) => state._hairLength,
        assignSingle: (state, value) => state._hairLength = value,
        options: <_QuestionOption>[
          _QuestionOption(
            value: 'very_short',
            title: localizations.hairLengthVeryShort,
            subtitle: localizations.hairLengthVeryShortHint,
          ),
          _QuestionOption(
            value: 'short',
            title: localizations.hairLengthShort,
            subtitle: localizations.hairLengthShortHint,
          ),
          _QuestionOption(
            value: 'medium',
            title: localizations.hairLengthMedium,
            subtitle: localizations.hairLengthMediumHint,
          ),
          _QuestionOption(
            value: 'long',
            title: localizations.hairLengthLong,
            subtitle: localizations.hairLengthLongHint,
          ),
          _QuestionOption(
            value: 'very_long',
            title: localizations.hairLengthVeryLong,
            subtitle: localizations.hairLengthVeryLongHint,
          ),
        ],
      ),
      _QuestionStep.singleChoice(
        title: localizations.hairThicknessQuestion,
        description: localizations.hairThicknessDescription,
        selectedValue: (state) => state._hairThickness,
        assignSingle: (state, value) => state._hairThickness = value,
        options: <_QuestionOption>[
          _QuestionOption(
            value: 'fine',
            title: localizations.hairThicknessFine,
            subtitle: localizations.hairThicknessFineHint,
          ),
          _QuestionOption(
            value: 'medium',
            title: localizations.hairThicknessMedium,
            subtitle: localizations.hairThicknessMediumHint,
          ),
          _QuestionOption(
            value: 'coarse',
            title: localizations.hairThicknessCoarse,
            subtitle: localizations.hairThicknessCoarseHint,
          ),
          _QuestionOption(
            value: 'unsure',
            title: localizations.unsureOption,
            subtitle: localizations.unsureOption,
          ),
        ],
      ),
      _QuestionStep.singleChoice(
        title: localizations.styleRetentionQuestion,
        description: localizations.styleRetentionDescription,
        selectedValue: (state) => state._styleRetention,
        assignSingle: (state, value) => state._styleRetention = value,
        options: <_QuestionOption>[
          _QuestionOption(
            value: 'not_long',
            title: localizations.styleRetentionShort,
            subtitle: localizations.styleRetentionShortHint,
          ),
          _QuestionOption(
            value: 'a_while',
            title: localizations.styleRetentionMedium,
            subtitle: localizations.styleRetentionMediumHint,
          ),
          _QuestionOption(
            value: 'long_time',
            title: localizations.styleRetentionLong,
            subtitle: localizations.styleRetentionLongHint,
          ),
          _QuestionOption(
            value: 'unsure',
            title: localizations.unsureOption,
            subtitle: localizations.unsureOption,
          ),
        ],
      ),
      _QuestionStep.singleChoice(
        title: localizations.stylingExperienceQuestion,
        description: localizations.stylingExperienceDescription,
        selectedValue: (state) => state._stylingExperience,
        assignSingle: (state, value) => state._stylingExperience = value,
        options: <_QuestionOption>[
          _QuestionOption(
            value: 'beginner',
            title: localizations.stylingExperienceBeginner,
            subtitle: localizations.stylingExperienceBeginnerHint,
          ),
          _QuestionOption(
            value: 'intermediate',
            title: localizations.stylingExperienceIntermediate,
            subtitle: localizations.stylingExperienceIntermediateHint,
          ),
          _QuestionOption(
            value: 'advanced',
            title: localizations.stylingExperienceAdvanced,
            subtitle: localizations.stylingExperienceAdvancedHint,
          ),
        ],
      ),
      _QuestionStep.multiChoice(
        title: localizations.stylingGoalsQuestion,
        description: localizations.stylingGoalsDescription,
        options: <_QuestionOption>[
          _QuestionOption(
            value: 'volume_curls',
            title: localizations.stylingGoalVolumeCurls,
          ),
          _QuestionOption(
            value: 'straight',
            title: localizations.stylingGoalStraight,
          ),
          _QuestionOption(
            value: 'sleek',
            title: localizations.stylingGoalSleek,
          ),
          _QuestionOption(
            value: 'frizz_control',
            title: localizations.stylingGoalFrizzControl,
          ),
          _QuestionOption(
            value: 'flyaway_management',
            title: localizations.stylingGoalFlyawayManagement,
          ),
          _QuestionOption(
            value: 'natural_finish',
            title: localizations.stylingGoalNaturalFinish,
          ),
          _QuestionOption(
            value: 'quick_style',
            title: localizations.stylingGoalQuickStyle,
          ),
          _QuestionOption(
            value: 'long_lasting',
            title: localizations.stylingGoalLongLasting,
          ),
          _QuestionOption(
            value: 'hair_health',
            title: localizations.stylingGoalHairHealth,
          ),
        ],
      ),
    ];
  }

  bool _canSaveStep(_QuestionStep step) {
    switch (step.type) {
      case _QuestionType.imageSingle:
        return _hairType != null;
      case _QuestionType.singleChoice:
        return step.selectedValue!(this) != null;
      case _QuestionType.multiChoice:
        return _stylingGoals.isNotEmpty;
    }
  }

  Future<void> _saveStep(int totalSteps) async {
    if (_stepIndex < totalSteps - 1) {
      setState(() {
        _stepIndex += 1;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final response = HairProfileResponse(
      hairType: _hairType!,
      hairLength: _hairLength!,
      hairThickness: _hairThickness!,
      styleRetention: _styleRetention!,
      stylingExperience: _stylingExperience!,
      stylingGoals: _stylingGoals.toList(growable: false),
    );
    await AppScope.of(context).saveHairProfileResponse(response);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  void _handleBack() {
    if (_stepIndex == 0) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _stepIndex -= 1;
    });
  }
}

class _HairTypeGrid extends StatelessWidget {
  const _HairTypeGrid({
    required this.step,
    required this.selectedValue,
    required this.onSelected,
  });

  final _QuestionStep step;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: step.options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final option = step.options[index];
        final isSelected = selectedValue == option.value;

        return InkWell(
          onTap: () => onSelected(option.value),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? Colors.amber : AppTheme.outline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(option.assetPath!, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      option.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        shadows: const <Shadow>[
                          Shadow(blurRadius: 12, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.step,
    this.selectedValue,
    this.selectedValues,
    this.onSingleSelected,
    this.onMultiToggled,
  });

  final _QuestionStep step;
  final String? selectedValue;
  final Set<String>? selectedValues;
  final ValueChanged<String>? onSingleSelected;
  final ValueChanged<String>? onMultiToggled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: ListView.separated(
        itemCount: step.options.length,
        separatorBuilder: (_, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final option = step.options[index];
          final isSelected = step.type == _QuestionType.multiChoice
              ? selectedValues!.contains(option.value)
              : selectedValue == option.value;

          return InkWell(
            onTap: () {
              if (step.type == _QuestionType.multiChoice) {
                onMultiToggled?.call(option.value);
              } else {
                onSingleSelected?.call(option.value);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SelectionIndicator(
                    isSelected: isSelected,
                    isMulti: step.type == _QuestionType.multiChoice,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          option.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (option.subtitle != null) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            option.subtitle!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.mutedForeground),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected, required this.isMulti});

  final bool isSelected;
  final bool isMulti;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFB400) : Colors.white,
        borderRadius: BorderRadius.circular(isMulti ? 12 : 12),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFB400) : AppTheme.outline,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 30)
          : null,
    );
  }
}

class _QuestionStep {
  const _QuestionStep._({
    required this.type,
    required this.title,
    required this.description,
    required this.options,
    this.selectedValue,
    this.assignSingle,
  });

  factory _QuestionStep.imageSingle({
    required String title,
    required String description,
    required List<_QuestionOption> options,
  }) {
    return _QuestionStep._(
      type: _QuestionType.imageSingle,
      title: title,
      description: description,
      options: options,
    );
  }

  factory _QuestionStep.singleChoice({
    required String title,
    required String description,
    required List<_QuestionOption> options,
    required String? Function(_HairProfileQuestionnairePageState state)
    selectedValue,
    required void Function(
      _HairProfileQuestionnairePageState state,
      String value,
    )
    assignSingle,
  }) {
    return _QuestionStep._(
      type: _QuestionType.singleChoice,
      title: title,
      description: description,
      options: options,
      selectedValue: selectedValue,
      assignSingle: assignSingle,
    );
  }

  factory _QuestionStep.multiChoice({
    required String title,
    required String description,
    required List<_QuestionOption> options,
  }) {
    return _QuestionStep._(
      type: _QuestionType.multiChoice,
      title: title,
      description: description,
      options: options,
    );
  }

  final _QuestionType type;
  final String title;
  final String description;
  final List<_QuestionOption> options;
  final String? Function(_HairProfileQuestionnairePageState state)?
  selectedValue;
  final void Function(_HairProfileQuestionnairePageState state, String value)?
  assignSingle;
}

class _QuestionOption {
  const _QuestionOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.assetPath,
  });

  final String value;
  final String title;
  final String? subtitle;
  final String? assetPath;
}

enum _QuestionType { imageSingle, singleChoice, multiChoice }
