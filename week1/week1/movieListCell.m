//
//  movieListCell.m
//  week1
//
//  Created by Yi-De Lin on 6/12/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "movieListCell.h"

@implementation movieListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *color = [UIColor blackColor];
    if (highlighted) {
        color = [UIColor redColor];
    }
    self.title.textColor = color;
    self.desc.textColor = color;
}
@end
