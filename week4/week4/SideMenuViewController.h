//
//  SideMenuViewController.h
//  week4
//
//  Created by Yi-De Lin on 7/3/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuProtocol.h"

@interface SideMenuViewController : UIViewController

@property (weak, nonatomic) id<showSideMenuDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *menuTable;
@property (strong, nonatomic) IBOutlet UIView *menuView;


@end
