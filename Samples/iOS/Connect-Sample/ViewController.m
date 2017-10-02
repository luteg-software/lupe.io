//
//  ViewController.m
//  Connect-Sample
//
//  Created by Fatih YASAR on 29/11/2016.
//  Copyright © 2016 Luteg Software Technologies. All rights reserved.
//

#import "ViewController.h"
#import "SRMModalViewController.h"
#import "CallViewController.h"
#import "MediaOptionsViewController.h"
#import "AudioCallViewController.h"
#import "CallReceivedViewController.h"
#import "MediaStreamViewController.h"
#import "ChatViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, LTGConnectorDelegate, LTGClientMediaSource, LTGClientDelegate, CallMediaOptionsDelegate, CallReceivedDelegate>
{
    //blocks refference
    requestAcceptBlock acceptRequest;
    requestDeclineBlock declineRequest;
    LTGClient *callerClient;
}

@property (strong, nonatomic) NSIndexPath *selectedIndex;

@property (weak, nonatomic) IBOutlet UIButton *connectionButton;
@property (weak, nonatomic) IBOutlet UITextField *sessionNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.connectionButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.joinButton setTitle:@"Join" forState:UIControlStateNormal];
    self.sessionNameTextField.enabled = NO;
    self.joinButton.enabled = NO;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LTGConnector sharedConnector].delegate = self;
    [self.usersTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectAction:(id)sender {
    if([self.connectionButton.titleLabel.text isEqualToString:@"Connect"]) {
        [self.connectionButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        [self connect];
    }else {
        [self.connectionButton setTitle:@"Connect" forState:UIControlStateNormal];
        [self disconnect];
    }
}


- (void)connect {
    NSLog(@"oooo");
    [LTGConnector sharedConnector].appKey = @"f5057270-a214-11e7-b235-c9789a68b5fa";
    [LTGConnector sharedConnector].appSecret = @"f54adfe0-a214-11e7-b235-c9789a68b5fa";
    [[LTGConnector sharedConnector] connect:@{@"userid" : [NSNumber numberWithInteger:332],
                                              @"fullName" : @"Sample User"}];
}

- (void)disconnect {
    [[LTGConnector sharedConnector] disconnect];
}

- (IBAction)joinToSession:(id)sender {
    if([self.joinButton.titleLabel.text isEqualToString:@"Join"]) {
        [self.joinButton setTitle:@"Leave" forState:UIControlStateNormal];
        [[LTGConnector sharedConnector] join:self.sessionNameTextField.text];
    }else {
        [self.joinButton setTitle:@"Join" forState:UIControlStateNormal];
        [[LTGConnector sharedConnector] leave];
    }
}

#pragma mark - 
#pragma mark LTGConnectorDelegate implementations
- (void)connector:(LTGConnector *)connector connected:(NSString *)sessionId error:(NSError *)error {
    self.sessionNameTextField.enabled = YES;
    self.joinButton.enabled = YES;
}
- (void)connector:(LTGConnector *)connector disconnected:(NSString *)sessionId error:(NSError *)error {
    [self.usersTableView reloadData];
    self.sessionNameTextField.enabled = NO;
    self.joinButton.enabled = NO;
    [self.joinButton setTitle:@"Join" forState:UIControlStateNormal];
}

- (void)connector:(LTGConnector *)connector joined:(NSString *)roomName clients:(NSArray *)clients error:(NSError *)error {
    [self.usersTableView reloadData];
}
- (void)connector:(LTGConnector *)connector left:(NSString *)roomName error:(NSError *)error{
    [self.usersTableView reloadData];
}

- (void)connector:(LTGConnector *)connector clientJoined:(LTGClient *)client sessionName:(NSString *)sessionName {
    [self.usersTableView reloadData];
}

- (void)connector:(LTGConnector *)connector clientLeft:(LTGClient *)client sessionName:(NSString *)sessionName {
    //NSLog(@"%s",__PRETTY_FUNCTION__);
    [self.usersTableView reloadData];
}


#pragma mark 
#pragma mark TableView for Users
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [LTGConnector sharedConnector].clients.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    LTGClient *client = [[LTGConnector sharedConnector].clients objectAtIndex:indexPath.row];
    cell.textLabel.text = client.clientId;
    client.delegate = self;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *actionSheet =
    [UIAlertController alertControllerWithTitle:nil message:@"Please select connection type"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    
    //Audio call
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Audio Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        LTGClient *client = [[LTGConnector sharedConnector].clients objectAtIndex:_selectedIndex.row];
        
        //set the local media options
        [LTGConnector sharedConnector].audio = YES;
        [LTGConnector sharedConnector].video = NO;
        
        //set client media options
        LTGCallOptions *options = [[LTGCallOptions alloc] init];
        options.audio = YES;
        options.video = NO;
        
        AudioCallViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"audioCallViewController"];
        controller.remoteClients = @[client];
        controller.callOptions = options;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:controller animated:NO completion:nil];
        
        
    }]];
    
    //Video call
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Video Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
        MediaOptionsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"mediaOptions"];
        controller.mediaOption = MediaOptionVideo;

        controller.view.frame = CGRectMake(0, 0, 320, 520);
        controller.view.backgroundColor = [UIColor whiteColor];
        controller.targetControllerStoryboardId = @"callViewController";
        controller.delegate = self;
        
        [[SRMModalViewController sharedInstance] showViewWithController:controller];
        
        _selectedIndex = indexPath;

    }]];
    

    
    //Data Channel
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Data Channel (Chat)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        MediaOptionsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"mediaOptions"];
        controller.mediaOption = MediaOptionData;
        
        [LTGConnector sharedConnector].audio = NO;
        [LTGConnector sharedConnector].video = NO;
        
        controller.view.frame = CGRectMake(0, 0, 320, 520);
        controller.view.backgroundColor = [UIColor whiteColor];
        controller.targetControllerStoryboardId = @"chat";
        controller.delegate = self;
        
        [[SRMModalViewController sharedInstance] showViewWithController:controller];
        _selectedIndex = indexPath;
        
    }]];
    
    

    //Manage media streams
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Media Streams" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        _selectedIndex = indexPath;
        
        LTGClient *client = [[LTGConnector sharedConnector].clients objectAtIndex:_selectedIndex.row];
        
        //set the local media options
        [LTGConnector sharedConnector].audio = YES;
        [LTGConnector sharedConnector].video = YES;

        //set client media options
        LTGCallOptions *options = [[LTGCallOptions alloc] init];
        options.audio = YES;
        options.video = YES;
        
        MediaStreamViewController *controller =
        [self.storyboard instantiateViewControllerWithIdentifier:@"mediaStreamController"];
        controller.remoteClients = @[client];
        controller.callOptions = options;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:controller animated:NO completion:nil];

        
    }]];

    
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}


