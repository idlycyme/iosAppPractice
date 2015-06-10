//
//  settingTableViewController.h
//  prework
//
//  Created by Yi-De Lin on 6/8/15.
//  Copyright (c) 2015 Yi-De Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *defaultPercentageTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *regionPicker;
@property (weak, nonatomic) IBOutlet UILabel *sampleCurrencyLabel;
@property (weak, nonatomic) IBOutlet UITextField *defaultCacheExpiration;

@end
