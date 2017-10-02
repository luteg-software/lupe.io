//
//  VideoConferenceViewController.h
//  Connect-Sample
//
//  Created by Fatih YASAR on 28/01/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Connect/Connect.h>
#import "Common.h"


@interface CallViewController : UIViewController

@property (nonatomic, assign) CALL_TYPE     callType;
@property(nonatomic, strong) NSArray        *remoteClients;
@property(nonatomic, strong) LTGCallOptions *callOptions;

@end
