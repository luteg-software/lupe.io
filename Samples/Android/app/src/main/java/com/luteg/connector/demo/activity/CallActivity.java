package com.luteg.connector.demo.activity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.luteg.connector.Client;
import com.luteg.connector.Connector;
import com.luteg.connector.demo.BundleIdentifier;
import com.luteg.connector.demo.SessionHelper;
import com.luteg.connector.options.CallOptions;
import com.luteg.connector.options.CallRequestOptions;
import com.luteg.connector.options.LocalMediaOptions;
import com.luteg.connector.demo.R;

import org.webrtc.MediaStream;
import org.webrtc.SurfaceViewRenderer;


public class CallActivity extends AppCompatActivity {
    private static final String TAG = "CallActivity";

    /**
     * the renderers from XML file
     */
    SurfaceViewRenderer localView;
    SurfaceViewRenderer remoteView;

    Client client;

    boolean isVideoStopped;
    boolean isAudioStopped;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_call);

        localView =(SurfaceViewRenderer) findViewById(R.id.local_video);
        remoteView =(SurfaceViewRenderer) findViewById(R.id.remote_video);

        /**
         * initialize local view
         */
        SessionHelper.getInstance().lutegConnector.setMediaView(localView);

        Bundle b =getIntent().getExtras();
        final boolean isAudio= b.getBoolean(BundleIdentifier.AUDIO_CALL);
        final boolean incoming= b.getBoolean(BundleIdentifier.INCOMING);
        String clientId = b.getString(BundleIdentifier.CLIENT_ID);

        client=SessionHelper.getInstance().lutegConnector.clients.get(clientId);
        if(client==null){
            finish();
            return;
        }
        /**
         * initialize remote view
         */
        client.setMediaView(remoteView);
        /**
         * initialize client listeners
         */
        initializeClient(client);

        LocalMediaOptions localMediaOptions = new LocalMediaOptions();
        localMediaOptions.audio = true;
        localMediaOptions.video = !isAudio;
        localMediaOptions.videoSource = Connector.VideoSource.FRONT;
        localMediaOptions.audioSource = Connector.AudioSource.EARPIECE;

        SessionHelper.getInstance().lutegConnector.startLocalMedia(
                localMediaOptions,
                new Connector.OnLocalMediaStartedListener() {
                    @Override
                    public void onLocalMediaStarted(MediaStream stream) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                /**
                                 * start call after initalization
                                 */
                                if(incoming){
                                    SessionHelper.getInstance().answer.accept();
                                }else{
                                    CallRequestOptions options = new CallRequestOptions();
                                    options.confirmationMessage="Arama";
                                    options.audio=true;
                                    options.video=!isAudio;
                                    client.call(options);
                                }

                            }
                        });
                    }
                },
                new Connector.OnLocalMediaErrorListener() {
                    @Override
                    public void onLocalMediaError(String error) {
                        showToast("startLocalMedia", "Err : " + error);
                    }
                }
        );

        findViewById(R.id.muteVideo).setOnClickListener(
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if(isVideoStopped){
                                    SessionHelper.getInstance().lutegConnector.startVideoSource();
                                    isVideoStopped=false;
                                }
                                else {
                                    SessionHelper.getInstance().lutegConnector.stopVideoSource();
                                    isVideoStopped=true;
                                }
                            }
                        });
                    }
                });
        findViewById(R.id.muteAudio).setOnClickListener(
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                            isAudioStopped=!isAudioStopped;
                            SessionHelper.getInstance().lutegConnector.toggleMute(isAudioStopped);
                            }
                        });
                    }
                });
        findViewById(R.id.switchCameraButton).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isVideoStopped){
                            SessionHelper.getInstance().lutegConnector.startVideoSource();
                            isVideoStopped=false;
                        }
                        else {
                            SessionHelper.getInstance().lutegConnector.stopVideoSource();
                            isVideoStopped=true;
                        }
                    }
                });
            }
        });
        findViewById(R.id.hangUpButton).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SessionHelper.getInstance().lutegConnector.stopLocalMedia(new Connector.OnLocalMediaStoppedListener() {
                    @Override
                    public void onLocalMediaStopped() {
                        try {
                            client.hangup();
                        }catch (Exception ex){

                        }
                        finish();

                    }
                });

            }
        });
        findViewById(R.id.switchCameraButton).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SessionHelper.getInstance().lutegConnector.toggleCamera();
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

    }

    private void initializeClient(final Client client){
        final String clientId = client.clientId;

        Log.d(TAG,"initializing client : " + clientId);
        // when calling to client
        client.setOnCallingListener(new Client.OnCallingListener() {
            @Override
            public void onCalling(CallOptions options) {
                boolean audioRequest = options.audio;
                boolean videoRequest = options.video;
                String message = "Calling to " + clientId + "..." + "Audio request : " + audioRequest + "Video request : " + videoRequest;
                showToast("onCalling", message);
            }
        });

        // when call is succeed between client
        client.setOnCallSucceedListener(new Client.OnCallSucceedListener() {
            @Override
            public void onCallSucceed(CallOptions options) {
                boolean audioRequest = options.audio;
                boolean videoRequest = options.video;
                String message = "Call is succeed between " + clientId + "." + "Audio request : " + audioRequest + "Video request : " + videoRequest;
                showToast("onCallSucceed", message);


            }
        });

        // when call is failed between client
        client.setOnCallFailedListener(new Client.OnCallFailedListener() {
            @Override
            public void onCallFailed(String error, CallOptions options) {
                if (!TextUtils.isEmpty(error)){
                    if (error.equals(Connector.ERROR_DISCONNECTED)){
                        showToast("onCallFailed", "You are disconnected from the server. Please connect to server at first");
                    }
                    else if (error.equals(Connector.ERROR_CALL_EXIST)){
                        showToast("onCallFailed", "You have already call with this client");
                    }
                    else if (error.equals(Connector.ERROR_LOCAL_MEDIA_NOT_EXISTS)){
                        showToast("onCallFailed", "You don't have local media. Please start your local media at first.");
                    }
                    else if (error.equals(Connector.ERROR_AUDIO_OR_VIDEO_OPTION_MUST_BE_SET)){
                        showToast("onCallFailed", "Please select audio or video option for this client.");
                    }
                    else{
                        showToast("onCallFailed", error);
                    }
                }
                else{
                    boolean audioRequest = options.audio;
                    boolean videoRequest = options.video;
                    String message = "Call is failed between " + clientId + "." + "Audio request : " + audioRequest + "Video request : " + videoRequest;
                    showToast("onCallFailed", message);
                }


            }
        });

        // when call request is received from client
        client.setOnCallRequestReceivedListener(new Client.OnCallRequestReceivedListener() {
            @Override
            public void onCallRequestReceived(CallRequestOptions options, final Client.Answer answer) {

                boolean audioRequest = options.audio;
                boolean videoRequest = options.video;
                final String confirmationMessage = options.confirmationMessage;
                Log.d(TAG, "call recieved :"+confirmationMessage);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            new AlertDialog.Builder(CallActivity.this)
                                    .setTitle(client.clientId)
                                    .setMessage(confirmationMessage)
                                    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                        public void onClick(DialogInterface dialog, int which) {
                                            // continue with delete
                                            SessionHelper.getInstance().answer = answer;
                                            Bundle b = new Bundle();
                                            b.putBoolean(BundleIdentifier.INCOMING, true);
                                            b.putString(BundleIdentifier.CLIENT_ID, client.clientId);
                                            b.putBoolean(BundleIdentifier.AUDIO_CALL, false);
                                            CallActivity.show(b, CallActivity.this);
                                        }
                                    })
                                    .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                                        public void onClick(DialogInterface dialog, int which) {
                                            answer.decline();
                                        }
                                    })
                                    .setIcon(android.R.drawable.ic_dialog_alert)
                                    .show();
                        }catch (Exception ex){}
                    }
                });


            }
        });

        // when call request is accepted by client
        client.setOnCallRequestAcceptedListener(new Client.OnCallRequestAcceptedListener() {
            @Override
            public void onCallRequestAccepted(CallOptions options) {
                boolean audioRequest = options.audio;
                boolean videoRequest = options.video;
                String message = "Call request is accepted by " + clientId + "." + "Audio request : " + audioRequest + "Video request : " + videoRequest;
                showToast("onCallRequestAccepted", message);
            }
        });

        // when call request is declined by client
        client.setOnCallRequestDeclinedListener(new Client.OnCallRequestDeclinedListener() {
            @Override
            public void onCallRequestDeclined(CallOptions options) {
                boolean audioRequest = options.audio;
                boolean videoRequest = options.video;
                String  message = "Call request is declined by " + clientId + "." + "Audio request : " + audioRequest + "Video request : " + videoRequest;
                showToast("onCallRequestDeclined", message);
            }
        });

        // when call is hungup by client
        client.setOnCallHungupListener(new Client.OnCallHungupListener() {
            @Override
            public void onCallHungup() {
                String message = "Call is hungup between " + clientId + ".";
                showToast("onCallHungup", message);
                SessionHelper.getInstance().lutegConnector.resetRoom();
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        SessionHelper.getInstance().lutegConnector.stopLocalMedia(new Connector.OnLocalMediaStoppedListener() {
                            @Override
                            public void onLocalMediaStopped() {
                                finish();

                            }
                        });
                    }
                });
            }
        });

        // when stream is added for client
        client.setOnStreamAddedListener(new Client.OnStreamAddedListener() {
            @Override
            public void onStreamAdded(MediaStream stream) {
            }
        });

        client.setOnStreamRemovedListener(new Client.OnStreamRemovedListener() {
            @Override
            public void onStreamRemoved() {
            }
        });

    }
    private void showToast(final String event, final String message){
        runOnUiThread(new Runnable() {
            public void run() {
                String toastMessage = "";
                if (!TextUtils.isEmpty(event)){
                    toastMessage = event + "\n";
                }
                toastMessage = toastMessage+ message;
                Toast.makeText(CallActivity.this, toastMessage,
                        Toast.LENGTH_SHORT).show();
            }
        });
    }
    public static void show(Bundle extras, Context from) {
        Intent myIntent = new Intent(from, CallActivity.class);
        if (extras != null)
            myIntent.putExtras(extras);
        from.startActivity(myIntent);
    }

}
