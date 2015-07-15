//
//  ProfilePageViewController.h
//  week4
//
//  Created by Yi-De Lin on 7/3/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuProtocol.h"
#import "User.h"
#import "TweetsViewController.h"

@interface ProfilePageViewController : UIViewController

@property (weak, nonatomic) id<showSideMenuDelegate> delegate;
@property (strong, nonatomic) UIImageView *profileImage;
@property (strong, nonatomic) TweetsViewController *profileTweetsPage;

@property (weak, nonatomic) User *user;

@end
