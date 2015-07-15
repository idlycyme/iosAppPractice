//
//  TweetsViewController.h
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuProtocol.h"
#import "User.h"
#import "Tweet.h"

@class TweetsViewController;
@protocol tweetViewDelegate <NSObject>
@required
- (void)controller:(TweetsViewController *)controller presentDetailWithTweet:(Tweet*)tweet;
- (void)controller:(TweetsViewController *)controller scroll:(UIScrollView *)scrollView;
@end

@interface TweetsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *homelineTable;
@property (weak, nonatomic) id<showSideMenuDelegate> delegate;
@property (weak, nonatomic) id<tweetViewDelegate> tweetViewDelegator;
@property (strong, nonatomic) NSString *currentTimelineType;
@property (nonatomic) BOOL enableOnRefresh;
@property (nonatomic) BOOL withHeaderCell;
@property (nonatomic, weak) NSString *headerCellId;
@property (nonatomic, strong) User *headerUser;

- (void)onRefresh;

@end
