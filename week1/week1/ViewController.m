//
//  ViewController.m
//  week1
//
//  Created by Yi-De Lin on 6/12/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "movieListCell.h"
#import "movieGridCell.h"
#import <UIImageView+AFNetworking.h>
#import "DetailViewController.h"
#import <SVProgressHUD.h>
@interface ViewController () <
                              UITableViewDataSource, UITableViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegate,
                              UIScrollViewDelegate,
                              UISearchBarDelegate,
                              UITabBarDelegate,
                              UICollectionViewDelegateFlowLayout
                             >
@end

AppDelegate *appDelegate;
BOOL presentListView;
NSArray *boxOfficeMovies;
NSArray *topRentalDVDs;
NSMutableArray *presentData;
NSDictionary *latestRequestedData;
UITabBarItem *selectedItem;
UIRefreshControl *refreshControl;
//static NSString *apiKey = put your key here;
static NSString *apiKey = put your key here;
static NSDictionary *apiDict;
BOOL dataComesBack;

@implementation ViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    apiDict = [NSDictionary dictionaryWithObjectsAndKeys:
               @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json", @"boxOfficeMovies",
               @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json", @"topRentalDVDs",
               nil];
}

- (void)getDataFromAPIAsync:(NSString*)api withQuery:(NSString*)q {
    NSString *requestString = [NSString stringWithFormat:
                               @"%@?limit=50&apiKey=%@", [apiDict objectForKey:api], apiKey];
    
    //NSLog(@"%@", requestString);
    NSURL *url = [NSURL URLWithString:requestString];
    self.handMadeStatusBar.hidden = YES;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"GET"];
    
    [req addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    dataComesBack = NO;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //NSDictionary *data = nil;
    //NSData *theResponseData;
    //NSData *theResponseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&theResponse error:&theError];
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *theResponseData, NSError *connectionError) {
        NSError *theError = nil;
        //__block NSDictionary *data = nil;
        if ([theResponseData length] > 0 && connectionError == nil){
            latestRequestedData = [NSJSONSerialization JSONObjectWithData:theResponseData options:kNilOptions error:&theError];
            //NSLog(@"data comes back");
            NSArray *data = [self loadDataAccordingToSeletedBarItem:NO];
            presentData = [NSMutableArray arrayWithArray:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.handMadeStatusBar.hidden = YES;
                if (!refreshControl.isRefreshing) {
                    [SVProgressHUD dismiss];
                } else {
                    [refreshControl endRefreshing];
                }
                [self reloadViews];
                [self showMovieView];
                //activityIndicator.hidden = TRUE;
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!refreshControl.isRefreshing) {
                    [SVProgressHUD dismiss];
                } else {
                    [refreshControl endRefreshing];
                }
                self.handMadeStatusBar.hidden = NO;
                [self reloadViews];
                //activityIndicator.hidden = TRUE;
            });
            // handle network error here
        }
    }];
    if (!refreshControl.isRefreshing) {
        [SVProgressHUD show];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UITabBar appearance] setTintColor:self.viewToggle.tintColor];
    [SVProgressHUD setBackgroundColor:self.viewToggle.tintColor];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    // Do any additional setup after loading the view, typically from a nib.
    presentListView = YES;
    [self.movieTabBar setSelectedItem:self.boxOfficeTab];
    
    [self sendRequestForDataAccordingToSeletedBarItem:NO]; //aync request
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:self.viewToggle.tintColor];
    [self.movieListView addSubview:refreshControl];
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout*)self.movieGridView.collectionViewLayout;
    flow.minimumInteritemSpacing  = 0;
}


- (void)onRefresh:(id)sender{
    //NSLog(@"in refreshing");
    [self sendRequestForDataAccordingToSeletedBarItem:YES];
}

- (IBAction)viewSwitch:(id)sender {
    UISegmentedControl *viewSwitch = (UISegmentedControl*)sender;
    presentListView = viewSwitch.selectedSegmentIndex ? NO : YES;
    [self showMovieView];
}

- (void)sendRequestForDataAccordingToSeletedBarItem:(BOOL)withReload {
    switch (self.movieTabBar.selectedItem.tag) {
        case 1:
            if (topRentalDVDs == nil || withReload) {
                [self getDataFromAPIAsync:@"topRentalDVDs" withQuery:@""];
            } else {
                presentData = [NSMutableArray arrayWithArray:[self loadDataAccordingToSeletedBarItem:NO]];
            }
            break;
        case 0:
        default:
            if (boxOfficeMovies == nil || withReload) {
                [self getDataFromAPIAsync:@"boxOfficeMovies" withQuery:@""];
            } else {
                presentData = [NSMutableArray arrayWithArray:[self loadDataAccordingToSeletedBarItem:NO]];
            }
            break;
    }
}


