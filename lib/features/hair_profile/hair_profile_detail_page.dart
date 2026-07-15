import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/hair_profile/hair_profile_response.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class HairProfileDetailPage extends StatelessWidget {
  const HairProfileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;
    final profile = controller.hairProfileResponse;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.hairProfileTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: profile == null
            ? _EmptyHairProfile(localizations: localizations)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: <Widget>[
                  _ProfileRow(
                    label: _hairTypeLabel(localizations),
                    value: _hairTypeValue(localizations, profile.hairType),
                    onTap: () => _editSingle(
                      context,
                      title: _hairTypeLabel(localizations),
                      selectedValue: profile.hairType,
                      options: _hairTypeOptions(localizations),
                      update: (value) => profile.copyWith(hairType: value),
                    ),
                  ),
                  _ProfileRow(
                    label: _hairLengthLabel(localizations),
                    value: _hairLengthValue(localizations, profile.hairLength),
                    onTap: () => _editSingle(
                      context,
                      title: _hairLengthLabel(localizations),
                      selectedValue: profile.hairLength,
                      options: _hairLengthOptions(localizations),
                      update: (value) => profile.copyWith(hairLength: value),
                    ),
                  ),
                  _ProfileRow(
                    label: _hairThicknessLabel(localizations),
                    value: _hairThicknessValue(
                      localizations,
                      profile.hairThickness,
                    ),
                    onTap: () => _editSingle(
                      context,
                      title: _hairThicknessLabel(localizations),
                      selectedValue: profile.hairThickness,
                      options: _hairThicknessOptions(localizations),
                      update: (value) => profile.copyWith(hairThickness: value),
                    ),
                  ),
                  _ProfileRow(
                    label: _styleRetentionLabel(localizations),
                    value: _styleRetentionValue(
                      localizations,
                      profile.styleRetention,
                    ),
                    onTap: () => _editSingle(
                      context,
                      title: _styleRetentionLabel(localizations),
                      selectedValue: profile.styleRetention,
                      options: _styleRetentionOptions(localizations),
                      update: (value) =>
                          profile.copyWith(styleRetention: value),
                    ),
                  ),
                  _ProfileRow(
                    label: _stylingExperienceLabel(localizations),
                    value: _stylingExperienceValue(
                      localizations,
                      profile.stylingExperience,
                    ),
                    onTap: () => _editSingle(
                      context,
                      title: _stylingExperienceLabel(localizations),
                      selectedValue: profile.stylingExperience,
                      options: _stylingExperienceOptions(localizations),
                      update: (value) =>
                          profile.copyWith(stylingExperience: value),
                    ),
                  ),
                  _ProfileRow(
                    label: _stylingGoalsLabel(localizations),
                    value: _stylingGoalsValue(
                      localizations,
                      profile.stylingGoals,
                    ),
                    onTap: () => _editGoals(context, profile),
                  ),
                ],
              ),
      ),
    );
  }

  static Future<void> _editSingle(
    BuildContext context, {
    required String title,
    required String selectedValue,
    required List<_HairProfileOption> options,
    required HairProfileResponse Function(String value) update,
  }) async {
    final controller = AppScope.of(context);
    final nextValue = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _OptionSheet(
        title: title,
        selectedValue: selectedValue,
        options: options,
      ),
    );
    if (nextValue == null) {
      return;
    }
    await controller.saveHairProfileResponse(update(nextValue));
  }

  static Future<void> _editGoals(
    BuildContext context,
    HairProfileResponse profile,
  ) async {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;
    final nextGoals = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _GoalsSheet(
        title: _stylingGoalsLabel(localizations),
        selectedValues: profile.stylingGoals,
        options: _stylingGoalOptions(localizations),
      ),
    );
    if (nextGoals == null || nextGoals.isEmpty) {
      return;
    }
    await controller.saveHairProfileResponse(
      profile.copyWith(stylingGoals: nextGoals),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 78),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.elevatedSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.outline),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.mutedForeground.withValues(alpha: 0.62),
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.mutedForeground.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionSheet extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.selectedValue,
    required this.options,
  });

  final String title;
  final String selectedValue;
  final List<_HairProfileOption> options;

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      title: title,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (_, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.value == selectedValue;
          return _SheetOptionTile(
            title: option.label,
            isSelected: isSelected,
            onTap: () => Navigator.of(context).pop(option.value),
          );
        },
      ),
    );
  }
}

