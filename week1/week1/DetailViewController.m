//
//  DetailViewController.m
//  week1
//
//  Created by Yi-De Lin on 6/14/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "DetailViewController.h"
#import <UIImageView+AFNetworking.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize movie;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.movieTitle.text = [movie objectForKey:@"title"];
    self.desc.text = [movie objectForKey:@"synopsis"];
    [self.desc sizeToFit];
    [self.detailScrollView setContentSize:self.desc.frame.size];
    
    NSString *lowResUrlString = [self convertPosterUrlStringToHeighRes:[movie valueForKeyPath:@"posters.detailed"] Type:@"det"];
    lowResUrlString = [movie valueForKeyPath:@"posters.detailed"];
    NSURL *imgUrl = [NSURL URLWithString:lowResUrlString];
    [self.image setImageWithURL:imgUrl];
    
    NSString *highResUrlString = [self convertPosterUrlStringToHeighRes:[movie valueForKeyPath:@"posters.detailed"] Type:nil];
    [self.image setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:highResUrlString]] placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest *request,   NSHTTPURLResponse *response, UIImage *image) {
        self.image.alpha = 0.9;
        self.image.image = image;
        // fade in effect
        [UIView beginAnimations:@"fadeIn" context:nil];
        [UIView setAnimationDuration:5.0];
        self.image.alpha = 1.0;
        [UIView commitAnimations];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        // network error
        NSLog(@"Error: %@", error);
    }];
    

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(showTextWrapperOrNot)];
    [self.view addGestureRecognizer:tap];
    
}


- (NSString *)convertPosterUrlStringToHeighRes: (NSString*)urlString Type:(NSString *)type {
    NSRange range = [urlString rangeOfString:@".*cloudfront.net/" options:NSRegularExpressionSearch];
    NSString *retValue = urlString;
    if (range.length > 0) {
        retValue = [urlString stringByReplacingCharactersInRange:range withString:@"https://content5.flixster.com/"];
    }
    
    //NSLog(@"ori is %@", retValue);
    if (type != nil && ![type isEqualToString:@"ori"]) {
        NSRange range2 = [retValue rangeOfString:@"ori" options:NSRegularExpressionSearch];
        if (range.length > 0) {
            retValue = [retValue stringByReplacingCharactersInRange:range2 withString:type];
        }
    }
    return retValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showTextWrapperOrNot{
    self.textWrapper.hidden = !self.textWrapper.hidden;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
