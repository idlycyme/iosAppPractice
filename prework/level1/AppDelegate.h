//
//  AppDelegate.h
//  level1
//
//  Created by Yi-De Lin on 6/4/15.
//  Copyright (c) 2015 Yi-De Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property int defaultPercent;
@property (weak, nonatomic) NSString *selectedLocale;
@property int cacheExipration;
@property NSString* currentAmountText;

-(int) validIntRange: (UITextField *)label min:(int)min max:(int)max;

@end

