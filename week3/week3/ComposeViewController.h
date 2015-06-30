//
//  ComposeViewController.h
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class ComposeViewController;
@protocol ComposeViewDelegate <NSObject>
@required
- (void)composer:(ComposeViewController *) controller DidComposeWithText:(NSString *)text ReplyToId:(NSString *)id;

@end


@interface ComposeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userScreenname;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *wordsLeft;

@property (nonatomic, weak) User *user;
@property (nonatomic, weak) NSString *idToReply;
@property (nonatomic, weak) NSString *prefix;
@property (nonatomic, weak) id<ComposeViewDelegate> delegate;

@end
