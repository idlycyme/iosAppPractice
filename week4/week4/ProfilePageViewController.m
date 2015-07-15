//
//  ProfilePageViewController.m
//  week4
//
//  Created by Yi-De Lin on 7/3/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "ProfilePageViewController.h"
#import <UIImageView+AFNetworking.h>
#import "TweetsViewController.h"
#import "TweetDetailViewController.h"

@interface ProfilePageViewController () <tweetViewDelegate>

@end

int bannerHeightExpand;
CGRect oriTableFrame;
CGRect oriBarFrame;
CGRect withBannerFrame;
NSString *oriBarBackTitle;
UINavigationController *tweetNavigator;
UIImage *bannerImage;
UIVisualEffectView *blurEffectView;

@implementation ProfilePageViewController

@synthesize user;

- (void)controller:(TweetsViewController *)controller presentDetailWithTweet:(Tweet*)tweet {
    NSLog(@"delegate profile2detail");
    [self performSegueWithIdentifier:@"profile2detail" sender:tweet];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    bannerHeightExpand = 60;
    oriBarFrame = self.navigationController.navigationBar.frame;
    withBannerFrame = CGRectMake(oriBarFrame.origin.x, oriBarFrame.origin.y
                                        , oriBarFrame.size.width, bannerHeightExpand);

    tweetNavigator = [self.storyboard instantiateViewControllerWithIdentifier:@"navigation"];
    self.profileTweetsPage = (TweetsViewController *)tweetNavigator.topViewController;
    //self.profileTweetsPage = [self.storyboard instantiateViewControllerWithIdentifier:@"HomelineView"];
    self.profileTweetsPage.delegate = self.delegate;
    self.profileTweetsPage.withHeaderCell = YES;
    self.profileTweetsPage.headerCellId = @"ProfileCell";
    self.profileTweetsPage.headerUser = self.user;
    self.profileTweetsPage.currentTimelineType = @"Home";
    self.profileTweetsPage.enableOnRefresh = NO;
    self.profileTweetsPage.tweetViewDelegator = self;
    self.profileTweetsPage.view.frame = CGRectMake(0, withBannerFrame.size.height + withBannerFrame.origin.y, self.view.frame.size.width, self.view.frame.size.height - withBannerFrame.origin.y - withBannerFrame.size.height);
    [self.view addSubview:self.profileTweetsPage.view];
    //[self.view addSubview:tweetNavigator.view];
    bannerImage = nil;
    //CGRect oriLeftBarItemFrame = self.navigationController.navigationItem.leftBarButtonItem.;
    NSArray *items = self.navigationController.navigationBar.items;
    UINavigationItem *backItem = items[0];
    oriBarBackTitle = backItem.title;
    backItem.title = @"";

    /*
    UIBarButtonItem *bitem =backItem.leftBarButtonItems.lastObject;
    NSLog(@"1212     %@", bitem.customView.frame);
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"Home"];
    UIImage *backBtnImagePressed = [UIImage imageNamed:@"btn-back-pressed"];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn setBackgroundImage:backBtnImagePressed forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    backBtn.frame = CGRectMake(0, 0, 63, 33);
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 63, 33)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 0, 20);
    [backButtonView addSubview:backBtn];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = backButton;
     */

}

- (void)viewWillAppear:(BOOL)animated {
    /* put it here or it will not show in view did load */
    [self setBannerImage];
    [self.view bringSubviewToFront:self.profileTweetsPage.view];
    //[self.view bringSubviewToFront:tweetNavigator.view];
    oriTableFrame = self.profileTweetsPage.view.frame;
    //oriTableFrame = CGRectMake(self.profileTweetsPage.view.frame.origin.x,
    //                    self.navigationController.navigationBar.frame.size.height,
//self.profileTweetsPage.view.frame.size.width,
    //                                        self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    //self.profileTweetsPage.view.frame = oriTableFrame;
}

