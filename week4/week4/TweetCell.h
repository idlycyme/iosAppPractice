//
//  TweetCell.h
//  week3
//
//  Created by Yi-De Lin on 6/28/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;
@protocol TweetCellDelegate <NSObject>
@required
- (void) tweetCell:(TweetCell *)cell didRetweetedWithId:(NSString *)id;
- (void) tweetCell:(TweetCell *)cell didReplyWithId:(NSString *)id;
- (void) tweetCell:(TweetCell *)cell didFavoriteWithId:(NSString *)id;
- (void) tweetCell:(TweetCell *)cell didUnfavoriteWithId:(NSString *)id;
- (void) tweetCell:(TweetCell *)cell didUnretweetedWithId:(NSString *)id;
@end

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userScreenname;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UILabel *createdAtByHour;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByWho;
@property (weak, nonatomic) IBOutlet UIImageView *retweetImage;
@property (weak, nonatomic) id<TweetCellDelegate>delegate;
@property (weak, nonatomic) Tweet *tweet;

@end
