//
//  LTGDataChannel.h
//  LutegWebRTC
//
//  Created by Fatih YASAR on 22/06/15.
//  Copyright (c) 2015 Luteg Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTCDataChannel;
@class LTGDataChannel;
@class LTGFileInfo;
@class LTGFileProgress;

typedef enum {
    LTGDataChannelStateNew,
    LTGDataChannelStateOpen,
    LTGDataChannelStateClosed
} LTGDataChannelState;

typedef void (^onOpen)(LTGDataChannel *channel);
typedef void (^onClose)(LTGDataChannel *channel);
typedef void (^onMessage)(LTGDataChannel *channel, NSString *message);
typedef void (^onFileDataReceiving)(LTGDataChannel *channel, NSData *data, float progress);
typedef void (^onFileDataReceived)(LTGDataChannel *channel, LTGFileInfo *fileInfo);
typedef void (^onFileDataSending)(LTGDataChannel *channel, float progress);
typedef void (^onFileDataSent)(LTGDataChannel *channel);


@interface LTGDataChannel : NSObject

- (instancetype)initWithDataChannelInstance:(RTCDataChannel *)channel;

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, assign) BOOL isRemote;

@property(nonatomic, assign, readonly) LTGDataChannelState state;

@property (nonatomic, copy) onOpen                  onOpenBlock;
@property (nonatomic, copy) onClose                 onCloseBlock;
@property (nonatomic, copy) onMessage               onMessageBlock;
@property (nonatomic, copy) onFileDataReceiving     onFileDataReceivingBlock;
@property (nonatomic, copy) onFileDataReceived      onFileDataReceivedBlock;
@property (nonatomic, copy) onFileDataSending       onFileDataSendingBlock;
@property (nonatomic, copy) onFileDataSent          onFileDataSentBlock;


//file send - receive
@property (nonatomic, strong) LTGFileInfo *fileInfo;
@property (nonatomic, strong) LTGFileProgress *fileProgress;
- (void)sendFile;

//messaging
- (BOOL)sendMessageAsData:(NSData *)data;
- (BOOL)sendMessage:(NSString *)message;

- (void)close;
@end
