package com.ondoor.app.ondoor;


import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.json.JSONObject;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import android.util.Log;



public class MainActivity extends FlutterActivity {


    private static final String CHANNEL = "com.ondoor/upi";
    private static final int UPI_PAYMENT_REQUEST_CODE = 1001;
    private MethodChannel.Result pendingResult;


    private static final String DATA_CHANNEL = "com.ondoor/shared_prefs";


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getUpiAppsInstalled")) {
                        String deepLink = call.argument("deepLink");
                        List<String> blacklistList = (List<String>) call.argument("blacklist");
                        String[] blacklist = blacklistList != null ? blacklistList.toArray(new String[0]) : new String[0];

                        try {
                            Intent intent = new Intent();
                            intent.setAction(Intent.ACTION_VIEW);
                            intent.setData(Uri.parse(deepLink));

                            pendingResult = result; // Save the result callback
                            startActivityForResult(Intent.createChooser(intent, "Choose UPI App"), UPI_PAYMENT_REQUEST_CODE);
                        } catch (Exception e) {
                            e.printStackTrace();
                            result.error("ERROR", "Failed to initiate UPI transaction", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), DATA_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getOldPreferences")) {
                        SharedPreferences prefs = getSharedPreferences("ONDOOR_DATA", MODE_PRIVATE);
                        Map<String, ?> allEntries = prefs.getAll();
                        result.success(allEntries); // Send all data to Flutter
                    }
                    else if (call.method.equals("clearOldPreferences")) {
                        SharedPreferences prefs = getSharedPreferences("ONDOOR_DATA", MODE_PRIVATE);
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.clear(); // Clear all data in SharedPreferences
                        boolean success = editor.commit(); // Commit changes
                        if (success) {
                            result.success("SharedPreferences cleared successfully.");
                        } else {
                            result.error("CLEAR_ERROR", "Failed to clear SharedPreferences.", null);
                        }
                    }

                    else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);


        if (requestCode == UPI_PAYMENT_REQUEST_CODE && pendingResult != null)
        {

            //Log.d("UPI_PAYMENT", "Intent Data: " + data.getStringExtra("response"));

            String status = "FAILED"; // Default to failed
            String response = "";

            if (data != null) {
                response = data.getStringExtra("response");
                if (response != null && response.toLowerCase().contains("success")) {
                    status = "SUCCESS";
                }
            }

            // Send the result back to Flutter
            pendingResult.success(status);
            pendingResult = null;
        }
    }
}