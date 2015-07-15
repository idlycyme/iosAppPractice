//
//  TweetDetailViewController.m
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "TweetDetailViewController.h"
#import <UIImageView+AFNetworking.h>
#import "ComposeViewController.h"
#import "ProfilePageViewController.h"
#import "TweetsViewController.h"
#import "SideMenuProtocol.h"

@interface TweetDetailViewController ()

@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.userName.text = self.tweet.user.name;
    self.userScreenname.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenname];
    
    self.text.text = self.tweet.text;
    self.favoriteCount.text = [NSString stringWithFormat:@"%d", self.tweet.favorite_count];
    self.retweetCount.text = [NSString stringWithFormat:@"%d", self.tweet.retweet_count];
    if (self.tweet.user.profileImage != nil) {
        self.userProfileImage.image = self.tweet.user.profileImage;
    } else {
        NSString *imageUrl = self.tweet.user.profileImageUrl;
        [self.userProfileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.userProfileImage.alpha = 0.9;
            self.userProfileImage.image = image;
            // fade in effect
            [UIView beginAnimations:@"fadeIn" context:nil];
            [UIView setAnimationDuration:5.0];
            self.userProfileImage.alpha = 1.0;
            [UIView commitAnimations];
            self.userProfileImage.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            // network error
            NSLog(@"[ERROR Failed with profile image retrieval: %@", error);
        }];
    }
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
    
    if (self.tweet.favorited) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
    
    if ([self.tweet.user.idStr isEqualToString:[User currentUser].idStr]) {
        self.retweetButton.enabled = NO;
    } else {
        self.retweetButton.enabled = YES;
    }
    
    self.userProfileImage.layer.cornerRadius = 5;
    self.userProfileImage.clipsToBounds = YES;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm";
    self.createdAt.text = [formatter stringFromDate:self.tweet.createAt];
    
    
    UITapGestureRecognizer *tapOnProfileImage =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileImage)];
    [self.userProfileImage addGestureRecognizer:tapOnProfileImage];
    
    
}

- (void)tapOnProfileImage {
    //NSLog(@"Tap on image");
    //[self performSegueWithIdentifier:@"detail2profile" sender:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRetweet:(id)sender {
    NSLog(@"detail onRetweet");
    if (self.tweet.retweeted == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
        self.tweet.retweet_count++;
        self.tweet.retweeted = 1;
        self.retweetCount.text = [NSString stringWithFormat:@"%d", self.tweet.retweet_count];
        self.retweetButton.imageView.image = [UIImage imageNamed:@"retweet_on"];
        });
        [self.delegate detailViewController:self doActions:@"retweet"];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
        self.tweet.retweet_count--;
        self.tweet.retweeted = 0;
        self.retweetCount.text = [NSString stringWithFormat:@"%d", self.tweet.retweet_count];
        self.retweetButton.imageView.image = [UIImage imageNamed:@"retweet"];
        });
        [self.delegate detailViewController:self doActions:@"unretweet"];
    }
}

- (NSString *)getPossibleEmbededImageURL:(NSString *)text {
    NSRange range = [text rangeOfString:@"http://t.co/[^ ]+" options:NSRegularExpressionSearch];
    NSString *retValue = nil;
    if (range.length > 0) {
        retValue = [text substringWithRange:range];
    }
    return retValue;
}

- (IBAction)onLongPressToAccount:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        TweetsViewController *ctr = (TweetDetailViewController*)self.delegate;
        [ctr.delegate controller:ctr DidPressMenuButton:sender];
    }
}

- (IBAction)onFavorite:(id)sender {
    NSLog(@"detail onFavorite");
    if (self.tweet.favorited == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
        self.tweet.favorite_count++;
        self.tweet.favorited = 1;
        self.favoriteCount.text = [NSString stringWithFormat:@"%d", self.tweet.favorite_count];
        self.favoriteButton.imageView.image = [UIImage imageNamed:@"favorite_on"];
        });
        [self.delegate detailViewController:self doActions:@"favorite"];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
        self.tweet.favorited = 0;
        self.tweet.favorite_count--;
        self.favoriteCount.text = [NSString stringWithFormat:@"%d", self.tweet.favorite_count];
        self.favoriteButton.imageView.image = [UIImage imageNamed:@"favorite"];
        });
        [self.delegate detailViewController:self doActions:@"unfavorite"];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detail2reply"]){
        NSLog(@"go to reply page");
        ComposeViewController *cVC = segue.destinationViewController;
        cVC.user = [User currentUser];
        cVC.idToReply = self.tweet.idStr;
        if (self.tweet.retweeter == nil) {
            cVC.prefix = [NSString stringWithFormat:@"@%@ ", self.tweet.user.screenname];
        } else {
            cVC.prefix = [NSString stringWithFormat:@"@%@ %@ ", self.tweet.user.screenname, self.tweet.retweeter.screenname];
        }
        cVC.delegate = (id<ComposeViewDelegate>)self.delegate;
        
    } else if ([segue.identifier isEqualToString:@"detail2profile"]){
        ProfilePageViewController *profileController = segue.destinationViewController;
        profileController.user = self.tweet.user;
    }
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
