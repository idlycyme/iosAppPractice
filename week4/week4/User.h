//
//  User.h
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BDBOAuth1RequestOperationManager.h"

extern NSString * const UserDidLoginNotificaiton;
extern NSString * const UserDidLogoutNotificaiton;

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenname;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *idStr;
@property (nonatomic, strong) NSDictionary *rawDict;
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *bannerImageUrl;
@property (nonatomic) int tweetCount;
@property (nonatomic) int followingCount;
@property (nonatomic) int followerCount;
@property (nonatomic, strong) BDBOAuth1Credential *token;


- (id) initWithDictionary:(NSDictionary *)dictionary;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;
+ (void)logout;
+ (void)logout:(NSString *)screenname;
+ (void)addLoggedinUser:(User *)user;
+ (void)removeLoggedinUser:(NSString *)userScreenname;
+ (NSMutableDictionary *)otherLoggedinUsers;
+ (User *)getUser:(NSString*)screenname;

@end
