import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/features/devices/devices_tab.dart';
import 'package:flutter_application_1/features/profile/profile_tab.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;
    final pages = <Widget>[const DevicesTab(), const ProfileTab()];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: controller.selectedTabIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF202020))),
        ),
        child: BottomNavigationBar(
          currentIndex: controller.selectedTabIndex,
          onTap: controller.selectTab,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.memory_rounded),
              label: localizations.myDevicesTab,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              label: localizations.userInfoTab,
            ),
          ],
        ),
      ),
    );
  }
}
