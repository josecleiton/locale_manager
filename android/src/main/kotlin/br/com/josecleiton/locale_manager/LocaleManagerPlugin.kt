package br.com.josecleiton.locale_manager

import android.app.Activity
import android.content.res.Configuration

import android.os.Build
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

class LocaleManagerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private var activity : Activity? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "locale_manager")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "setLocale" -> {
          setLocale(call.argument<String>("locale")!!)
          result.success(true)
        }
        "getLocalized" -> {
          val value = getLocalized(call.argument<String>("key")!!)
          result.success(value)
        }
        "getLocale" -> {
          val value = getLocale()
          result.success(value)
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  @Suppress("DEPRECATION")
  private fun getLocale(): String {
    val activity = this.activity ?: return ""
    val configuration = activity.resources.configuration

    val locale = if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N) configuration.locales.get(0) else configuration.locale

    // locale.toString() -> en_US
    return locale.toLanguageTag() // -> en-US
  }

  private fun getLocalized(key: String): String? {
    val activity = this.activity ?: return null
    val packageName = activity.packageName
    val resId = activity.resources.getIdentifier(key, "string", packageName)
    if (resId == 0) {
      return null
    }
    val locale = getLocale() // Assuming getLocale() returns a string like "en" or "fr"
    val config = Configuration(activity.resources.configuration)
    config.setLocale(Locale.forLanguageTag(locale))
    val localizedContext = activity.createConfigurationContext(config)

    return localizedContext.resources.getString(resId)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
     activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  @Suppress("DEPRECATION")
  private fun setLocale(localeStr: String) {
    val activity = this.activity ?: return

    val locale = Locale.forLanguageTag(localeStr)

    val resources = activity.resources
    val configuration = resources.configuration

    configuration.setLocale(locale)

    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N){
      activity.applicationContext.createConfigurationContext(configuration)
    } else {
      resources.updateConfiguration(configuration, resources.displayMetrics)
    }
  }
}
