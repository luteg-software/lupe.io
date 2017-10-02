//
//  LTGDataChannelProtocol.h
//  LutegWebRTC
//
//  Created by Fatih YASAR on 27/06/15.
//  Copyright (c) 2015 Luteg Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTGDataChannelProtocol : NSObject

@property(nonatomic, strong) NSString   *name;
@property(nonatomic, strong) NSString   *confirmationMessage;
@property(nonatomic, assign) BOOL       accepted;
@property(nonatomic, assign) BOOL       isRequest;

- (NSDictionary *)toDictionary;
- (void)parseResponse:(NSDictionary *)data;

+ (instancetype)initWithDictionary:(NSDictionary *)data;

@end
