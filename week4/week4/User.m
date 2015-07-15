//
//  User.m
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotificaiton = @"UserDidLoginNotificaiton";
NSString * const UserDidLogoutNotificaiton = @"UserDidLogoutNotificaiton";

@interface User()

@end

@implementation User
@synthesize description;

- (id) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        self.name = dictionary[@"name"];
        self.screenname = dictionary[@"screen_name"];
        self.profileImageUrl = dictionary[@"profile_image_url"];
        self.description = dictionary[@"description"];
        self.idStr = dictionary[@"id_str"];
        self.tweetCount = [dictionary[@"statuses_count"] intValue];
        self.followerCount = [dictionary[@"followers_count"] intValue];
        self.followingCount = [dictionary[@"friends_count"] intValue];
        self.bannerImageUrl = dictionary[@"profile_banner_url"];
        if (dictionary[@"_token"]) {
            BDBOAuth1Credential *token = [BDBOAuth1Credential credentialWithToken:dictionary[@"_token"] secret:dictionary[@"_secret"] expiration:nil];
            self.token = token;
        }
        //NSLog(@"%@", dictionary);
    }
    return self;
}

static User *_currentUser = nil;
static NSMutableDictionary *_loggedinUsers = nil;

NSString * const kCurrentUserKey = @"kCurrentUserKey";
NSString * const kOtherLoggedinUsersNameKey = @"kLogginedUserNamekey";
NSString * const kOtherLoggedinUsersDataKey = @"kLogginedUserDatakey";

+ (User *)currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    
    return  _currentUser;
}

+ (NSMutableDictionary *)otherLoggedinUsers {
    if (_loggedinUsers == nil) {
        NSArray *keys = [[NSUserDefaults standardUserDefaults] objectForKey:kOtherLoggedinUsersNameKey];
        if (keys != nil) {
            //NSArray *keys = [NSJSONSerialization JSONObjectWithData:dataK options:0 error:NULL];
            NSData *dataV = [[NSUserDefaults standardUserDefaults] objectForKey:kOtherLoggedinUsersDataKey];
            if (dataV != nil) {
                NSArray *rawVals = [NSJSONSerialization JSONObjectWithData:dataV options:0 error:NULL];
                NSMutableArray *vals = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in rawVals) {
                    User *u = [[User alloc] initWithDictionary:dict];
                    NSLog(@"in %@", u.screenname);
                    [vals addObject:[[User alloc] initWithDictionary:dict]];
                }
                _loggedinUsers = [NSMutableDictionary dictionaryWithObjects:vals forKeys:keys];
            }

        }
    }
    
    return _loggedinUsers;
}

+ (User *)getUser:(NSString*)screenname{
    if (_currentUser != nil && [_currentUser.screenname isEqualToString:screenname]) {
        return  _currentUser;
    }
    if ([self otherLoggedinUsers]) {
        User *user = [_loggedinUsers objectForKey:screenname];
        if (user != nil) {
            return user;
        }
    }
    return nil;
}


+ (void)setCurrentUser:(User *)currentUser{
    _currentUser = currentUser;
    if (_currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:NULL];
        [TwitterClient setSharedInstanceAccessToken:_currentUser.token];
        [self removeLoggedinUser:currentUser.screenname];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)addLoggedinUser:(User *)user{
    if (_loggedinUsers == nil) {
        _loggedinUsers = [[NSMutableDictionary alloc] init];
    }
    [_loggedinUsers setObject:user forKey:user.screenname];
    NSLog(@"save logged %@", [_loggedinUsers allKeys]);
    
    [self syncLoggedUserData];
}

+ (void)syncLoggedUserData {
    NSArray *keys = [_loggedinUsers allKeys];
    NSArray *rawVals = [_loggedinUsers allValues];
    NSMutableArray *vals = [[NSMutableArray alloc] init];
    for (User *user in rawVals) {
        //NSData *val = [NSJSONSerialization dataWithJSONObject:user.dictionary options:0 error:NULL];
        [vals addObject:user.dictionary];
    }
    //NSData *dataK = [NSJSONSerialization dataWithJSONObject:keys options:0 error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:keys forKey:kOtherLoggedinUsersNameKey];
    NSData *dataV = [NSJSONSerialization dataWithJSONObject:vals options:0 error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:dataV forKey:kOtherLoggedinUsersDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeLoggedinUser:(NSString *)userScreenname{
    if (_loggedinUsers != nil) {
        [_loggedinUsers removeObjectForKey:userScreenname];
        [self syncLoggedUserData];
    }
}

+ (void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotificaiton object:nil];
}

+ (void)logout:(NSString *)screenname {
    NSLog(@"aaaaa %@ %@", _currentUser.screenname, screenname);
    if ([screenname isEqualToString:_currentUser.screenname]) {
        [self logout];
    } else {
        [self removeLoggedinUser:screenname];
    }
    
}

@end
