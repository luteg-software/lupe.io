//
//  AudioCallViewController.h
//  Connect-Sample
//
//  Created by Fatih YASAR on 23/02/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Connect/Connect.h>
#import "Common.h"

@interface AudioCallViewController : UIViewController

@property (nonatomic, assign) CALL_TYPE     callType;
@property(nonatomic, strong) NSArray        *remoteClients;
@property(nonatomic, strong) LTGCallOptions *callOptions;

@end
