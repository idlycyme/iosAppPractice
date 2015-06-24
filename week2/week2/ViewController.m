//
//  ViewController.m
//  week2
//
//  Created by Yi-De Lin on 6/18/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "ViewController.h"
#import "SearchResultCell.h"
#import "NSURLRequest+OAuth.h"
#import <UIImageView+AFNetworking.h>
#import "FilterController.h"
#import "DetailViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <
                              UITableViewDelegate,
                              UITableViewDataSource,
                              UISearchBarDelegate,
                              UIScrollViewDelegate,
                              FilterControllerDelegate,
                              CLLocationManagerDelegate
                             >

@end

static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kBusinessPath      = @"/v2/business/";
static NSString * const kSearchLimit       = @"20";
NSMutableDictionary *latestRequestedData;
NSString *currentOffset;
NSMutableDictionary *filterSettings;
NSString *currentSearchTerm;
CLLocationManager *locationManager;
float lontitude, latitude;
NSDictionary *thisSearchData;
UIActivityIndicatorView *spinner;

@implementation ViewController

- (void)searchWithTerm: (NSString*)term Offset:(NSString*)offset Limit:(NSString*)limit Mode:(int)mode {
    if (limit == nil || [limit isEqualToString:@""]) {
        limit = kSearchLimit;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary: @{
                             @"term": term,
                             //@"location": @"taipei",
                             @"limit": limit,
                             @"offset": offset,
                             @"ll" : [NSString stringWithFormat:@"%f, %f", latitude, lontitude]
                             }];
    
    if ([filterSettings valueForKey:@"sortBy"] != nil) {
        NSString *sortBy = [NSString stringWithFormat:@"%@", [filterSettings valueForKey:@"sortBy"]];
        [params setValue:sortBy forKey:@"sort"];
    }
    if ([filterSettings valueForKey:@"distance"] != nil) {
        NSString *distance = [NSString stringWithFormat:@"%d", [[filterSettings valueForKey:@"distance"] intValue] * 1000];
        [params setValue:distance forKey:@"radius_filter"];
    }
    if ([filterSettings valueForKey:@"deals"] != nil) {
        NSString *distance = [NSString stringWithFormat:@"%@", [filterSettings valueForKey:@"deals"]];
        [params setValue:distance forKey:@"deals_filter"];
    }
    if ([filterSettings valueForKey:@"category"] != nil) {
        NSMutableDictionary *category = [filterSettings valueForKey:@"category"];
        NSMutableArray *selected = [[NSMutableArray alloc] init];
        for (NSString *key in category) {
            BOOL isOn = [[category objectForKey:key] boolValue];
            if (isOn) {
                [selected addObject:key];
            }
        }
        [params setValue:[selected componentsJoinedByString:@","] forKey:@"category_filter"];
    }
    //NSLog(@"param is %@", params);

    NSURLRequest *req = [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *theResponseData, NSError *connectionError) {
        NSError *theError = nil;
        //__block NSDictionary *data = nil;
        if ([theResponseData length] > 0 && connectionError == nil){
            if(mode == 1){
            latestRequestedData = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:theResponseData options:kNilOptions error:&theError]];
            } else {
                NSDictionary *newData = [NSJSONSerialization JSONObjectWithData:theResponseData options:kNilOptions error:&theError];
                NSMutableArray *oriBiz = [NSMutableArray arrayWithArray:[latestRequestedData objectForKey:@"businesses"]];
                [oriBiz addObjectsFromArray:[newData objectForKey:@"businesses"]];
                [latestRequestedData setValue:oriBiz forKey:@"businesses"];
            }
           
            thisSearchData = [NSJSONSerialization JSONObjectWithData:theResponseData options:kNilOptions error:&theError];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateSearchBarText];
            [spinner stopAnimating];
            [self.searchResultTable reloadData];
        });
    }];

    if (spinner == nil) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]; [self.view addSubview:spinner];
        spinner.color = [UIColor redColor];
        [self.view addSubview:spinner];

    }
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view bringSubviewToFront:spinner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    latitude = 25.030992;
    lontitude = 121.535818;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    

    float h = self.filterButton.frame.size.height;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 220, h)];
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = NO;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.barTintColor = [UIColor blackColor];
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    self.navigationBar.leftBarButtonItem = searchBarItem;
    currentOffset = @"0";
    currentSearchTerm = @"steak";
    self.searchBar.placeholder = currentSearchTerm;
    [self searchWithTerm:currentSearchTerm Offset:currentOffset Limit:kSearchLimit Mode:1];
    self.searchResultTable.estimatedRowHeight = 91.0;
    self.searchResultTable.rowHeight = UITableViewAutomaticDimension;
    //NSLog(@"%@", latestRequestedData);
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    // automatic dimension will not take in effect if not reload
    [self.searchResultTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)filterController:(FilterController*)controller didUpdateFilters:(NSMutableDictionary *)filters {
    filterSettings = filters;
    currentOffset = @"0";
    [self searchWithTerm:currentSearchTerm Offset:currentOffset Limit:kSearchLimit Mode:1];
    //NSLog(@"now data is %@", latestRequestedData);
    //[self.searchResultTable reloadData];
}
// search related methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

