//
//  LTGConnector.h
//  Connect
//
//  Created by Fatih YASAR on 29/11/2016.
//  Copyright © 2016 Luteg Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Connect/LTGClient.h>
#import <Connect/LTGFileInfo.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LTGConnectionStatus) {
    LTGConnectionStatusReady            = 0,
    LTGConnectionStatusConnecting       = 1,
    LTGConnectionStatusConnected        = 2,
    LTGConnectionStatusDisconnecting    = 3,
    LTGConnectionStatusDisconnected     = 4
};

typedef NS_ENUM(NSInteger, LTGMediaAudioOutput) {
    LTGMediaAudioOutputSpeaker = 0,
    LTGMediaAudioOutputHandset = 1
};


/**
 *  Connector Options
 */
FOUNDATION_EXPORT NSString* const kLTGConnectorAppKey;
FOUNDATION_EXPORT NSString* const kLTGConnectorAppSecret;
FOUNDATION_EXPORT NSString* const kLTGConnectorServerUrl;
FOUNDATION_EXPORT NSString* const kLTGConnectorDebug;


@protocol LTGConnectorDelegate;
@protocol LTGConnectorMediaSource;

@interface LTGConnector : NSObject

@property (nonatomic, strong) NSString                      *appKey;
@property (nonatomic, strong) NSString                      *appSecret;
@property (nonatomic, assign) BOOL                          debug;
@property (nonatomic, assign) BOOL                          useLevelControl;
@property (nonatomic, assign) BOOL                          isLoopback;
@property (nonatomic, strong, readonly) NSString            *serverUrl;

@property (nonatomic, assign, readonly) BOOL                connected;
@property (nonatomic, assign) LTGConnectionStatus           connectionStatus;
@property (nonatomic, weak)   id<LTGConnectorDelegate>      delegate;
@property (nonatomic, weak)   id<LTGConnectorMediaSource>   mediaSource;
@property (nonatomic, assign) NSInteger                     numberConnectionAttemps; //default 10

@property (nonatomic, assign) BOOL                          audio;
@property (nonatomic, assign) BOOL                          video;


@property (nonatomic, assign) BOOL                          localAudioStarted;
@property (nonatomic, assign) BOOL                          localVideoStarted;
@property (nonatomic, assign) BOOL                          localAudioMuted;
@property (nonatomic, assign) BOOL                          localVideoMuted;
@property (nonatomic, assign) LTGMediaAudioOutput           audioOutput;
@property (nonatomic, strong) NSArray                       *clients;


/**
 *  Singleton instance of LTGConnector object, this method ensure
 *  only single instance created on current app context.
 *  @return LTGConnector object instance
 */
+ (LTGConnector *)sharedConnector;

/**
 *  Constructor with LTGConnectorDelegate delegate
 *  @param delegate an object instance that conforms to LTGConnectorDelegate
 *  @return LTGConnector instance
 */
- (instancetype)initWithDelegate:(id<LTGConnectorDelegate>)delegate;

/**
 *  setup connector enviroment
 */
- (void)setup:(NSDictionary *)options;

/**
 *  shutdown connector enviroment
 */
- (void)shutdown;


/**
 *  Get LTGClient with clientid,
 *  You may use this function to client query or get a contructed instance for client.
 *
 *  @param clientId client identifier
 *
 *  @return LTGClient instance
 */
- (LTGClient *)clientWithId:(NSString *)clientId;


/**
 *  Connect to server environment
 *
 *  @param customProperties Custom user profile configuration that will be hold by server
 *  server also share this data with other connected clients as json data.
 *  @param statusBlock      connection status function callback. see : connectionHandler type
 */
- (void)connect;
- (void)connect:(NSDictionary *)customProperties;


/**
 *  Disconnect from server environment
 *
 */
- (void)disconnect;


/**
 *  Join a room on server side.
 *
 *  @param roomName    target room name
 */
- (void)join:(NSString *)sessionName;

/**
 *  Leave from room
 *
 */
- (void)leave;


/**
 *  Start local medias (audio and video)
 *
 *  @param audio enable / disable audio
 *  @param video anable / disable video
 */
- (void)startLocalMedia:(BOOL)audio video:(BOOL)video;


/**
 *  Stop started local medias
 */
- (void)stopLocalMedia;


/**
 *  Mute / Unmute audio Internal mute state can be track with audioMuted property.
 *  see audioMuted
 *
 *  @param mute Boolean value to change mute state.
 */
- (void)muteAudio:(BOOL)mute;
- (void)muteVideo:(BOOL)mute;

- (void)switchCamera;

/**
 *  Toogle audio output between speaker and headset, the default value is LTGMediaAudioOutputSpeaker
 *
 *  @param output LTGMediaAudioOutput enumeration value. See LTGMediaAudioOutput
 */
- (void)toggleAudioOutput:(LTGMediaAudioOutput)output;
@end


@protocol LTGConnectorDelegate <NSObject>
@optional
- (void)connector:(LTGConnector *)connector connected:(NSString *)sessionId error:(NSError *)error;
- (void)connector:(LTGConnector *)connector disconnected:(NSString *)sessionId error:(NSError *)error;
- (void)connector:(LTGConnector *)connector joined:(NSString *)sessionName clients:(NSArray *)clients error:(NSError *)error;
- (void)connector:(LTGConnector *)connector left:(NSString *)sessionName error:(NSError *)error;
- (void)connector:(LTGConnector *)connector clientJoined:(LTGClient *)client sessionName:(NSString *)sessionName;
- (void)connector:(LTGConnector *)connector clientLeft:(LTGClient *)client sessionName:(NSString *)sessionName;
- (void)connector:(LTGConnector *)connector iotDataReceived:(NSDictionary *)data;

@end


@protocol LTGConnectorMediaSource <NSObject>

@optional
- (UIView *)connector:(LTGConnector *)localMediaPreviewView;
- (void)connector:(LTGConnector *)connector localMediaDidStarted:(NSError *)error;
- (void)connector:(LTGConnector *)connector localMediaDidStopped:(NSError *)error;

@end

