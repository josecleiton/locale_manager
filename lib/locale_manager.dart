library locale_manager;

import 'locale_manager_platform_interface.dart';

class LocaleManager {
  /// Sets the locale to the specified [locale].
  ///
  /// Returns a [Future] that completes when the locale is set.
  Future<void> setLocale(String locale) {
    return LocaleManagerPlatform.instance.setLocale(locale);
  }

  /// Retrieves the localized value for the specified [key].
  ///
  /// Returns a [Future] that completes with the localized value, or `null` if the value is not found.
  Future<String?> getLocalized(String key) {
    return LocaleManagerPlatform.instance.getLocalized(key);
  }

  /// Retrieves the current locale in IETF language tag standard.
  ///
  /// Returns a [Future] that completes with the current locale.
  Future<String> getLocale() => LocaleManagerPlatform.instance.getLocale();
}
