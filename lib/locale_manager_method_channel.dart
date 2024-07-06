import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'locale_manager_platform_interface.dart';

/// An implementation of [LocaleManagerPlatform] that uses method channels.
class MethodChannelLocaleManager extends LocaleManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('locale_manager');

  @override
  Future<void> setLocale(String locale) async {
    await methodChannel.invokeMethod('setLocale', {
      "locale": locale,
    });
  }

  @override
  Future<String?> getLocalized(String key) {
    return methodChannel.invokeMethod<String?>(
      'getLocalized',
      {'key': key},
    );
  }

  @override
  Future<String> getLocale() async {
    final result = await methodChannel.invokeMethod<String>('getLocale');
    return result ?? '';
  }
}
