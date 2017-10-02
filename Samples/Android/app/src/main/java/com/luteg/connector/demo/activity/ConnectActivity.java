package com.luteg.connector.demo.activity;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.support.v7.app.AppCompatActivity;

import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.luteg.connector.Client;
import com.luteg.connector.Connector;
import com.luteg.connector.demo.BundleIdentifier;
import com.luteg.connector.demo.RecyclerItemClickListener;
import com.luteg.connector.demo.SessionHelper;
import com.luteg.connector.demo.adapter.ClientAdapter;
import com.luteg.connector.options.CallOptions;
import com.luteg.connector.options.CallRequestOptions;
import com.luteg.connector.options.ConnectorOptions;
import com.luteg.connector.options.DataChannelRequestOptions;
import com.luteg.connector.demo.R;

import java.util.HashMap;
import java.util.List;

import pub.devrel.easypermissions.EasyPermissions;

/**
 * Initial activity for connection
 */
public class ConnectActivity extends AppCompatActivity implements EasyPermissions.PermissionCallbacks {
    private static final String TAG = "ConnectActivity";


    private String APP_KEY = "<YOUR APP KEY>";
    private String APP_SECRET = "<YOUR APP SECRET>";

    /**
     * local connector instance
     */
    private Connector mLutegConnector;
    LinearLayoutManager layoutManager;
    ClientAdapter adapter;

    RecyclerView recyclerView;
    Button connect_button;
    Button join_button;