class _GoalsSheet extends StatefulWidget {
  const _GoalsSheet({
    required this.title,
    required this.selectedValues,
    required this.options,
  });

  final String title;
  final List<String> selectedValues;
  final List<_HairProfileOption> options;

  @override
  State<_GoalsSheet> createState() => _GoalsSheetState();
}

class _GoalsSheetState extends State<_GoalsSheet> {
  late final Set<String> _selectedValues = widget.selectedValues.toSet();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return _SheetContainer(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.options.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final isSelected = _selectedValues.contains(option.value);
                return _SheetOptionTile(
                  title: option.label,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedValues.remove(option.value);
                      } else {
                        _selectedValues.add(option.value);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _selectedValues.isEmpty
                ? null
                : () => Navigator.of(
                    context,
                  ).pop(_selectedValues.toList(growable: false)),
            child: Text(localizations.saveButton),
          ),
        ],
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class _SheetOptionTile extends StatelessWidget {
  const _SheetOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.elevatedSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : AppTheme.outline,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (isSelected) const Icon(Icons.check_rounded),
          ],
        ),
      ),
    );
  }
}

class _EmptyHairProfile extends StatelessWidget {
  const _EmptyHairProfile({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final isEnglish = localizations.localeName == 'en';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          isEnglish
              ? 'Complete the first connection questionnaire to save your hair profile.'
              : '完成首次连接问卷后，会在这里保存您的头发资料。',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.mutedForeground.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class _HairProfileOption {
  const _HairProfileOption(this.value, this.label);

  final String value;
  final String label;
}

String hairProfileSummary(
  AppLocalizations localizations,
  HairProfileResponse? profile,
) {
  if (profile == null) {
    return localizations.localeName == 'en' ? 'Not completed' : '尚未填写';
  }
  return _profileSummary(localizations, profile);
}

String _profileSummary(
  AppLocalizations localizations,
  HairProfileResponse profile,
) {
  return '${_hairTypeValue(localizations, profile.hairType)} · '
      '${_hairLengthValue(localizations, profile.hairLength)} · '
      '${_hairThicknessValue(localizations, profile.hairThickness)}';
}

String _hairTypeLabel(AppLocalizations localizations) {
  return localizations.localeName == 'en' ? 'Hair type' : '发型';
}

String _hairLengthLabel(AppLocalizations localizations) {
  return localizations.localeName == 'en' ? 'Hair length' : '头发长度';
}

String _hairThicknessLabel(AppLocalizations localizations) {
  return localizations.localeName == 'en' ? 'Hair density' : '头发密度';
}

String _styleRetentionLabel(AppLocalizations localizations) {
  return localizations.localeName == 'en' ? 'Style retention' : '发型持久度';
}

String _stylingExperienceLabel(AppLocalizations localizations) {
  return localizations.localeName == 'en' ? 'Styling experience' : '造型经验';
}

String _stylingGoalsLabel(AppLocalizations localizations) {
  return localizations.localeName == 'en' ? 'Styling goals' : '头发造型目标';
}

String _hairTypeValue(AppLocalizations localizations, String value) {
  return _labelFromOptions(_hairTypeOptions(localizations), value);
}

String _hairLengthValue(AppLocalizations localizations, String value) {
  return _labelFromOptions(_hairLengthOptions(localizations), value);
}

String _hairThicknessValue(AppLocalizations localizations, String value) {
  return _labelFromOptions(_hairThicknessOptions(localizations), value);
}

String _styleRetentionValue(AppLocalizations localizations, String value) {
  return _labelFromOptions(_styleRetentionOptions(localizations), value);
}

String _stylingExperienceValue(AppLocalizations localizations, String value) {
  return _labelFromOptions(_stylingExperienceOptions(localizations), value);
}

String _stylingGoalsValue(AppLocalizations localizations, List<String> values) {
  final labels = values
      .map(
        (value) => _labelFromOptions(_stylingGoalOptions(localizations), value),
      )
      .toList(growable: false);
  return labels.join(localizations.localeName == 'en' ? ', ' : '、');
}

String _labelFromOptions(List<_HairProfileOption> options, String value) {
  return options
      .firstWhere(
        (option) => option.value == value,
        orElse: () => _HairProfileOption(value, value),
      )
      .label;
}

List<_HairProfileOption> _hairTypeOptions(AppLocalizations localizations) {
  return <_HairProfileOption>[
    _HairProfileOption('straight', localizations.hairTypeStraight),
    _HairProfileOption('wavy', localizations.hairTypeWavy),
    _HairProfileOption('curly', localizations.hairTypeCurly),
    _HairProfileOption('coily', localizations.hairTypeCoily),
  ];
}

List<_HairProfileOption> _hairLengthOptions(AppLocalizations localizations) {
  return <_HairProfileOption>[
    _HairProfileOption('very_short', localizations.hairLengthVeryShort),
    _HairProfileOption('short', localizations.hairLengthShort),
    _HairProfileOption('medium', localizations.hairLengthMedium),
    _HairProfileOption('long', localizations.hairLengthLong),
    _HairProfileOption('very_long', localizations.hairLengthVeryLong),
  ];
}

List<_HairProfileOption> _hairThicknessOptions(AppLocalizations localizations) {
  return <_HairProfileOption>[
    _HairProfileOption('fine', localizations.hairThicknessFine),
    _HairProfileOption('medium', localizations.hairThicknessMedium),
    _HairProfileOption('coarse', localizations.hairThicknessCoarse),
    _HairProfileOption('unsure', localizations.unsureOption),
  ];
}

List<_HairProfileOption> _styleRetentionOptions(
  AppLocalizations localizations,
) {
  return <_HairProfileOption>[
    _HairProfileOption('not_long', localizations.styleRetentionShort),
    _HairProfileOption('a_while', localizations.styleRetentionMedium),
    _HairProfileOption('long_time', localizations.styleRetentionLong),
    _HairProfileOption('unsure', localizations.unsureOption),
  ];
}

List<_HairProfileOption> _stylingExperienceOptions(
  AppLocalizations localizations,
) {
  return <_HairProfileOption>[
    _HairProfileOption('beginner', localizations.stylingExperienceBeginner),
    _HairProfileOption(
      'intermediate',
      localizations.stylingExperienceIntermediate,
    ),
    _HairProfileOption('advanced', localizations.stylingExperienceAdvanced),
  ];
}

List<_HairProfileOption> _stylingGoalOptions(AppLocalizations localizations) {
  return <_HairProfileOption>[
    _HairProfileOption('volume_curls', localizations.stylingGoalVolumeCurls),
    _HairProfileOption('straight', localizations.stylingGoalStraight),
    _HairProfileOption('sleek', localizations.stylingGoalSleek),
    _HairProfileOption('frizz_control', localizations.stylingGoalFrizzControl),
    _HairProfileOption(
      'flyaway_management',
      localizations.stylingGoalFlyawayManagement,
    ),
    _HairProfileOption(
      'natural_finish',
      localizations.stylingGoalNaturalFinish,
    ),
    _HairProfileOption('quick_style', localizations.stylingGoalQuickStyle),
    _HairProfileOption('long_lasting', localizations.stylingGoalLongLasting),
    _HairProfileOption('hair_health', localizations.stylingGoalHairHealth),
  ];
}
