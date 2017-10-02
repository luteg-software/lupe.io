package com.luteg.connector.demo;

/**
 * Created by utkubayik on 28/09/2017.
 */

/**
 * Message model for the adapter
 */
public class Message{
    public boolean local;
    public String message;

    /**
     *
     * @param local if the message is local message
     * @param message the message text
     */
    public Message(boolean local,String message){
        this.local=local;
        this.message =message;
    }
}