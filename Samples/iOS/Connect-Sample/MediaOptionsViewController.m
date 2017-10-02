//
//  MediaOptionsViewController.m
//  Connect-Sample
//
//  Created by Fatih YASAR on 29/01/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import "MediaOptionsViewController.h"

@interface MediaOptionsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *audioSend;
@property (weak, nonatomic) IBOutlet UISwitch *videoSend;
@property (weak, nonatomic) IBOutlet UITextField *confirmationMessage;

@property (weak, nonatomic) IBOutlet UISwitch *receiveAudio;
@property (weak, nonatomic) IBOutlet UISwitch *receiveVideo;
@property (weak, nonatomic) IBOutlet UISwitch *dataChannel;

@end

@implementation MediaOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    if(self.mediaOption == MediaOptionData) {
        self.confirmationMessage.enabled = NO;
        self.audioSend.on = NO;
        self.audioSend.enabled = NO;
        self.videoSend.on = NO;
        self.videoSend.enabled = NO;
        self.receiveAudio.on = NO;
        self.receiveAudio.enabled = NO;
        self.receiveVideo.on = NO;
        self.receiveVideo.enabled = NO;
    } else if(self.mediaOption == MediaOptionAudio) {
        self.videoSend.on = NO;
        self.videoSend.enabled = NO;
        self.receiveVideo.on = NO;
        self.receiveVideo.enabled = NO;
    }
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.confirmationMessage resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setCallOptions:(id)sender {
    
    [self.delegate mediaOptionsSelected:self.audioSend.on
                              sendVideo:self.videoSend.on
                           receiveAudio:self.receiveAudio.on
                           receiveVideo:self.receiveVideo.on
                            dataChannel:self.dataChannel.on
                    confirmationMessage:self.confirmationMessage.text
                     targetStoryboardId:self.targetControllerStoryboardId];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(![touch.view isMemberOfClass:[UITextField class]]) {
        [touch.view endEditing:YES];
    }
}

@end
