//
//  CallReceivedViewController.h
//  Connect-Sample
//
//  Created by Fatih YASAR on 29/01/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallReceivedDelegate <NSObject>
-(void)callAccepted:(BOOL)accepted;
@end

@interface CallReceivedViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *confirmartionLabel;
@property(nonatomic, weak) id<CallReceivedDelegate> delegate;
@end