- (NSArray *)loadDataAccordingToSeletedBarItem:(BOOL)withReload {
    NSArray *ret;
    //NSDictionary *data;
    switch (self.movieTabBar.selectedItem.tag) {
        case 1:
            if (topRentalDVDs == nil || withReload) {
                topRentalDVDs = [latestRequestedData objectForKey:@"movies"];
            }
            ret = topRentalDVDs;
            break;
        case 0:
        default:
            if (boxOfficeMovies == nil || withReload) {
                boxOfficeMovies = [latestRequestedData objectForKey:@"movies"];
            }
            ret = boxOfficeMovies;
            break;
    }
    //NSLog(@"%@", self.movieListView.subviews);
    return  ret;
}

- (void)showMovieView {
    self.movieListView.hidden = !presentListView;
    self.movieGridView.hidden = presentListView;
    [self.view setNeedsDisplay];
    if (presentListView) {
       [self.movieListView addSubview:refreshControl];
    } else {
       [self.movieGridView addSubview:refreshControl];
    }
}

- (void)reloadViews {
   [self.movieListView reloadData];
   [self.movieGridView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// collection view methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return presentData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"movieGridItem";
    movieGridCell *cell = [self.movieGridView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.title.text = [[presentData objectAtIndex:indexPath.row] objectForKey:@"title"];
    //cell.desc.text = [[boxOfficeMovies objectAtIndex:indexPath.row] objectForKey:@"synopsis"];
    NSURL *imgUrl = [NSURL URLWithString:[[presentData objectAtIndex:indexPath.row] valueForKeyPath:@"posters.thumbnail"]];
    [cell.thumbnail setImageWithURL:imgUrl];
    cell.title.adjustsFontSizeToFitWidth = YES;
    // fade in effect
    cell.thumbnail.alpha = 0;
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:2.0];
    cell.thumbnail.alpha = 1.0;
    [UIView commitAnimations];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.movieSearchBar resignFirstResponder];
}


// table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"count is %d", presentData.count);
    return presentData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"movieListItem";
    movieListCell *cell = [self.movieListView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[movieListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.title.adjustsFontSizeToFitWidth = YES;
    cell.title.text = [[presentData objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.desc.text = [[presentData objectAtIndex:indexPath.row] objectForKey:@"synopsis"];
    NSURL *imgUrl = [NSURL URLWithString:[[presentData objectAtIndex:indexPath.row] valueForKeyPath:@"posters.thumbnail"]];
    [cell.thumbnail setImageWithURL:imgUrl];
    
    // fade in effect
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:2.0];
    cell.thumbnail.alpha = 1.0;
    [UIView commitAnimations];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.movieSearchBar resignFirstResponder];
}


// search related methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.movieSearchBar resignFirstResponder];
}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSString *searchTextLowerCased = [searchBar.text lowercaseString];
    [presentData removeAllObjects];
    for (NSDictionary *movie in [self loadDataAccordingToSeletedBarItem:NO]) {
        if ([[[movie valueForKeyPath:@"title"] lowercaseString] rangeOfString:searchTextLowerCased].location != NSNotFound) {
            [presentData addObject:movie];
            //NSLog(@"=== %@", [movie valueForKeyPath:@"title"]);
        }
    }
    [self reloadViews];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.movieSearchBar.text = @"";
    [self sendRequestForDataAccordingToSeletedBarItem:NO];
    [self reloadViews];
}

// tab bar methods
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    /*
    NSArray *ret = [self loadDataAccordingToSeletedBarItem:NO];
    presentData = [NSMutableArray arrayWithArray:ret];
    [self reloadViews];
     */
    
    [self sendRequestForDataAccordingToSeletedBarItem:NO];
    self.movieSearchBar.text = @"";
    [self reloadViews];
}
- (IBAction)dismissBar:(id)sender {
    self.handMadeStatusBar.hidden = YES;
}

#pragma mark - Naviation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
    DetailViewController *destController = segue.destinationViewController;
    if ([[segue identifier] isEqualToString:@"list2detail"]) {
        movieListCell *cell = (movieListCell*)sender;
        NSIndexPath *path = [self.movieListView indexPathForCell:cell];
        NSDictionary *movie = [presentData objectAtIndex:path.row];
        destController.movie = movie;
    } else {
        movieGridCell *cell = (movieGridCell*)sender;
        NSIndexPath *path = [self.movieGridView indexPathForCell:cell];
        NSDictionary *movie = [presentData objectAtIndex:path.row];
        destController.movie = movie;
        //NSLog(@"movie is %@", movie);
    }

}
/*
- (IBAction)dimissKeyboard:(id)sender {
    [self.movieSearchBar resignFirstResponder];
}*/

@end
