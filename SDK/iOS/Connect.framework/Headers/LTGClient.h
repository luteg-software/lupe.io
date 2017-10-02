//
//  LTGClient.h
//  Connect
//
//  Created by Fatih YASAR on 13/12/2016.
//  Copyright © 2016 Luteg Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTGClientDelegate.h"
#import "LTGFileInfo.h"
#import "LTGCallOptions.h"


@protocol LTGClientDelegate;

@interface LTGClient : NSObject

@property (nonatomic, strong) NSString                  *clientId;
@property (nonatomic, strong) NSString                  *sessionId;
@property (nonatomic, strong) NSDictionary              *customProperties;
@property (nonatomic, assign) BOOL                      hasCall;
@property (nonatomic, weak)   id<LTGClientDelegate>     delegate;
@property (nonatomic, weak)   id<LTGClientMediaSource>  mediaSource;
@property (nonatomic, strong) NSNumber                  *maximumBitRate;
@property (nonatomic, assign) LTGClientConnectionState  state;

-(instancetype) __unavailable init;


- (void)openDataChannel:(NSString *)channelName confirmationMessage:(NSString *)confirmationMessage;


-(void)sendMessage:(NSString *)message
       channelName:(NSString *)channelName;


- (void)closeDataChannel:(NSString *)channelName;


- (void)sendFile:(NSString *)filePath;
- (void)sendFile:(NSString *)filePath confirmationMessage:(NSString *)confirmationMessage;


- (void)call:(LTGCallOptions *)callOptions;
- (void)hangup;


@end
