//
//  FilterCell.h
//  week2
//
//  Created by Yi-De Lin on 6/21/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilterCell;
@protocol FilterCellDelegate <NSObject>
-(void)filterCell:(FilterCell*)cell didChangeFilter:(NSString*)key Value:(NSObject*)value;
@end

@interface FilterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *dealSwitch;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UISwitch *categorySwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortBySegment;
@property (weak, nonatomic) id<FilterCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *checkStatusImage;
@property (weak, nonatomic) IBOutlet UILabel *predefinedRadiusLabel;

@end
