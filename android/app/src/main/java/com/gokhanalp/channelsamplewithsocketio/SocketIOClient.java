package com.gokhanalp.channelsamplewithsocketio;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.lang.reflect.Array;
import java.lang.reflect.Method;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;
import io.socket.client.Ack;
import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;

import static io.socket.client.IO.socket;

public class SocketIOClient {
    static SocketIOClient shared = new SocketIOClient();
    Socket socket;
    MethodChannel flutterchannel;
    Activity activity;

    SocketIOClient() {
        try {
            String url = "http://10.0.2.2:3000";
            URI uri = new URI(url);
            socket = IO.socket(uri);
        } catch (Exception e) {
            Log.v("SocketIOManager", "Socket setleme başarısız");
        }

        socket.on(Socket.EVENT_CONNECT, new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                invokeMethod("connected", null);
            }
        }).on(Socket.EVENT_DISCONNECT, new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                invokeMethod("disconnected", null);
            }
        }).on("message", new Emitter.Listener() {

            @Override
            public void call(Object... args) {
                if (args.length == 2) {
                    String sender = (String) args[0];
                    String mesage = (String) args[1];
                    if(sender != null && mesage != null) {
                        ArrayList<String> params = new ArrayList<String>();
                        params.add(sender);
                        params.add(mesage);
                        invokeMethod("messageReceived", params);

                    }
                }
            }
        });
    }

    private void invokeMethod(@NonNull String method, @Nullable Object arguments) {
        if (flutterchannel != null && activity != null) {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    flutterchannel.invokeMethod(method, arguments);
                }
            });
        }
    }

    static boolean flutterChannelTest(String arg) {
        Log.v("SocketIO", "Android flutterChannelTest arg: " + arg);
        return arg == "test" ? true : false;
    }

    void connect() {
        socket.connect();
    }

    void disconnect() {
        socket.connect();
    }

    void sendMessage(String sender, String message) {
        socket.emit("sendMessage", sender, message, new Ack() {
            @Override
            public void call(Object... args) {
                Log.v("SocketIO", "SocketIO " + sender + " tarafından şu mesaj gönderildi: " + message);
            }
        });
    }
}
