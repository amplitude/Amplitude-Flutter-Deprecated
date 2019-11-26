package com.amplitude.amplitude_flutter;

import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.core.app.ActivityCompat;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.telephony.TelephonyManager;
import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;

/** AmplitudeFlutterPlugin */
public class AmplitudeFlutterPlugin implements MethodCallHandler {
  private final Activity mActivity;
  String carrierName;
  private final TelephonyManager mTelephonyManager;
  private Result mResult;
  boolean permissionGranted;
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
        boolean permissionGranted;
        if ((requestCode == READ_PHONE_STATE) && (grantResults.length > 0)
            && (grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
          permissionGranted = true;
        } else {
          permissionGranted = false;

        }
        amplitudeFlutterPlugin.processCarrierResult(permissionGranted);
        return permissionGranted;
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
