//
//  movieGridCell.h
//  week1
//
//  Created by Yi-De Lin on 6/14/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface movieGridCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
