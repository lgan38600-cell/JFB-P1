import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_application_1/core/app/app_controller.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/ble/flutter_ble_repository.dart';
import 'package:flutter_application_1/core/ble/web_ble_repository.dart';
import 'package:flutter_application_1/core/serial/serial_recognition_service_factory.dart';
import 'package:flutter_application_1/core/services/app_package_info.dart';
import 'package:flutter_application_1/core/services/app_preferences.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/shell/app_shell.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap>
    with WidgetsBindingObserver {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final preferences = SharedPreferencesAsync();
    _controller = AppController(
      preferences: SharedAppPreferences(preferences),
      packageInfoService: PlatformPackageInfo(),
      bleRepository: kIsWeb
          ? WebBleRepository()
          : FlutterBleRepository(preferences: preferences),
      serialRecognitionService: createSerialRecognitionService(),
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.handleAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DysonCurlApp(controller: _controller);
  }
}

class DysonCurlApp extends StatelessWidget {
  const DysonCurlApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AppScope(
          controller: controller,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Airstyle',
            theme: AppTheme.theme,
            locale: controller.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: const AppShell(),
          ),
        );
      },
    );
  }
}
