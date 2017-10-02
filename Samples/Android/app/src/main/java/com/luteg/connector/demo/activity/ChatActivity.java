package com.luteg.connector.demo.activity;

import android.content.Context;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.luteg.connector.Client;
import com.luteg.connector.demo.BundleIdentifier;
import com.luteg.connector.demo.SessionHelper;
import com.luteg.connector.demo.adapter.MessageAdapter;
import com.luteg.connector.demo.Message;
import com.luteg.connector.options.FileTransferRequestOptions;
import com.luteg.connector.demo.R;

import java.util.ArrayList;

public class ChatActivity extends AppCompatActivity {
    private static final String TAG = "ChatActivity";

    Client client;
    String channelName;

    EditText message_text;
    Button send_data;
    RecyclerView recyclerView;
    MessageAdapter adapter;
    LinearLayoutManager layoutManager;
    ArrayList<Message> messages= new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);

        Bundle b =getIntent().getExtras();
        String clientId = b.getString(BundleIdentifier.CLIENT_ID);
        channelName = b.getString(BundleIdentifier.CHANNEL_ID);
        client=SessionHelper.getInstance().lutegConnector.clients.get(clientId);

        message_text =(EditText)findViewById(R.id.message_text);
        send_data=(Button)findViewById(R.id.send_data);
        send_data.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                client.sendMessage(channelName,message_text.getText().toString());
            }
        });

        layoutManager = new LinearLayoutManager(getApplicationContext(), LinearLayoutManager.VERTICAL, false);
        recyclerView = (RecyclerView)findViewById(R.id.listView);
        adapter = new MessageAdapter(messages);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.setAdapter(adapter);

        initializeClient(client);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        client.closeDataChannel(channelName);
    }

    private void initializeClient(final Client client){
        final String clientId = client.clientId;

        Log.d(TAG,"initializing client : " + clientId);

        client.setOnMessageReceivedListener(new Client.OnMessageReceivedListener() {
            @Override
            public void onMessageReceived(String channelName, final String message) {
                showToast(channelName,message);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        messages.add(new Message(false,message));
                        recyclerView.getAdapter().notifyDataSetChanged();

                    }
                });
            }
        });
        client.setOnMessageSentListener(new Client.OnMessageSentListener() {
            @Override
            public void onMessageSent(String err, String channelName, final String message) {
                showToast(channelName,message);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        messages.add(new Message(true,message));
                        recyclerView.getAdapter().notifyDataSetChanged();

                    }
                });
            }
        });
        client.setOnFileTransferRequestReceivedListener(new Client.OnFileTransferRequestReceivedListener() {
            @Override
            public void onFileTransferRequestReceived(FileTransferRequestOptions options, Client.Answer answer) {
                answer.accept();
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
                Toast.makeText(ChatActivity.this, toastMessage,
                        Toast.LENGTH_SHORT).show();
            }
        });
    }
    public static void show(Bundle extras, Context from) {
        Intent myIntent = new Intent(from, ChatActivity.class);
        if (extras != null)
            myIntent.putExtras(extras);
        from.startActivity(myIntent);
    }

}
