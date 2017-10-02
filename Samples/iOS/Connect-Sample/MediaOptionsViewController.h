//
//  MediaOptionsViewController.h
//  Connect-Sample
//
//  Created by Fatih YASAR on 29/01/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Connect/Connect.h>

typedef NS_ENUM(NSInteger, MediaOption) {
    MediaOptionAudio       = 0,
    MediaOptionVideo       = 1,
    MediaOptionData        = 2
};

@protocol CallMediaOptionsDelegate <NSObject>

- (void)mediaOptionsSelected:(BOOL)sendAudio
                   sendVideo:(BOOL)sendVideo
                receiveAudio:(BOOL)receiveAudio
                receiveVideo:(BOOL)receiveVideo
                 dataChannel:(BOOL)dataChannel
         confirmationMessage:(NSString *)confirmationMessage
          targetStoryboardId:(NSString *)targetStoryboardId;
@end

@interface MediaOptionsViewController : UIViewController

@property(nonatomic, weak) id<CallMediaOptionsDelegate> delegate;
@property(nonatomic, assign) MediaOption mediaOption;
@property(nonatomic, strong) NSString *targetControllerStoryboardId;
@end

