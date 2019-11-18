package com.amplitude.amplitude_flutter;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.telephony.TelephonyManager;
import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;

/** AmplitudeFlutterPlugin */
public class AmplitudeFlutterPlugin implements MethodCallHandler {
  private final Activity mActivity;
  private final TelephonyManager mTelephonyManager;

  private AmplitudeFlutterPlugin(Activity activity) {
    mActivity = activity;
    mTelephonyManager = (TelephonyManager) activity.getSystemService(Context.TELEPHONY_SERVICE);
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "amplitude_flutter");
    channel.setMethodCallHandler(new AmplitudeFlutterPlugin(registrar.activity()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("carrierName")) {
      String networkOperatorName = mTelephonyManager.getNetworkOperatorName();
      if (networkOperatorName == null) {
        networkOperatorName = "null";
    }
      result.success(networkOperatorName);
    } else {
      result.notImplemented();
    }
  }
}
