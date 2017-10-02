//
//  ChatViewController.h
//  LutegWebRTC Demo
//
//  Created by Fatih YASAR on 08/06/15.
//  Copyright (c) 2015 Luteg Software Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <Connect/Connect.h>
#import "JSQMessages.h"

@interface ChatViewController : JSQMessagesViewController

/**
 * We have already created an LTGClient instance.
 * we should pass it as weak refference to prevent unnecessary retains
 */
@property(nonatomic, weak) LTGClient *client;

/**
 *  Desired channel name
 */
@property(nonatomic, strong) NSString  *channelName;
@property(nonatomic, assign) BOOL       isRemoteChannel;
@property(nonatomic, strong) NSString  *confirmationMessage;

@end
