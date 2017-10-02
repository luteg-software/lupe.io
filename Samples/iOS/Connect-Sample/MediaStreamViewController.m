//
//  MediaStreamViewController.m
//  Connect-Sample
//
//  Created by Fatih YASAR on 10/02/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import "MediaStreamViewController.h"

@interface MediaStreamViewController () <LTGClientDelegate, LTGConnectorMediaSource, LTGClientMediaSource>
{
    LTGConnector *connector;
}
@property (weak, nonatomic) IBOutlet UIView *localvideoView;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoView;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchCamera;


@property (weak, nonatomic) IBOutlet UIButton *addVideoStreamButton;
@property (weak, nonatomic) IBOutlet UIButton *removeVideoStreamButton;
@property (weak, nonatomic) IBOutlet UIButton *addAudioStreamButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAudioStreamButton;


@end

@implementation MediaStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.localvideoView.hidden = YES;
    self.switchCamera.hidden = YES;
    
    connector = [LTGConnector sharedConnector];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    connector.mediaSource = self;
    
    [self.addAudioStreamButton setTitle:@"Add Audio Stream" forState:UIControlStateNormal];
    [self.addVideoStreamButton setTitle:@"Add Video Stream" forState:UIControlStateNormal];
    
    //Do not start my localmedia yet
    [connector startLocalMedia:NO video:NO];
    
    for (LTGClient *client in self.remoteClients) {
        
        client.delegate = self;
        client.mediaSource = self;
        
        if(self.callType == CALL_TYPE_CALLER) {
            [client call:self.callOptions];
        }
    }
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
    [connector switchCamera];
        
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


- (IBAction)addVideoStreamTap:(id)sender {

    if([self.addVideoStreamButton.titleLabel.text isEqualToString:@"Add Video Stream"]) {
        [connector startLocalMedia:connector.localAudioStarted video:YES];
        [self.addVideoStreamButton setTitle:@"Remove Video Stream" forState:UIControlStateNormal];
    
    }else {
        [self.addVideoStreamButton setTitle:@"Add Video Stream" forState:UIControlStateNormal];
        [connector startLocalMedia:connector.localAudioStarted video:NO];
    }    
}


- (IBAction)addAudioStreamTap:(id)sender {

    if([self.addAudioStreamButton.titleLabel.text isEqualToString:@"Add Audio Stream"]) {
        [self.addAudioStreamButton setTitle:@"Remove Audio Stream" forState:UIControlStateNormal];
        [connector startLocalMedia:YES video:connector.localVideoStarted];
        
    }else {
        [self.addAudioStreamButton setTitle:@"Add Audio Stream" forState:UIControlStateNormal];
        [connector startLocalMedia:NO video:connector.localVideoStarted];
    }
    
}



#pragma mark - 
#pragma mark LTGConnectorMediaSource
- (void)connector:(LTGConnector *)connector localMediaDidStopped:(NSError *)error {
    self.localvideoView.hidden = YES;
}

@end
