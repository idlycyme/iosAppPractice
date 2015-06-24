//
//  FilterController.h
//  week2
//
//  Created by Yi-De Lin on 6/21/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterController;

@protocol FilterControllerDelegate <NSObject>
@required
-(void)filterController:(FilterController*)controller didUpdateFilters:(NSMutableDictionary *)filters;
@end

@interface FilterController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *filterTable;
@property (weak, nonatomic) id<FilterControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *filterSettings;

@end