#pragma mark 
#pragma mark CallMediaOptionsDelegate
- (void)mediaOptionsSelected:(BOOL)sendAudio
                   sendVideo:(BOOL)sendVideo
                receiveAudio:(BOOL)receiveAudio
                receiveVideo:(BOOL)receiveVideo
                 dataChannel:(BOOL)dataChannel
         confirmationMessage:(NSString *)confirmationMessage
          targetStoryboardId:(NSString *)targetStoryboardId {

    [[SRMModalViewController sharedInstance] hide];
    
    LTGClient *client = [[LTGConnector sharedConnector].clients objectAtIndex:_selectedIndex.row];

    //set the local media options
    [LTGConnector sharedConnector].audio = sendAudio;
    [LTGConnector sharedConnector].video = sendVideo;

    //set client media options
    LTGCallOptions *options = [[LTGCallOptions alloc] init];
    options.audio = receiveAudio;
    options.video = receiveVideo;
    options.confirmationMessage = confirmationMessage;
    
    if([targetStoryboardId isEqualToString:@"callViewController"]) {
        CallViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:targetStoryboardId];
        controller.remoteClients = @[client];
        controller.callOptions = options;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:controller animated:NO completion:nil];
    
    }else if ([targetStoryboardId isEqualToString:@"mediaStreamController"]) {
        
        MediaStreamViewController *controller =
        [self.storyboard instantiateViewControllerWithIdentifier:targetStoryboardId];
        controller.remoteClients = @[client];
        controller.callOptions = options;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:controller animated:NO completion:nil];
        
    }else if ([targetStoryboardId isEqualToString:@"chat"]) {
        
        LTGClient *client = [[LTGConnector sharedConnector].clients objectAtIndex:_selectedIndex.row];
        ChatViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatSample"];
        chatViewController.client = client;
        chatViewController.channelName = @"chat";
        chatViewController.confirmationMessage = confirmationMessage;
        chatViewController.isRemoteChannel = NO;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
        [self presentViewController:navController animated:NO completion:nil];

    }
}



