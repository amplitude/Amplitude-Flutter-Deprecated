package com.amplitude.amplitude_flutter;

import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.amplitude.api.Amplitude;

/** AmplitudeFlutterPlugin */
public class AmplitudeFlutterPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "amplitude_flutter");

    Amplitude.getInstance().initialize(registrar.context(), "API_KEY");
    Amplitude.getInstance().enableForegroundTracking(registrar.activity().getApplication());

    channel.setMethodCallHandler(new AmplitudeFlutterPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("logEvent")) {
      final String eventName = call.argument("name");
      Amplitude.getInstance().logEvent(eventName);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }
}
