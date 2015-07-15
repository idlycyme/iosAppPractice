//
//  AccountCell.h
//  week4
//
//  Created by Yi-De Lin on 7/12/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountCell;
@protocol accountCellDelegate <NSObject>
@required
- (void)cell:(AccountCell *)cell userLogout:(NSString *)userScreenname;
@end

@interface AccountCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) id<accountCellDelegate> delegate;
@property (nonatomic) CGRect normalFrame;

- (void)addPanGesture;

@end
