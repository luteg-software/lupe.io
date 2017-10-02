//
//  AudioCallViewController.m
//  Connect-Sample
//
//  Created by Fatih YASAR on 23/02/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import "AudioCallViewController.h"

@interface AudioCallViewController ()<LTGClientDelegate>
{
    NSTimer *stopTimer;
    NSDate *startDate;
}

@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timer;
@end

@implementation AudioCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[LTGConnector sharedConnector].mediaSource = self;
    [[LTGConnector sharedConnector] startLocalMedia:_callOptions.audio video:_callOptions.video];
    
    for (LTGClient *client in self.remoteClients) {
        
        client.delegate = self;
        //client.mediaSource = self;
        
        if(self.callType == CALL_TYPE_CALLER) {
            [client call:self.callOptions];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)muteAudioTap:(id)sender {
    LTGConnector *connector = [LTGConnector sharedConnector];
    
    if(connector.localAudioMuted) {
        [self.muteButton setTitle:@"Mute Audio" forState:UIControlStateNormal];
    }else {
        [self.muteButton setTitle:@"Unmute Audio" forState:UIControlStateNormal];
    }
    [connector muteAudio:!connector.localAudioMuted];
}

- (IBAction)hangupTap:(id)sender {
    for (LTGClient *client in self.remoteClients) {
        [client hangup];
    }
}


-(void)updateTimer{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    self.timer.text = timeString;
}

#pragma mark -
#pragma mark LTGClientDelegate 
- (void)client:(LTGClient *)client hangupCompletedWitherror:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)client:(LTGClient *)client didConnectionStateChanged:(LTGClientConnectionState)state {
    self.statusLabel.text = @"Connected";
    
    startDate = [NSDate date];
    if (stopTimer == nil) {
        stopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                     target:self
                                                   selector:@selector(updateTimer)
                                                   userInfo:nil
                                                    repeats:YES];
    }
}


@end