#pragma mark -
#pragma mark LTGClientDelegate
- (void)client:(LTGClient *)client callRequestReceived:(NSString *)confirmationMessage
        accept:(requestAcceptBlock)accept
       decline:(requestDeclineBlock)decline {
    
    acceptRequest = accept;
    declineRequest = decline;
    callerClient = client;
    
    if(confirmationMessage && confirmationMessage.length > 0) {
        CallReceivedViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"callReceived"];
        controller.view.frame = CGRectMake(0, 0, 350, 260);
        controller.view.backgroundColor = [UIColor whiteColor];
        controller.confirmartionLabel.text = confirmationMessage;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.delegate = self;
        
        [[SRMModalViewController sharedInstance] showViewWithController:controller];
        [SRMModalViewController sharedInstance].enableTapOutsideToDismiss = NO;
        
    }else {
        
        CallViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"callViewController"];
        controller.remoteClients = @[callerClient];
        controller.callType = CALL_TYPE_CALLEE;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:controller animated:NO completion:^{
            acceptRequest();
        }];
    }
}

- (void)client:(LTGClient *)client dataChannelOpened:(NSString *)channelName isRemote:(BOOL)isRemote error:(NSError *)error {
    NSLog(@"%s - channelName : %@ -  error : %@", __PRETTY_FUNCTION__, channelName, error);
    
    
    /* dispatch async */
    dispatch_async(dispatch_get_main_queue(), ^{
        ChatViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatSample"];
        chatViewController.client = client;
        chatViewController.isRemoteChannel = isRemote;
        chatViewController.channelName = @"chat";
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
        [self presentViewController:navController animated:NO completion:^{

        }];

    });
}

- (void)client:(LTGClient *)client dataChannelRequestReceived:(NSString *)channelName confirmationMessage:(NSString *)confirmationMessage accept:(requestAcceptBlock)accept decline:(requestDeclineBlock)decline {
    acceptRequest = accept;
    declineRequest = decline;
    callerClient = client;

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data channel request received."
                                                    message:confirmationMessage
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Accept", @"Decline", nil];
    [alert show];
}


#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        ChatViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatSample"];
        chatViewController.client = callerClient;
        chatViewController.channelName = @"chat";
        chatViewController.isRemoteChannel = YES;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
        [self presentViewController:navController animated:NO completion:^{
            /* dispatch async */
            dispatch_async(dispatch_get_main_queue(), ^{
                acceptRequest();
            });
        }];

    }else if (buttonIndex == 1) {
        declineRequest();
    }
}

#pragma mark -
#pragma mark CallReceivedDelegate
-(void)callAccepted:(BOOL)accepted {
    [[SRMModalViewController sharedInstance] hide];
    
    if(!accepted) {
        declineRequest();
        return;
    }
    
    
    
    CallViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"callViewController"];
    controller.remoteClients = @[callerClient];
    controller.callType = CALL_TYPE_CALLEE;
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:controller animated:NO completion:^{
        acceptRequest();
    }];
    
}


@end
