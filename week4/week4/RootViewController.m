//
//  RootViewController.m
//  week4
//
//  Created by Yi-De Lin on 7/3/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "RootViewController.h"
#import "ProfilePageViewController.h"
#import "SideMenuViewController.h"
#import "SideMenuProtocol.h"
#import "TweetsViewController.h"
#import "User.h"
#import "TwitterClient.h"

@interface RootViewController () <showSideMenuDelegate>

@end
CGRect showMenu, hideHome, hideMenu, showHome, hideNav, showNav;
int menuToggle = 0;
ProfilePageViewController *profilePage;
SideMenuViewController *sideMenu;
UINavigationController *tweetsNavigator;
UINavigationController *profileNavigator;
UIViewController *currentMainView;
TweetsViewController *tweetsPage;

@implementation RootViewController

- (void)controller:(UIViewController *) contorller DidSelectItem:(NSString *)action Data:(id)data {
    CGRect cFrame = currentMainView.view.frame;
    if ([action isEqualToString:@"Profile"]) {
        User *user = (User *)data;
        if (profilePage.user != user) {
            NSLog(@"reload user %@", user.name);
            profileNavigator = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationProfile"];
            profilePage = (ProfilePageViewController *)profileNavigator.topViewController;
            profilePage.delegate = self;
            profilePage.user = user;
        }
        currentMainView = profileNavigator;
    } else if ([action isEqualToString:@"Home"] || [action isEqualToString:@"Mentions"]) {
        currentMainView = tweetsNavigator;
        if (![tweetsPage.currentTimelineType isEqualToString:action]) {
            tweetsPage.currentTimelineType = action;
            NSLog(@"reload --- %@", action);
            [tweetsPage onRefresh];
            [tweetsPage.homelineTable reloadData];
        }
    } else if ([action isEqualToString:@"Account"]) {
        NSString *switchedUserScreenname = (NSString *)data;
        //User *currentUser = [User currentUser];
        if (switchedUserScreenname != nil) {
            /* init here, todo */
            currentMainView = tweetsNavigator;
            tweetsPage.currentTimelineType = @"Home";
            
            [tweetsPage onRefresh];
            [tweetsPage.homelineTable reloadData];
        }
    } else if ([action isEqualToString:@"addAccount"]) {
        [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
            if (error == nil) {
                if (user != nil) {
                    NSLog(@"!Welcome to %@", user.name);
                    tweetsPage.currentTimelineType = @"Home";
                    [tweetsPage onRefresh];
                    [tweetsPage.homelineTable reloadData];
                    [sideMenu.menuTable reloadData];
                } else {
                    NSLog(@"[ERROR] No user data");
                }
            } else {
                NSLog(@"[ERROR] Failed to login");
            }
        }];
    } else {
        NSLog(@"[ERROR] Unkonw action %@ with data %@", action, data);
        return;
    }
    
    currentMainView.view.frame = cFrame;
    [self presentViews];
    if (!menuToggle) {
        [self sideMenuToggle];
    }
}

- (void)controller:(UIViewController *) controller DidPressMenuButton:(id)button {
    NSLog(@"get button pressed");
    [self sideMenuToggle];
}

- (void)didHideMenuController:(UIViewController *) controller {
    //NSLog(@"get hide");
    [self sideMenuToggle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //profilePage = [self.storyboard instantiateViewControllerWithIdentifier:@"profileView"];

    
    sideMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"sideMenu"];
    tweetsNavigator = [self.storyboard instantiateViewControllerWithIdentifier:@"navigation"];
    tweetsPage = (TweetsViewController *)tweetsNavigator.topViewController;
    

    sideMenu.delegate = self;
    tweetsPage.delegate = self;
    tweetsPage.currentTimelineType = @"Home";
    tweetsPage.enableOnRefresh = YES;
    currentMainView = tweetsNavigator;
    menuToggle = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [self presentViews];
}

- (void)presentViews {
    [self.view addSubview:sideMenu.view];
    [self.view addSubview:currentMainView.view];
}

- (void)viewDidAppear:(BOOL)animated {
    /* side menu rect definition */
    float wh = self.view.window.frame.size.height;
    float ww = self.view.window.frame.size.width;
    float sw = 50; //part for unhidden home table
    //float sh = [UIApplication sharedApplication].statusBarFrame.size.height;
    // case 1: show menu and hide home
    showMenu = CGRectMake(0, 0, ww-sw, wh);
    hideHome = CGRectMake(ww-sw, 0, ww, wh);
    // case 2: hide menu and show home, default
    hideMenu = CGRectMake(0, 0, ww-sw, wh);
    showHome = CGRectMake(0, 0, ww, wh);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sideMenuToggle {
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"menu toggle %d", menuToggle);
        if (menuToggle) {
            //NSLog(@"hideHome");
            currentMainView.view.frame = hideHome;
            sideMenu.menuView.frame = showMenu;
        } else {
            //NSLog(@"showHome");
            currentMainView.view.frame = showHome;
            sideMenu.menuView.frame = hideMenu;
        }
    }];
    menuToggle = !menuToggle;
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