    boolean isJoined;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_connect);
        EasyPermissions.requestPermissions(this, "Konuşma izinlerine ihtiyaç var", 100, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO);
        recyclerView = (RecyclerView)findViewById(R.id.listView);
        connect_button = (Button) findViewById(R.id.connect_button);
        join_button = (Button)findViewById(R.id.join_button);
        initButtons();
        layoutManager = new LinearLayoutManager(getApplicationContext(), LinearLayoutManager.VERTICAL, false);

        /**
         * initialize connectior on create method
         */
        initializeLutegConnector();
        adapter = new ClientAdapter(mLutegConnector.clients);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.setAdapter(adapter);
        recyclerView.addOnItemTouchListener(
                new RecyclerItemClickListener(getApplicationContext(), recyclerView, new RecyclerItemClickListener.OnItemClickListener() {
                    @Override
                    public void onItemClick(View view, int position) {
                        final Client client = (Client) mLutegConnector.clients.values().toArray()[position];

                        android.support.v7.app.AlertDialog.Builder builder = new android.support.v7.app.AlertDialog.Builder(ConnectActivity.this);
                        builder.setTitle("Please select connection type");

                        /**
                         * examples for these actions are available
                         */
                        String[] minutes = {"Audio Call", "Video Call", "Data Channel (Chat)", "Media Streams", "Cancel"};
                        builder.setItems(minutes, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                if(which==4){
                                    dialog.dismiss();
                                    return;
                                }
                                if(which==2){
                                    /**
                                     * create data channel
                                     */
                                    client.openDataChannel("chat");
                                    client.setOnDataChannelOpenedListener(new Client.OnDataChannelOpenedListener() {
                                        @Override
                                        public void onDataChannelOpened(String err, String channelName) {
                                            Bundle b = new Bundle();
                                            b.putString(BundleIdentifier.CLIENT_ID,client.clientId);
                                            b.putString(BundleIdentifier.CHANNEL_ID,"chat");
                                            ChatActivity.show(b,ConnectActivity.this);
                                        }
                                    });

                                    return;
                                }
                                Bundle b = new Bundle();
                                b.putBoolean(BundleIdentifier.INCOMING,false);
                                b.putString(BundleIdentifier.CLIENT_ID,client.clientId);
                                b.putBoolean(BundleIdentifier.AUDIO_CALL,which==0);
                                CallActivity.show(b,ConnectActivity.this);
                            }
                        });


                        android.support.v7.app.AlertDialog dialog = builder.create();
                        dialog.show();
                    }

                    @Override
                    public void onLongItemClick(View view, int position) {
                    }
                }));
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(isJoined){
            mLutegConnector.resetRoom();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }

    @Override
    public void onPermissionsGranted(int requestCode, List<String> perms) {}

    @Override
    public void onPermissionsDenied(int requestCode, List<String> perms) {}

    private void initButtons(){
        connect_button.setOnClickListener(
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if(mLutegConnector==null)
                                    initializeLutegConnector();
                                if(!mLutegConnector.isConnected()){
                                    mLutegConnector.connect(null);
                                }else{
                                    mLutegConnector.disconnect();
                                }

                            }
                        });
                    }
                });
        join_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(isJoined)
                    mLutegConnector.leave();
                else
                    mLutegConnector.join(((EditText)findViewById(R.id.name_text)).getText().toString());
            }
        });
    }

    /**
     * initialize connector on create
     */
    private void initializeLutegConnector() {

        // set options
        ConnectorOptions options = new ConnectorOptions();
        options.appKey =APP_KEY;
        options.appSecret =APP_SECRET;
        // create instance
        mLutegConnector = new Connector(getApplicationContext(), options);
        mLutegConnector.clients= new HashMap<>();

        /**
         * set source types
         */
        mLutegConnector.setAudioSource(Connector.AudioSource.EARPIECE);
        mLutegConnector.setVideoSource(Connector.VideoSource.FRONT);


        // when connected to the server
        mLutegConnector.setOnConnectedListener(new Connector.OnConnectedListener() {
            @Override
            public void onConnected(String err, final String sessionId) {
                String message = "";
                if (!TextUtils.isEmpty(err)){
                    message = "Error : " + err;
                }
                else{
                    message = "Connection id : " + sessionId;
                }
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        connect_button.setText("Disconnect");
                        join_button.setVisibility(View.VISIBLE);
                    }
                });
                showToast("onConnected", message);

            }
        });

        // when disconnected from the server
        mLutegConnector.setOnDisconnectedListener(new Connector.OnDisconnectedListener() {
            @Override
            public void onDisconnected(String err, final String sessionId) {
                String message = "";
                if (!TextUtils.isEmpty(err)){
                    message = "Error : " + err;
                }
                else{
                    message = "Connection id : " + sessionId;
                }
                Log.d(TAG,message);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        connect_button.setText("Connect");
                        join_button.setVisibility(View.INVISIBLE);
                    }
                });
                showToast("onDisconnected", message);
            }
        });

        // when joined to the room
        mLutegConnector.setOnJoinedListener(new Connector.OnJoinedListener() {
            @Override
            public void onJoined(String err, final String roomName, final HashMap<String, Client> clients) {
                String message = "";
                if (!TextUtils.isEmpty(err)){
                    message = "Error : " + err;
                }
                else{
                    message = "You joined to the \"" + roomName + "\" room.";
                    // initialize clients
                    for (String clientId : clients.keySet()) {
                        initializeClient(clients.get(clientId));
                        Log.d(TAG,"client added " + clientId);
                    }
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            // update room fragment
                            join_button.setText("Leave Room");
                            recyclerView.getAdapter().notifyDataSetChanged();
                            View view = ConnectActivity.this.getCurrentFocus();
                            if (view != null) {
                                InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
                                imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
                            }
                        }
                    });
                }
                Log.d(TAG,message);
                isJoined=true;
                showToast("onJoined", message);
            }
        });

        // when left from the room
        mLutegConnector.setOnLeftListener(new Connector.OnLeftListener() {
            @Override
            public void onLeft(String err, String roomName) {
                String message = "";
                if (!TextUtils.isEmpty(err)){
                    message = "Error : " + err;
                }
                else{
                    message = "You left from the \"" + roomName + "\" room.";
                    // update room fragment
                }
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        join_button.setText("Join");
                        recyclerView.getAdapter().notifyDataSetChanged();
                    }
                });
                isJoined=false;
                showToast("onLeft", message);
            }
        });

        // when new client joined to room
        mLutegConnector.setOnClientJoinedListener(new Connector.OnClientJoinedListener() {
            @Override
            public void onClientJoined(String roomName, final Client client) {
                // initialize client
                initializeClient(client);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        recyclerView.getAdapter().notifyDataSetChanged();
                    }
                });
                // update room fragment
            }
        });

        // when any client left from the room
        mLutegConnector.setOnClientLeftListener(new Connector.OnClientLeftListener() {
            @Override
            public void onClientLeft(String roomName, final Client client) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        recyclerView.getAdapter().notifyDataSetChanged();

                    }
                });
                // update room fragment
            }
        });

        SessionHelper.getInstance().lutegConnector=mLutegConnector;
    }

    /**
     * Sets some listeners for the clients. This client is the user, or other users in the room
     * @param client
     */
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

                final String confirmationMessage = options.confirmationMessage;
                Log.d(TAG, "call recieved :"+confirmationMessage);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        new AlertDialog.Builder(ConnectActivity.this)
                                .setTitle(client.clientId)
                                .setMessage(confirmationMessage)
                                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {
                                        // answer is done after initializing the local sources, so it is saved for other activites for answer.
                                        SessionHelper.getInstance().answer=answer;
                                        Bundle b = new Bundle();
                                        b.putBoolean(BundleIdentifier.INCOMING,true);
                                        b.putString(BundleIdentifier.CLIENT_ID,client.clientId);
                                        b.putBoolean(BundleIdentifier.AUDIO_CALL,false);
                                        CallActivity.show(b,ConnectActivity.this);
                                    }
                                })
                                .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {
                                        answer.decline();
                                    }
                                })
                                .setIcon(android.R.drawable.ic_dialog_alert)
                                .show();
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
                mLutegConnector.resetRoom();
            }
        });
        client.setOnDataChannelRequestReceivedListener(new Client.OnDataChannelRequestReceivedListener() {
            @Override
            public void onDataChannelRequestReceived(final DataChannelRequestOptions options, final Client.Answer answer) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {

                        new AlertDialog.Builder(ConnectActivity.this)
                                .setTitle(client.clientId)
                                .setMessage(client.clientId)
                                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {
                                        answer.accept();
                                        Bundle b = new Bundle();
                                        b.putString(BundleIdentifier.CLIENT_ID,client.clientId);
                                        b.putString(BundleIdentifier.CHANNEL_ID,options.name);
                                        ChatActivity.show(b,ConnectActivity.this);
                                    }
                                })
                                .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {
                                        answer.decline();
                                    }
                                })
                                .setIcon(android.R.drawable.ic_dialog_alert)
                                .show();
                    }
                });
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
                Toast.makeText(ConnectActivity.this, toastMessage,
                        Toast.LENGTH_SHORT).show();
            }
        });
    }
}
