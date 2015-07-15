//
//  ComposeViewController.m
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "ComposeViewController.h"
#import <UIImageView+AFNetworking.h>
#import "TwitterClient.h"

@interface ComposeViewController () <UITextViewDelegate>

@end
static int MAX_WORD_IN_A_TWEET = 140;

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.user.profileImage != nil) {
        self.userProfileImage.image = self.user.profileImage;
    } else {
        NSString *imageUrl = self.user.profileImageUrl;
        [self.userProfileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.userProfileImage.alpha = 0.9;
            self.userProfileImage.image = image;
            // fade in effect
            [UIView beginAnimations:@"fadeIn" context:nil];
            [UIView setAnimationDuration:5.0];
            self.userProfileImage.alpha = 1.0;
            [UIView commitAnimations];
            self.userProfileImage.image = image;
            self.user.profileImage = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            // network error
            NSLog(@"[ERROR] Failed with profile image retrieval: %@", error);
        }];
    }
    
    self.userName.text = self.user.name;
    self.userScreenname.text = self.user.screenname;
    if (self.idToReply != nil && self.prefix != nil) {
        self.textField.text = self.prefix;
    }
    [self.textField sizeToFit];
    [self.textField becomeFirstResponder];
    self.tweetButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textViewDidChange:(UITextView *)textView{
    int count = MAX_WORD_IN_A_TWEET - (int)textView.text.length;
    if (count) {
        self.tweetButton.enabled = YES;
    } else {
        self.tweetButton.enabled = NO;
    }
    self.wordsLeft.text = [NSString stringWithFormat:@"%d", count];
    
    if (count < 0) {
        self.textField.text = [self.textField.text substringToIndex:140];
        count = 0;
        self.wordsLeft.text = [NSString stringWithFormat:@"%d", count];
    }
    if (count == 0) {
        self.wordsLeft.textColor = [UIColor redColor];
    } else {
        self.wordsLeft.textColor = [UIColor grayColor];
    }
    
    
    [self.textField sizeToFit];
}

- (IBAction)onTweet:(id)sender {
    if ([self.textField.text isEqualToString:@""]) {
        return;
    }
    [self.delegate composer:self DidComposeWithText:self.textField.text ReplyToId:self.idToReply];
    
    /* //Original non-delegate implementation
    [[TwitterClient sharedInstance] tweet:self.textField.text repliesTo:self.idToReply completion:^(Tweet *tweet, NSError *error) {
        NSLog(@"tweet success");
        //Todo append latest tweet
        
        [self.navigationController popViewControllerAnimated:YES];
        //error handling
    }];
    */
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
