//
//  CallReceivedViewController.m
//  Connect-Sample
//
//  Created by Fatih YASAR on 29/01/2017.
//  Copyright © 2017 Luteg Software Technologies. All rights reserved.
//

#import "CallReceivedViewController.h"

@interface CallReceivedViewController ()

@end

@implementation CallReceivedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)acceptCall:(id)sender {
    [self.delegate callAccepted:YES];
}

- (IBAction)declineCall:(id)sender {
    [self.delegate callAccepted:NO];
}

@end