- (void)setBannerImage {
    if (bannerImage == nil && self.user.bannerImageUrl) {
        NSURL *url = [NSURL URLWithString:self.user.bannerImageUrl];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"GET"];
        [req addValue:@"image" forHTTPHeaderField:@"Content-type"];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *theResponseData, NSError *connectionError) {
            if ([theResponseData length] > 0 && connectionError == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    bannerImage = [UIImage imageWithData:theResponseData];
                    [self.navigationController.navigationBar setBackgroundImage:bannerImage forBarMetrics:UIBarMetricsDefault];
                    self.navigationController.navigationBar.frame = withBannerFrame;
                    //[self showProfileImage];
                    //[self.view addSubview:self.profileImage];
                    //[self.view bringSubviewToFront:self.profileImage];
                    
                });
            }
        }];
    } else if (bannerImage) {
        [self.navigationController.navigationBar setBackgroundImage:bannerImage forBarMetrics:UIBarMetricsDefault];
        //self.navigationController.navigationBar.frame = withBannerFrame;
        //[self showProfileImage];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.navigationBar.frame = withBannerFrame;
    });

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];
    [self restoreNavBarAppearance];
    //NSLog(@"view did disappear");
}

- (void)restoreNavBarAppearance {
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.frame = oriBarFrame;
    NSArray *items = self.navigationController.navigationBar.items;
    UINavigationItem *backItem = items[0];
    backItem.title = oriBarBackTitle;
    self.profileImage.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onMenu:(id)sender {
    //[self restoreNavBarAppearance];
    [self.delegate controller:self DidPressMenuButton:sender];
}

- (void)controller:(TweetsViewController *)controller scroll:(UIScrollView *)scrollView {
    //NSLog(@"===== %d %f", (int)[[controller.homelineTable indexPathsForVisibleRows] count], scrollView.contentOffset.y);
    CGRect initFrame = oriBarFrame;
    /*if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]) {
        initFrame = withBannerFrame;
    } else {
        return;
    }*/
    
    int animateHeight = initFrame.size.height - scrollView.contentOffset.y;
    CGRect animateFrame = CGRectMake(initFrame.origin.x, initFrame.origin.y, initFrame.size.width, animateHeight);
    CGRect tableFrame = CGRectMake(animateFrame.origin.x,
                                   animateFrame.origin.y+animateFrame.size.height,
                                   animateFrame.size.width,
                                   self.view.frame.size.height - animateFrame.size.height);
    
    if (scrollView.contentOffset.y < 0) {


        float opacity;
        long seg = (long)scrollView.contentOffset.y;
        seg = seg % 20;
        if (seg) {
            opacity = scrollView.contentOffset.y / -200;
        } else {
            opacity = blurEffectView.alpha;
        }
        [self blurrNavBarImageWithHeight:animateHeight opacity:opacity];
        self.navigationController.navigationBar.frame = animateFrame;
        
        self.profileTweetsPage.view.frame = oriTableFrame;
        
    } else if (scrollView.contentOffset.y > 0  && self.navigationController.navigationBar.frame.size.height > oriBarFrame.size.height) {
        //self.navigationController.navigationBar.alpha = 0.5;
        if (animateFrame.size.height < oriBarFrame.size.height) {
            animateFrame = CGRectMake(animateFrame.origin.x, animateFrame.origin.y, animateFrame.size.width, oriBarFrame.size.height);
        }
        self.navigationController.navigationBar.frame = animateFrame;
        self.profileTweetsPage.view.frame = tableFrame;
    }
    if (self.navigationController.navigationBar.frame.size.height == initFrame.size.height) {
        [self blurrNavBarImageWithHeight:0 opacity:0];
    }
    
}

- (void)blurrNavBarImageWithHeight:(int)height opacity:(float)opacity {
    UINavigationBar *view = self.navigationController.navigationBar;
    if ([view backgroundImageForBarMetrics:UIBarMetricsDefault] == nil) {
      //  return;
    }
    //view.backgroundColor = [UIColor clearColor];
    if (blurEffectView == nil) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [view addSubview:blurEffectView];
    }
    //NSLog(@"opacity %f %d", opacity, height);
    
    //self.navigationController.navigationBar.opaque = opacity;
    if (!height) {
        [blurEffectView removeFromSuperview];
        blurEffectView = nil;
    } else {
        int sh = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGRect frame = CGRectMake(0, -sh, view.frame.size.width, height+sh);
        blurEffectView.frame = frame;
        blurEffectView.alpha = opacity;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"profile2detail"]){
        Tweet *tweet = (Tweet *)sender;
        TweetDetailViewController *dVC = segue.destinationViewController;
        dVC.tweet = tweet;
        dVC.delegate = (id<TweetDetailViewDelegate>)self.profileTweetsPage;
    }
}


@end
