//
//  Tweet.m
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet


- (id) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSDictionary *interestedDictionary = dictionary;
        if (dictionary[@"retweeted_status"] != nil) {
            interestedDictionary = dictionary[@"retweeted_status"];
            self.retweeter = [[User alloc] initWithDictionary:dictionary[@"user"]];
        } else {
            self.retweeter = nil;
        }
        
        //NSLog(@"dict is %@", dictionary);
        self.user = [[User alloc] initWithDictionary:interestedDictionary[@"user"]];
        self.text = dictionary[@"text"];
        NSString *createdAtString = interestedDictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *languageID = [[NSBundle mainBundle] preferredLocalizations].firstObject;
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:languageID]];
        [formatter setDateFormat:@"EEE MMM d HH:mm:ss Z y"];
        self.createAt = [formatter dateFromString:createdAtString];
        self.displayDate = [self getTweetCellDisplayTimeStringSince:self.createAt];
        self.retweet_count = [interestedDictionary[@"retweet_count"] intValue];
        self.favorite_count = [interestedDictionary[@"favorite_count"] intValue];
        self.idStr = interestedDictionary[@"id_str"];
        self.retweeted = [interestedDictionary[@"retweeted"] intValue];
        self.favorited = [interestedDictionary[@"favorited"] intValue];
        self.originalRetweetIdStr = interestedDictionary[@"id_str"];
        self.rawDict = dictionary;
        //NSLog(@"=============== %@", self.originalRetweetIdStr);
    }
    return self;
}

- (NSString *) getTweetCellDisplayTimeStringSince:(NSDate*)date {
    NSString *retString = nil;
    float epoch = [[NSDate date] timeIntervalSinceDate:date];
    int hoursPassed = floor(epoch/3600);
    if (hoursPassed > 23) {
        int daysPassed = floor(hoursPassed/24);
        if (daysPassed > 100) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy/MM/dd";
            retString = [formatter stringFromDate:date];
        } else {
            retString = [NSString stringWithFormat:@"%dd", daysPassed];
        }
    } else {
        if (hoursPassed == 0) {
            retString = [NSString stringWithFormat:@"%dm", (int)floor(epoch/60)];
        } else {
            retString = [NSString stringWithFormat:@"%dh", hoursPassed];
        }
    }
    //NSLog(@"ret display string is %@", date);
    return retString;
}


+ (NSArray *)tweetsWithArray:(NSArray *) array{
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    return tweets;
}

@end
