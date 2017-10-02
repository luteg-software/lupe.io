//
//  ChatViewController.m
//  LutegWebRTC Demo
//
//  Created by Fatih YASAR on 08/06/15.
//  Copyright (c) 2015 Luteg Software Technologies. All rights reserved.
//

#import "ChatViewController.h"
#import <Connect/LTGClient.h>
#import "NSUserDefaults+DemoSettings.h"
#import "DemoModelData.h"
#import "JSQSystemSoundPlayer.h"
#import "JSQSystemSoundPlayer+JSQMessages.h"

@interface ChatViewController ()<LTGClientDelegate>
{
    //blocks refference
    requestAcceptBlock acceptDataChannel;
    requestDeclineBlock declineDataChannel;
}

@property (nonatomic, strong) LTGConnector *connector;
@property (strong, nonatomic) DemoModelData *demoData;
@property (strong, nonnull) NSString *senderId;
@property (strong, nonnull) NSString *senderDisplayName;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property(nonatomic, strong) NSMutableArray *messages;
@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Chat Sample";

    self.senderId = @"AF3AD4EA-E1DC-43C4-9A36-4425B88F5031";
    self.senderDisplayName = @"You";
    
    self.messages = [NSMutableArray array];
    self.demoData = [[DemoModelData alloc] init];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];


    _client.delegate = self;
    if(!_isRemoteChannel) {
        //[self.client openDataChannel:_channelName confirmationMessage:@"Confirmation Test"];
        [self.client openDataChannel:_channelName confirmationMessage:nil];
    } else {
        [self showDataChannelReadyToUse];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
}



-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.client.delegate = nil;
    [self.client closeDataChannel:_channelName];
    [self.client hangup];
}



#pragma mark - JSQMessagesViewController method overrides
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [_client sendMessage:text channelName:_channelName];
    
}


#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
     return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}


- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - JSQMessages collection view flow layout delegate
#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods
- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.demoData.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

#pragma mark - JSQMessagesViewAccessoryDelegate methods

- (void)messageView:(JSQMessagesCollectionView *)view didTapAccessoryButtonAtIndexPath:(NSIndexPath *)path
{
    NSLog(@"Tapped accessory button!");
}



#pragma mark -
#pragma mark LTGClientDelegate implementations
- (void)client:(LTGClient *)client dataChannelOpened:(NSString *)channelName isRemote:(BOOL)isRemote error:(NSError *)error {
    NSLog(@"%s - channelName : %@ -  error : %@", __PRETTY_FUNCTION__, channelName, error);
    
    /* dispatch async */
    dispatch_async(dispatch_get_main_queue(), ^{
        if([_channelName isEqualToString:channelName]) {
            [self showDataChannelReadyToUse];
        }
    });
}

- (void)showDataChannelReadyToUse {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are ready to chat"
                                                    message:@"Now, you can start chat with remote peer"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}


- (void)client:(LTGClient *)client dataChannelClosed:(NSString *)channelName error:(NSError *)error {
    NSLog(@"%s - channelName : %@ - error : %@", __PRETTY_FUNCTION__, channelName, error);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Channel closed"
                                                    message:@"Chat data channel closed."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)client:(LTGClient *)client messageReceived:(NSString *)message channelName:(NSString *)channelName {
    NSLog(@"%s - message : %@ - channelName : %@", __PRETTY_FUNCTION__, message, channelName);
    dispatch_async(dispatch_get_main_queue(), ^{
        JSQMessage *newMessage = [JSQMessage messageWithSenderId:client.clientId
                                                     displayName:client.clientId
                                                            text:message];
        
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
    });
}

- (void)client:(LTGClient *)client messageSent:(NSString *)message channelName:(NSString *)channelName error:(NSError *)error {
    NSLog(@"%s - message : %@ - channelName : %@ - error : %@", __PRETTY_FUNCTION__, message, channelName, error);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        JSQMessage *msg = [[JSQMessage alloc] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:[NSDate date]
                                                          text:message];
        
        [self.messages addObject:msg];
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        [self finishSendingMessageAnimated:YES];
    });
}


- (void)client:(LTGClient *)client dataChannelError:(NSString *)channelName error:(NSError *)error {
    NSLog(@"%s - channelName : %@ - error : %@", __PRETTY_FUNCTION__, channelName, error);
}

- (void)client:(LTGClient *)client dataChannelRequestAccepted:(NSString *)channelName {
    NSLog(@"%s - channelName : %@", __PRETTY_FUNCTION__, channelName);
}

- (void)client:(LTGClient *)client dataChannelRequestDeclined:(NSString *)channelName {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                    message:@"Data channel declined by remote client"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}


- (void)client:(LTGClient *)client dataChannelRequestReceived:(NSString *)channelName confirmationMessage:(NSString *)confirmationMessage accept:(requestAcceptBlock)accept decline:(requestDeclineBlock)decline {
    acceptDataChannel = accept;
    declineDataChannel = decline;
    
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
    if(buttonIndex == 0) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else if (buttonIndex == 1) {
        acceptDataChannel();
    }else if (buttonIndex == 2) {
        declineDataChannel();
    }
}

@end
