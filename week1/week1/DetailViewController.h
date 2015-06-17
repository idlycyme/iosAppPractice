//
//  DetailViewController.h
//  week1
//
//  Created by Yi-De Lin on 6/14/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UIView *textWrapper;
@property (weak, nonatomic) IBOutlet UIScrollView *detailScrollView;

@property (strong, nonatomic) NSDictionary *movie;
@property (weak, nonatomic) IBOutlet UIScrollView *titleScrollView;

@end
