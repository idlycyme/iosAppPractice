//
//  ViewController.h
//  week1
//
//  Created by Yi-De Lin on 6/12/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *movieListView;

@property (weak, nonatomic) IBOutlet UICollectionView *movieGridView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *viewToggle;
@property (weak, nonatomic) IBOutlet UISearchBar *movieSearchBar;
@property (weak, nonatomic) IBOutlet UITabBar *movieTabBar;
@property (weak, nonatomic) IBOutlet UITabBarItem *boxOfficeTab;
@property (weak, nonatomic) IBOutlet UITabBarItem *topRentalTab;
//@property (nonatomic,retain) UIRefreshControl *refreshControl NS_AVAILABLE_IOS(6_0);

@property (weak, nonatomic) IBOutlet UIView *handMadeStatusBar;

@end

