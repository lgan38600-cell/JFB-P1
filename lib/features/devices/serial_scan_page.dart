import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/serial/serial_recognition_service.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class SerialScanPage extends StatefulWidget {
  const SerialScanPage({super.key});

  @override
  State<SerialScanPage> createState() => _SerialScanPageState();
}

class _SerialScanPageState extends State<SerialScanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serialController;

  bool _isProcessing = false;
  String? _recognizedText;
  String? _statusMessage;
  bool _isUnsupported = false;

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final savedSerial = AppScope.of(context).savedSerialNumber;
    if (_serialController.text.isEmpty && savedSerial != null) {
      _serialController.text = savedSerial;
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _captureSerialNumber() async {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _isProcessing = true;
      _statusMessage = null;
      _isUnsupported = false;
    });

    final result = await controller.captureSerialNumber();
    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = false;
      _recognizedText = result.rawText;
      switch (result.status) {
        case SerialRecognitionStatus.success:
          _serialController.text = result.serialNumber ?? '';
          _statusMessage = localizations.editSerialBeforeSave;
          break;
        case SerialRecognitionStatus.noMatch:
          _statusMessage = localizations.serialNotDetected;
          break;
        case SerialRecognitionStatus.unsupported:
          _isUnsupported = true;
          _statusMessage = localizations.scanUnsupportedBody;
          break;
        case SerialRecognitionStatus.error:
          _statusMessage =
              result.errorMessage ?? localizations.serialRecognitionError;
          break;
        case SerialRecognitionStatus.cancelled:
          _statusMessage = null;
          break;
      }
    });
  }

  Future<void> _saveSerialNumber() async {
    final localizations = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final normalized = normalizeSerialNumber(_serialController.text);
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
      appBar: AppBar(title: Text(localizations.scanToAddDevice)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: <Widget>[
          Text(
            localizations.scanSerialHint,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isProcessing ? null : _captureSerialNumber,
            child: Text(
              _isProcessing
                  ? localizations.scanning
                  : _serialController.text.isEmpty
                  ? localizations.openCamera
                  : localizations.retakePhoto,
            ),
          ),
          if (_statusMessage != null) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              _statusMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _isUnsupported
                    ? AppTheme.mutedForeground
                    : AppTheme.foreground,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _serialController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\- ]')),
              ],
              decoration: InputDecoration(
                labelText: localizations.recognizedSerialNumber,
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
          if ((_recognizedText ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            Text(
              localizations.recognizedText,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _recognizedText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.mutedForeground),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saveSerialNumber,
            child: Text(localizations.saveSerialNumber),
          ),
        ],
      ),
    );
  }
}
