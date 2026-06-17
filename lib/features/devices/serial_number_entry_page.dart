import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/serial/serial_recognition_service.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class SerialNumberEntryPage extends StatefulWidget {
  const SerialNumberEntryPage({super.key});

  @override
  State<SerialNumberEntryPage> createState() => _SerialNumberEntryPageState();
}

class _SerialNumberEntryPageState extends State<SerialNumberEntryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final savedSerial = AppScope.of(context).savedSerialNumber;
    if (_controller.text.isEmpty && savedSerial != null) {
      _controller.text = savedSerial;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final localizations = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final normalized = normalizeSerialNumber(_controller.text);
    await AppScope.of(context).saveSerialNumber(normalized);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(localizations.serialNumberSaved)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.productSerialNumber)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: <Widget>[
          Text(
            localizations.manualSerialHint,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\- ]')),
              ],
              decoration: InputDecoration(
                hintText: localizations.serialNumberInputHint,
                helperText: localizations.serialNumberHelper,
              ),
              validator: (value) {
                final normalized = normalizeSerialNumber(value ?? '');
                if (!isLikelySerialNumber(normalized)) {
                  return localizations.serialNumberRequired;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(localizations.saveSerialNumber),
          ),
        ],
      ),
    );
  }
}
