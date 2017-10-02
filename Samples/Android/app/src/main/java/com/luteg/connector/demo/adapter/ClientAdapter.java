package com.luteg.connector.demo.adapter;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.luteg.connector.Client;
import com.luteg.connector.demo.R;

import java.util.HashMap;

/**
 * Created by utkubayik on 27/09/2017.
 */

public class ClientAdapter extends RecyclerView.Adapter<ClientAdapter.ClientViewHolder> {
    HashMap<String,Client> clientList;

    class ClientViewHolder extends RecyclerView.ViewHolder {

        TextView clientId;

        ClientViewHolder(View itemView) {
            super(itemView);
            clientId =(TextView)itemView.findViewById(R.id.client_id);
        }

    }

    public ClientAdapter(HashMap<String,Client> clientList) {

        this.clientList = clientList;
    }

    @Override
    public ClientViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_item_client, parent, false);
        return new ClientViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(ClientViewHolder holder, int position) {

        Client client = (Client) clientList.values().toArray()[position];
        holder.clientId.setText(client.clientId);
    }

    @Override
    public int getItemCount() {
        return clientList.keySet().size();
    }
}
