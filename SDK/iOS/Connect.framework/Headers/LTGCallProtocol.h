//
//  LTGCallRequest.h
//  LutegWebRTC
//
//  Created by Fatih YASAR on 25/06/15.
//  Copyright (c) 2015 Luteg Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTGCallProtocol : NSObject

@property(nonatomic, strong) NSString *sessionId;
@property(nonatomic, assign) BOOL sendAudio;
@property(nonatomic, assign) BOOL sendVideo;
@property(nonatomic, assign) BOOL receiveAudio;
@property(nonatomic, assign) BOOL receiveVideo;
@property(nonatomic, assign) BOOL accepted;
@property(nonatomic, strong) NSString *confirmationMessage;
@property(nonatomic, assign) BOOL isRequest;

- (NSDictionary *)toDictionary;
+ (instancetype)initWithDictionary:(NSDictionary *)data;
- (void)parseResponse:(NSDictionary *)data;

@end


