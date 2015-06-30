//
//  Tweet.h
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createAt;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UIImage *image;
@property int retweet_count;
@property (nonatomic, strong) NSString *idStr;
@property int favorite_count;
@property (nonatomic, strong) NSString *displayDate;
@property int retweeted;
@property int favorited;
@property (nonatomic, strong) NSString *originalRetweetIdStr;
@property (nonatomic, strong) NSDictionary *rawDict;
@property (nonatomic, strong) User *retweeter;

- (id) initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)tweetsWithArray:(NSArray *) array;

@end
