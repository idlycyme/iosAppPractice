//
//  movieListCell.h
//  week1
//
//  Created by Yi-De Lin on 6/12/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface movieListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;

@end
