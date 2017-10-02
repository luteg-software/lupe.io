//
//  MediaStreamViewController.h
//  Connect-Sample
//
//  Created by Fatih YASAR on 10/02/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Connect/Connect.h>
#import "Common.h"


@interface MediaStreamViewController : UIViewController

@property (nonatomic, assign) CALL_TYPE     callType;
@property(nonatomic, strong) NSArray        *remoteClients;
@property(nonatomic, strong) LTGCallOptions *callOptions;

@end
