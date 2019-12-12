package com.amplitude.amplitude_flutter;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.telephony.TelephonyManager;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AmplitudeFlutterPlugin */
public class AmplitudeFlutterPlugin implements MethodCallHandler {
  String carrierName;

  private final Activity mActivity;
  private final TelephonyManager mTelephonyManager;
  private Result mResult;
  private static int READ_PHONE_STATE = 123;

  private AmplitudeFlutterPlugin(Activity activity) {
    this.mActivity = activity;
    mTelephonyManager = (TelephonyManager) activity.getSystemService(Context.TELEPHONY_SERVICE);
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "amplitude_flutter");
    final AmplitudeFlutterPlugin amplitudeFlutterPlugin = new AmplitudeFlutterPlugin(registrar.activity());
    channel.setMethodCallHandler(amplitudeFlutterPlugin);

    /** Adds a callback allowing the plugin to take part in handling incoming calls
     * to Activity#onRequestPermissionsResult(int, String[], int[])
     **/
    registrar.addRequestPermissionsResultListener(new PluginRegistry.RequestPermissionsResultListener() {
      @Override
      public boolean onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        if (requestCode == READ_PHONE_STATE) {
          boolean permissionGranted = grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
          amplitudeFlutterPlugin.processCarrierResult(permissionGranted);
          return true;
        } else {
          // We don't care other permissions other than READ_PHONE_STATE
          return false;
        }
      }
    });
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    mResult = result;
    if (call.method.equals("carrierName")) {
      if (Build.VERSION.SDK_INT >= 23) {
        getCarrierInfoWithPermissions(mResult);
      } else {
        processCarrierResult(true);
      }
    } else {
      result.notImplemented();
    }
    mResult = null;
  }

  private void getCarrierInfoWithPermissions(Result result) {
    boolean permissionGranted;
    permissionGranted = checkAlreadyExistingPermission();
    if (permissionGranted) {
      carrierName = getCarrierName();
      result.success(carrierName);
    } else {
      ActivityCompat.requestPermissions(this.mActivity, new String[] { Manifest.permission.READ_PHONE_STATE },
          READ_PHONE_STATE);
    }
  }

  private boolean checkAlreadyExistingPermission() {
    int result = ContextCompat.checkSelfPermission(this.mActivity, Manifest.permission.READ_PHONE_STATE);
    if (result == PackageManager.PERMISSION_GRANTED) {
      return true;
    } else {
      return false;
    }
  }

  private void processCarrierResult(boolean permission) {
    // We only proceed only when permission is triggered when `device` method is called.
    // That means mResult is not null.
    if (mResult == null) {
      return;
    }

    if (permission) {
      String name = getCarrierName();
      mResult.success(name);
    } else {
      mResult.error("PERMISSION_DENIED", "PERMISSION_DENIED", null);
    }
    mResult = null;
  }

  private String getCarrierName() {
    String networkOperatorName = mTelephonyManager.getNetworkOperatorName();
    if (networkOperatorName == null) {
      networkOperatorName = "null";
    }
    return networkOperatorName;
  }
}
