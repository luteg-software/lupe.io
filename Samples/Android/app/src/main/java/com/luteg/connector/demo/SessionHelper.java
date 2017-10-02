package com.luteg.connector.demo;

import com.luteg.connector.Client;
import com.luteg.connector.Connector;

/**
 * Session singleton instance for single values
 */
public class SessionHelper {
    private static SessionHelper ourInstance = new SessionHelper();

    public static SessionHelper getInstance() {
        return ourInstance;
    }

    private SessionHelper() {    }
    public Connector lutegConnector;
    public Client.Answer answer;
}
