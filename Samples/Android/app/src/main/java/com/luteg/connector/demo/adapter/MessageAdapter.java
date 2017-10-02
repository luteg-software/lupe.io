package com.luteg.connector.demo.adapter;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.luteg.connector.demo.Message;
import com.luteg.connector.demo.R;

import java.util.List;

/**
 * Created by utkubayik on 28/09/2017.
 */

public class MessageAdapter extends RecyclerView.Adapter<MessageAdapter.MessageViewHolder> {

    List<Message> messageList;

    class MessageViewHolder extends RecyclerView.ViewHolder {

        TextView local_message;
        TextView remote_message;

        MessageViewHolder(View itemView) {
            super(itemView);
            local_message =(TextView)itemView.findViewById(R.id.local_message);
            remote_message =(TextView)itemView.findViewById(R.id.remote_message);
        }

    }

    public MessageAdapter(List<Message> clientList) {

        this.messageList = clientList;
    }

    @Override
    public MessageAdapter.MessageViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_item_message, parent, false);
        return new MessageAdapter.MessageViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(MessageAdapter.MessageViewHolder holder, int position) {

        Message message = messageList.get(position);
        if(message.local)
            holder.local_message.setText(message.message);
        else
            holder.remote_message.setText(message.message);
    }

    @Override
    public int getItemCount() {
        return messageList.size();
    }
}