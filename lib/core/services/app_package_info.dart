import 'package:package_info_plus/package_info_plus.dart';

abstract class AppPackageInfo {
  Future<String> loadVersionLabel();
}

class PlatformPackageInfo implements AppPackageInfo {
  @override
  Future<String> loadVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version} (${info.buildNumber})';
  }
}
