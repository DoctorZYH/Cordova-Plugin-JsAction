package org.apache.cordova.jsaction;

import android.annotation.SuppressLint;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class JsAction extends CordovaPlugin {

    private static final String TAG = "JsAction";


    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.e(TAG, "execute: '-------> " + action );
        if (action.equals("open")) {
            backEvent(1, new JSONObject());
            return true;
        }
        return false;
    }

    private void backEvent(int eventID, JSONObject jsonObject) {
        @SuppressLint("DefaultLocale") final String jsStr =
                String.format("window.JsAction.onEvent(%d, %s)", eventID, jsonObject.toString());
        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                webView.loadUrl("javascript:" + jsStr);
            }
        });
    }
}
