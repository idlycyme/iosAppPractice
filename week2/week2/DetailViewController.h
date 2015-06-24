//
//  DetailViewController.h
//  week2
//
//  Created by Yi-De Lin on 6/23/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController <MKMapViewDelegate,
                                                    UITableViewDataSource,
                                                    UITableViewDelegate
                                                   >
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) NSString *resturantId;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UISegmentedControl *reviewMapToggle;
//@property (weak, nonatomic) IBOutlet UILabel *desc;
//@property (weak, nonatomic) IBOutlet UIScrollView *descScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *reviewCount;
@property (weak, nonatomic) IBOutlet UILabel *categories;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UITableView *reviewTable;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) NSString *countryCode;
@end