// Search Bar Event Handlers
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *term = searchBar.text;
    currentOffset = @"0";
    currentSearchTerm = term;
    [self searchWithTerm:term Offset:currentOffset Limit:kSearchLimit Mode:1];
    [searchBar resignFirstResponder];
    //[self.searchResultTable reloadData];
}

-(void)updateSearchBarText {
    if ([[latestRequestedData valueForKey:@"total"] intValue] == 0) {
        self.searchBar.placeholder = @"Nothing Found!";
    } else {
        self.searchBar.placeholder = currentSearchTerm;
    }
    self.searchBar.text = @"";

}

// Table View Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[latestRequestedData objectForKey:@"businesses"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"searchResultCell";
    SearchResultCell *cell = [self.searchResultTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:cellIdentifier];
    }
    
    int lastIndex = (int)[[latestRequestedData objectForKey:@"businesses"] count];
    if (indexPath.row == lastIndex-1 && [[latestRequestedData objectForKey:@"total"] intValue] > lastIndex) {
        /*
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]; [self.view addSubview:spinner];
        spinner.center = self.view.center;
        //spinner.color = [UIColor redColor];
        [spinner startAnimating];
        [self.view addSubview:spinner];
        [self.view bringSubviewToFront:spinner];
        */
        currentOffset = [NSString stringWithFormat:@"%d", [currentOffset intValue]+[kSearchLimit intValue]];
        NSLog(@"load more %@ %d %d", currentOffset, [[latestRequestedData objectForKey:@"total"] intValue], lastIndex);
        [self searchWithTerm:currentSearchTerm Offset:currentOffset Limit:kSearchLimit Mode:0];
    }
    
    NSDictionary *currentBusiness = [[latestRequestedData objectForKey:@"businesses"] objectAtIndex:indexPath.row];
    cell.name.text = [currentBusiness objectForKey:@"name"];
    //cell.address.text = [[[currentBusiness objectForKey:@"location"] objectForKey:@"address"] objectAtIndex:0];
    if ([[currentBusiness valueForKeyPath:@"location.address"] count]) {
        cell.address.text = [[currentBusiness valueForKeyPath:@"location.address"] objectAtIndex:0];
    } else {
        cell.address.text = @"";
    }
    
    //NSArray *firstCat = [[currentBusiness objectForKey:@"categories"] objectAtIndex:0];
    NSMutableString *cats = [[NSMutableString alloc] init];
    for (NSArray *cat in [currentBusiness objectForKey:@"categories"]) {
        if (![cats isEqualToString:@""]) {
            [cats appendString:@", "];
        }
        [cats appendString:[cat objectAtIndex:0]];
    }

    cell.category.text = cats;
    
    int reviewCount = [[currentBusiness objectForKey: @"review_count"] intValue];
    cell.reviewCount.text = [NSString stringWithFormat:@"%d reviews", reviewCount];
    cell.thumbnail.image = nil;
    
    NSString *imageUrlString = [currentBusiness valueForKeyPath:@"image_url"];
    if (imageUrlString == nil) {
        imageUrlString = @"Restaurant-100";
        [cell.thumbnail setImage:[UIImage imageNamed:imageUrlString]];
    } else {
        NSURL *imgUrl = [NSURL URLWithString:imageUrlString];
        [cell.thumbnail setImageWithURL:imgUrl];
    }
    [cell.thumbnail sizeToFit];
    
    
    cell.distance.text = [NSString stringWithFormat:@"%.2f KM", [[currentBusiness valueForKey:@"distance"] floatValue]/1000];
    NSURL *ratUrl = [NSURL URLWithString:[currentBusiness valueForKeyPath:@"rating_img_url"]];
    [cell.ratingImg setImageWithURL:ratUrl];

    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"search2filter"]){
        FilterController *filterVC = segue.destinationViewController;
        filterVC.delegate = self;
        filterVC.filterSettings = filterSettings;
    } else {
        SearchResultCell *cell = (SearchResultCell*)sender;
        NSIndexPath *indexPath = [self.searchResultTable indexPathForCell:cell];
        DetailViewController *detailVC = segue.destinationViewController;
        detailVC.resturantId = [[[latestRequestedData objectForKey:@"businesses"] objectAtIndex:indexPath.row] valueForKey:@"id"];
        detailVC.countryCode = [[[latestRequestedData objectForKey:@"businesses"] objectAtIndex:indexPath.row] valueForKeyPath:@"location.country_code"];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    latitude = 25.030992;
    lontitude = 121.535818;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    latitude = newLocation.coordinate.latitude;
    lontitude = newLocation.coordinate.longitude;
}

@end
