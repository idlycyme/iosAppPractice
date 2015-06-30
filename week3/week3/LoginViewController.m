//
//  LoginViewController.m
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "LoginViewController.h"
#import "TweetsViewController.h"
#import "TwitterClient.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (error == nil) {
            if (user != nil) {
                NSLog(@"Welcome to %@", user.name);
                UINavigationController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"navigation"];
                [self presentViewController:controller animated:YES completion:nil];
            } else {
                NSLog(@"[ERROR] No user data");
            }
        } else {
            NSLog(@"[ERROR] Failed to login");
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
