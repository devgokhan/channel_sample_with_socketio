package com.gokhanalp.channelsamplewithsocketio;

import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  SocketIOClient socketIOClient = SocketIOClient.shared;
  MethodChannel flutterchannel = null;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    flutterchannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "SocketIOClient");
    socketIOClient.flutterchannel = flutterchannel;
    socketIOClient.activity = this;

    flutterchannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("flutterChannelTest")) {
          HashMap<String,String> map = (HashMap<String,String>) call.arguments;
          if (map != null) {
            String arg = map.get("arg");
            boolean resultChannel = SocketIOClient.flutterChannelTest(arg);
            result.success(resultChannel);
          }
        } else if (call.method.equals("connect")) {
          socketIOClient.connect();
        } else if (call.method.equals("disconnect")) {
          socketIOClient.disconnect();
        } else if (call.method.equals("sendMessage")) {
          HashMap<String, String> map = (HashMap<String,String>) call.arguments;
          if (map != null) {
            String sender = map.get("sender");
            String message = map.get("message");
            if(sender != null && message != null) {
              socketIOClient.sendMessage(sender, message);
            }
          }
        }
      }
    });
  }
}


