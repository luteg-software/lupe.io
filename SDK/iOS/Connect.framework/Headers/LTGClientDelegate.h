//
//  LTGClientDelegate.h
//  LutegWebRTC
//
//  Created by Fatih YASAR on 17/06/15.
//  Copyright (c) 2015 Luteg Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LTGClient.h"

@class LTGClient;
@class LTGFileInfo;
@class LTGCallOptions;

typedef NS_ENUM(NSInteger, LTGClientConnectionState) {
    // Disconnected from remote peer.
    LTGClientConnectionStateDisconnected,
    // Connecting to remote peer.
    LTGClientConnectionStateConnecting,
    // Connected to remote peer.
    LTGClientConnectionStateConnected
};



typedef void (^requestAcceptBlock) ();
typedef void (^requestDeclineBlock) ();


@protocol LTGClientDelegate <NSObject>

@optional


/* Data channels */
- (void)client:(LTGClient *)client dataChannelOpened:(NSString *)channelName isRemote:(BOOL)isRemote error:(NSError *)error;
- (void)client:(LTGClient *)client dataChannelClosed:(NSString *)channelName error:(NSError *)error;
- (void)client:(LTGClient *)client dataChannelError:(NSString *)channelName error:(NSError *)error;
- (void)client:(LTGClient *)client dataChannelRequestAccepted:(NSString *)channelName;
- (void)client:(LTGClient *)client dataChannelRequestDeclined:(NSString *)channelName;
- (void)client:(LTGClient *)client dataChannelRequestReceived:(NSString *)channelName confirmationMessage:(NSString *)confirmationMessage accept:(requestAcceptBlock)accept decline:(requestDeclineBlock)decline;


/* Text Messaging */
- (void)client:(LTGClient *)client messageReceived:(NSString *)message channelName:(NSString *)channelName;
- (void)client:(LTGClient *)client messageSent:(NSString *)message channelName:(NSString *)channelName error:(NSError *)error;


/* File send & receive operations */
- (void)client:(LTGClient *)client fileTransferRequestReceived:(LTGFileInfo *)fileInfo
confirmationMessage:(NSString *)confirmationMessage accept:(requestAcceptBlock)accept decline:(requestDeclineBlock)decline;
- (void)client:(LTGClient *)client fileTransferRequestAccepted:(LTGFileInfo *)fileInfo;
- (void)client:(LTGClient *)client fileTransferRequestDeclined:(LTGFileInfo *)fileInfo;
/* File sending */
- (void)client:(LTGClient *)client fileDataWillSend:(LTGFileInfo *)fileInfo;
- (void)client:(LTGClient *)client fileDataSent:(LTGFileInfo *)fileInfo progress:(float)progress;
- (void)client:(LTGClient *)client fileSent:(LTGFileInfo *)fileInfo;
/* File receiving */
- (void)client:(LTGClient *)client fileDataWillReceive:(LTGFileInfo *)fileInfo;
- (void)client:(LTGClient *)client fileDataReceived:(LTGFileInfo *)fileInfo data:(NSData *)data progress:(float)progress;
- (void)client:(LTGClient *)client fileReceived:(LTGFileInfo *)fileInfo;


/* Call operations for voice and video */
- (void)client:(LTGClient *)client callRequestReceived:(NSString *)confirmationMessage
        accept:(requestAcceptBlock)accept decline:(requestDeclineBlock)decline;
- (void)client:(LTGClient *)client callRequestAccepted:(LTGCallOptions *)callOptions;
- (void)client:(LTGClient *)client callRequestDeclined:(LTGCallOptions *)callOptions;
- (void)client:(LTGClient *)client hangupReceived:(NSDictionary *)payload;
- (void)client:(LTGClient *)client hangupCompletedWitherror:(NSError *)error;
- (void)client:(LTGClient *)client didError:(NSError *)error;
- (void)client:(LTGClient *)client didConnectionStateChanged:(LTGClientConnectionState)state;
@end



@protocol LTGClientMediaSource <NSObject>

@optional
- (UIView *)mediaPreviewView:(LTGClient *)client;

@end
