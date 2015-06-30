//
//  TweetCell.m
//  week3
//
//  Created by Yi-De Lin on 6/28/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    self.userProfileImage.layer.cornerRadius = 5;
    self.userProfileImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onFavorite:(id)sender {
    NSLog(@"cell favorite");
    if (self.tweet.favorited == 0) {
        [self.delegate tweetCell:self didFavoriteWithId:self.tweet.idStr];
    } else {
        [self.delegate tweetCell:self didUnfavoriteWithId:self.tweet.idStr];
    }
}
- (IBAction)onRetweet:(id)sender {
    if (self.tweet.retweeted == 0) {
        NSLog(@"cell onRetweet");
        [self.delegate tweetCell:self didRetweetedWithId:self.tweet.idStr];
    } else {
        NSLog(@"cell unretweet");
        NSString *tweetId = self.tweet.idStr;
        if (self.tweet.originalRetweetIdStr != nil) {
            tweetId = self.tweet.originalRetweetIdStr;
        }
        //NSLog(@"%@", tweetId);
        [self.delegate tweetCell:self didUnretweetedWithId:tweetId];
    }
}
- (IBAction)onReply:(id)sender {
    NSLog(@"dell reply");
    [self.delegate tweetCell:self didReplyWithId:self.tweet.idStr];
}

@end
