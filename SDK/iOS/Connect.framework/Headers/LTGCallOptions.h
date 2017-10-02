//
//  LTGCallOptions.h
//  LutegWebRTC
//
//  Created by Fatih YASAR on 25/06/15.
//  Copyright (c) 2015 Luteg Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTGCallOptions : NSObject

@property (nonatomic, assign) BOOL      audio;
@property (nonatomic, assign) BOOL      video;
@property (nonatomic, strong) NSString  *confirmationMessage;
@end
