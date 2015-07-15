//
//  showSideMenu.h
//  week4
//
//  Created by Yi-De Lin on 7/3/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#ifndef week4_showSideMenu_h
#define week4_showSideMenu_h
#import <UIKit/UIKit.h>

@class UIViewController;
@protocol showSideMenuDelegate <NSObject>
@required
- (void)controller:(UIViewController *) controller DidPressMenuButton:(id)button;
- (void)didHideMenuController:(UIViewController *) controller;
- (void)controller:(UIViewController *) contorller DidSelectItem:(NSString *)action Data:(id)data;

@end

#endif
