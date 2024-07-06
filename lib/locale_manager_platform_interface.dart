import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'locale_manager_method_channel.dart';

abstract class LocaleManagerPlatform extends PlatformInterface {
  /// Constructs a NativeLocalePlatform.
  LocaleManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocaleManagerPlatform _instance = MethodChannelLocaleManager();

  /// The default instance of [LocaleManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocaleManager].
  static LocaleManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocaleManagerPlatform] when
  /// they register themselves.
  static set instance(LocaleManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> setLocale(String locale);

  Future<String?> getLocalized(String key);

  Future<String> getLocale();
}
