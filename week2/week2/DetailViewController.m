//
//  DetailViewController.m
//  week2
//
//  Created by Yi-De Lin on 6/23/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "DetailViewController.h"
#import "NSURLRequest+OAuth.h"
#import <UIImageView+AFNetworking.h>
#import "ReviewCell.h"

@interface DetailViewController ()

@end

static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kBusinessPath      = @"/v2/business/";
NSDictionary *business;

@implementation DetailViewController
@synthesize resturantId;
@synthesize countryCode;

- (NSDictionary *)bussineWithId: (NSString*)rid Country:(NSString*)cc Lang:(NSString*)lang LangFilter:(BOOL)filterOn {
  
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                   @"cc": cc,
                                                                                   }];
    if (lang != nil) {
        [params setValue:lang forKey:@"lang"];
        NSString *langFilter = [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:filterOn]];
        [params setValue:langFilter forKey:@"lang_filter"];
    }
    
    //NSLog(@"param is %@ %@", params, rid);
    NSString *apiPath = [NSString stringWithFormat:@"%@%@", kBusinessPath, rid];
    NSURLRequest *req = [NSURLRequest requestWithHost:kAPIHost path:apiPath params:params];
    NSURLResponse * response = nil;
    NSError *theError = nil;
    NSData *theResponseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&theError];
    if (theResponseData != nil) {
        return [NSJSONSerialization JSONObjectWithData:theResponseData options:kNilOptions error:&theError];
    } else {
        return [[NSDictionary alloc] init];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Dispose of any resources that can be recreated.
    business = [self bussineWithId:self.resturantId Country:self.countryCode Lang:nil LangFilter:NO];
    //NSLog(@"%@", business);
    NSString *name = [business valueForKeyPath:@"name"];
    NSString *ratingUrl = [business valueForKeyPath:@"rating_img_url"];
    NSString *displayAddress = [[business valueForKeyPath:@"location.display_address"] componentsJoinedByString:@" "];
    NSString *displayPhone = [business valueForKeyPath:@"display_phone"];
    NSString *imageUrl = [business valueForKeyPath:@"image_url"];
    if (imageUrl == nil) {
        imageUrl = @"Restaurant-100";
        [self.image setImage:[UIImage imageNamed:imageUrl]];
    } else {
        [self.image setImageWithURL:[NSURL URLWithString:imageUrl]];
        self.image.layer.cornerRadius = 5;
        self.image.clipsToBounds = YES;
    }
    //NSString *desc = [business valueForKeyPath:@"snippet_text"];
    int reviewCount = [[business valueForKeyPath:@"review_count"] intValue];
    NSMutableString *categories = [[NSMutableString alloc] init];
    for (NSArray *cat in [business objectForKey:@"categories"]) {
        if (![categories isEqualToString:@""]) {
            [categories appendString:@", "];
        }
        [categories appendString:[cat objectAtIndex:0]];
    }
    self.name.text = name;
    self.address.text = displayAddress;
    self.phone.text = displayPhone;
    self.categories.text = categories;
    //self.desc.text = desc;
    self.reviewCount.text = [NSString stringWithFormat:@"%d reviews", reviewCount];
    
    [self.ratingImage setImageWithURL:[NSURL URLWithString:ratingUrl]];
    
    double X = [[business valueForKeyPath:@"location.coordinate.latitude"] floatValue];
    double Y = [[business valueForKeyPath:@"location.coordinate.longitude"] floatValue];
    [self initMapWithX:X Y:Y Title:name];
    self.reviewTable.estimatedRowHeight = 60.0;
    self.reviewTable.rowHeight = UITableViewAutomaticDimension;
}

- (void)initMapWithX:(double)X Y:(double)Y Title:(NSString*)title{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = X;
    location.longitude = Y;
    region.span = span;
    region.center = location;
    [self.map setRegion:region animated:YES];
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = location;
    pa.title = title;
    [self.map addAnnotation:pa];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
// Table View Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[business valueForKey:@"reviews"] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"reviewCell";
    ReviewCell *cell = [self.reviewTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ReviewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier];
    }
    NSArray *reviews = [business valueForKey:@"reviews"];
    NSDictionary *review = [reviews objectAtIndex:indexPath.row];
    cell.name.text = [review valueForKeyPath:@"user.name"];
    cell.comment.text = [review valueForKeyPath:@"excerpt"];
    [cell.ratingImage setImageWithURL:[NSURL URLWithString:[review valueForKeyPath:@"rating_image_url"]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)toggleChanged:(id)sender {
    BOOL showMap = NO;
    if (self.reviewMapToggle.selectedSegmentIndex == 1) {
        showMap = YES;
    }
    self.reviewTable.hidden = showMap;
    self.map.hidden = !showMap;
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
