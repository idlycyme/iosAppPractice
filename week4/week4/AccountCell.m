//
//  AccountCell.m
//  week4
//
//  Created by Yi-De Lin on 7/12/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "AccountCell.h"

@implementation AccountCell
CGPoint startLocation;

- (void)awakeFromNib {
    // Initialization code
}

- (void)addPanGesture {
    UIPanGestureRecognizer *panOnAccountCell =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDeleteCell:)];
    [self addGestureRecognizer:panOnAccountCell];
}

- (IBAction)onDeleteCell:(UIPanGestureRecognizer *)sender {
    CGRect cFrame = self.normalFrame;
    self.normalFrame = CGRectMake(cFrame.origin.x, self.frame.origin.y, cFrame.size.width, self.frame.size.height);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        startLocation = [sender locationInView:self];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint stopLocation = [sender locationInView:self];
        CGFloat dx = stopLocation.x - startLocation.x;
        if (dx >= -20) {
            return;
        }
        [UIView animateWithDuration:0.2 animations:^{
        CGRect cFrame = self.normalFrame;
        self.frame = CGRectMake(cFrame.origin.x + dx, self.frame.origin.y, cFrame.size.width, self.frame.size.height);
        self.backgroundColor = [UIColor greenColor];
        self.alpha = 0.5 - dx/self.frame.size.width;
        //NSLog(@"Distance: %f %f %f", self.alpha, dx, cFrame.size.width);
        }];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint stopLocation = [sender locationInView:self];
        CGFloat dx = startLocation.x - stopLocation.x;
        if (dx > 0 && (dx > 70)) {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect cFrame = self.normalFrame;
                self.frame = CGRectMake(-cFrame.size.width, self.frame.origin.y, cFrame.size.width, self.frame.size.height);
                self.backgroundColor = nil;
                self.alpha = 1;
            }];
            [self onLogout:nil];
        } else {
            self.frame = self.normalFrame;
            self.backgroundColor = nil;
            self.alpha = 1;
        }
        //NSLog(@"Distance: %f", distance);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)onLogout:(id)sender {
    NSLog(@"user logout");
    [self.delegate cell:self userLogout:[self.screenname.text substringFromIndex:1]];
}


@end
