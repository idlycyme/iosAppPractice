//
//  FilterCell.m
//  week2
//
//  Created by Yi-De Lin on 6/21/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)distanceChanged:(id)sender {
    self.distanceLabel.text = [NSString stringWithFormat:@"%d KM", (int)self.distanceSlider.value];
    [self.delegate filterCell:self didChangeFilter:@"distance" Value:[NSNumber numberWithFloat:[self.distanceLabel.text intValue]]];
}
- (IBAction)sortByChanged:(id)sender {
    [self.delegate filterCell:self didChangeFilter:@"sortBy" Value:[NSNumber numberWithLong:self.sortBySegment.selectedSegmentIndex]];
}
- (IBAction)dealsChanged:(id)sender {
    [self.delegate filterCell:self didChangeFilter:@"deals" Value:[NSNumber numberWithBool:self.dealSwitch.isOn]];
}
- (IBAction)categoryChanged:(id)sender {
    [self.delegate filterCell:self didChangeFilter:@"category" Value:[NSNumber numberWithBool:self.categorySwitch.isOn]];
}

@end
