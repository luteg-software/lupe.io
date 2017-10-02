//
//  VideoConferenceViewController.m
//  Connect-Sample
//
//  Created by Fatih YASAR on 28/01/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import "CallViewController.h"

@interface CallViewController () <LTGClientDelegate, LTGConnectorMediaSource, LTGClientMediaSource>
{

}
@property (strong, nonatomic) LTGClient *activeClient;
@property (weak, nonatomic) IBOutlet UIView *localvideoView;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoView;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchCamera;

@end

@implementation CallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.localvideoView.hidden = YES;
    self.switchCamera.hidden = YES;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [LTGConnector sharedConnector].mediaSource = self;
    [[LTGConnector sharedConnector] startLocalMedia:YES video:YES];
    
    for (LTGClient *client in self.remoteClients) {
        
        client.delegate = self;
        client.mediaSource = self;

        if(self.callType == CALL_TYPE_CALLER) {
            self.activeClient = client;
            [client call:self.callOptions];
            return;
        }
    }
}

- (IBAction)muteAudio:(id)sender {
    [[LTGConnector sharedConnector] muteAudio:![LTGConnector sharedConnector].localAudioMuted];
}

- (IBAction)muteVideo:(id)sender {
    [[LTGConnector sharedConnector] muteVideo:![LTGConnector sharedConnector].localVideoMuted];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark
#pragma mark LTGClientDelegate
- (void)client:(LTGClient *)client callRequestAccepted:(LTGCallOptions *)callOptions {
    self.statusLabel.text = @"Your call accepted by remote user";
}

- (void)client:(LTGClient *)client callRequestDeclined:(LTGCallOptions *)callOptions {
    self.statusLabel.text = @"Your call declined by remote user";
}

- (void)client:(LTGClient *)client hangupReceived:(NSDictionary *)payload {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)client:(LTGClient *)client hangupCompletedWitherror:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)client:(LTGClient *)client didError:(NSError *)error {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Ops"
                                 message:error.localizedDescription
                                 preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark LTGConnectorMediaSource
- (UIView *)connector:(LTGConnector *)localMediaPreviewView {
    self.localvideoView.hidden = NO;
    self.switchCamera.hidden = NO;
    return self.localvideoView;
}

#pragma mark -
#pragma mark LTGClientMediaSource
- (UIView *)mediaPreviewView:(LTGClient *)client {
    self.statusLabel.hidden = YES;
    return self.remoteVideoView;
}


- (IBAction)switchCameraAction:(id)sender {
    [[LTGConnector sharedConnector] switchCamera];
    
    [UIView beginAnimations:@"Flip" context:NULL];
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.localvideoView cache:NO];
    
    [UIView commitAnimations];
    
}

- (IBAction)hangupAction:(id)sender {
    for (LTGClient *client in self.remoteClients) {
        [client hangup];
    }
}

@end
