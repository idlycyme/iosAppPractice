//
//  SearchResultCell.m
//  week2
//
//  Created by Yi-De Lin on 6/21/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "SearchResultCell.h"

@implementation SearchResultCell

- (void)awakeFromNib {
    // Initialization code
    self.thumbnail.layer.cornerRadius = 5;
    self.thumbnail.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
