//
//  TweetsViewController.m
//  week3
//
//  Created by Yi-De Lin on 6/27/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "TweetsViewController.h"
#import "Tweet.h"
#import "TwitterClient.h"
#import "AppDelegate.h"
#import "ComposeViewController.h"
#import "TweetDetailViewController.h"
#import "TweetCell.h"
#import <UIImageView+AFNetworking.h>
#import "ProfilePageViewController.h"
#import "ProfileCell.h"

@interface TweetsViewController () <UITableViewDataSource,
                                    UITableViewDelegate,
                                    TweetDetailViewDelegate,
                                    TweetCellDelegate,
                                    ComposeViewDelegate,
                                    UIScrollViewDelegate>

@end

NSMutableArray *_tweets;
UIRefreshControl *_refreshControl;
int loadMore;
UIActivityIndicatorView *spinner;
CGPoint sDragPoint;
//CGRect showMenu, hideHome, hideMenu, showHome, hideNav, showNav;
//int menuToggle = 0;

@implementation TweetsViewController

@synthesize currentTimelineType;
// one function for load/reload homeline tweets
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.withHeaderCell) {
        [self.tweetViewDelegator controller:self scroll:scrollView];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //if (spinner == nil) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]; [self.view addSubview:spinner];
        spinner.color = [UIColor grayColor];
        [self.view addSubview:spinner];
    //}
    self.homelineTable.hidden = YES;
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view bringSubviewToFront:spinner];
    [self onRefresh];
    if (self.enableOnRefresh) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
        [self.homelineTable addSubview:_refreshControl];
    }
    self.homelineTable.estimatedRowHeight = 107;
    self.homelineTable.rowHeight = UITableViewAutomaticDimension;

    loadMore = 0;
    if (self.currentTimelineType == nil) {
        self.currentTimelineType = @"Home";
    }
    
    if (self.withHeaderCell) {
        [self.homelineTable registerNib:[UINib nibWithNibName:self.headerCellId bundle:nil] forCellReuseIdentifier:self.headerCellId];
    }
    
    UIPanGestureRecognizer *onDragMenu =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDragMenu:)];
    [self.view addGestureRecognizer:onDragMenu];
}

- (IBAction)onDragMenu:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        sDragPoint = [sender locationInView:self.view];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint stopLocation = [sender locationInView:self.view];
        CGFloat dx = sDragPoint.x - stopLocation.x;
        if (dx < 0 && (dx < -70)) {
            [self.delegate controller:self DidPressMenuButton:sender];
        } else if ( dx > 0 && (dx > 10)) {
            [self.delegate didHideMenuController:self];
        }

    }
}


- (void)onRefresh {
    if (loadMore) {
        return;
    }
    NSLog(@"onRefresh %@", self.currentTimelineType);
    loadMore = 1;
    self.navigationController.navigationBar.topItem.title = self.currentTimelineType;
    [[TwitterClient sharedInstance] timeline:self.currentTimelineType params:nil completion:^(NSArray *tweets, NSError *error) {
        NSLog(@"data is back");
        loadMore = 0;
        if (tweets != nil) {
            _tweets = [NSMutableArray arrayWithArray:tweets];
        }
        if (error) {
            NSLog(@"error %@", error);
        }
        if (self.enableOnRefresh) {
            [_refreshControl endRefreshing];
        }
        self.homelineTable.hidden = NO;
        [self.homelineTable reloadData];
        //dispatch_async(dispatch_get_main_queue(), ^{
        if (spinner.isAnimating) {
            [spinner stopAnimating];
        }
        [self.view addSubview:self.homelineTable];
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.withHeaderCell) {
        return [_tweets count] + 1; //plus header
    } else {
        return [_tweets count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // reach the end
    if (!loadMore && indexPath.row == [_tweets count] - 3) {
        long int lastIndex = (long int)[_tweets count] - 1;
        Tweet *lastTweet = [_tweets objectAtIndex:lastIndex];
        NSDictionary *params = @{@"max_id": lastTweet.idStr};
        NSLog(@"max_id %ld %@", lastIndex, lastTweet.idStr);
        loadMore = 1;
        [[TwitterClient sharedInstance] timeline:self.currentTimelineType params:params completion:^(NSArray *tweets, NSError *error) {
            if (error == nil && tweets != nil) {
            Tweet *t = tweets[0];
            if (![t.idStr isEqualToString:lastTweet.idStr]) {
                [_tweets addObject:t];
            }
            loadMore = 0;
            [_tweets addObjectsFromArray:[tweets subarrayWithRange:NSMakeRange(1, [tweets count]-1)]];
            //NSLog(@"reloadData %d", [_tweets count]);
            [self.homelineTable reloadData];
            }
        }];
    }
    if (self.withHeaderCell && indexPath.row == 0) {
        ProfileCell *pCell = [self.homelineTable dequeueReusableCellWithIdentifier:self.headerCellId];
        pCell.name.text = self.headerUser.name;
        pCell.screenname.text = [NSString stringWithFormat:@"@%@", self.headerUser.screenname];
        pCell.desc.text = self.headerUser.description;
        //[pCell.desc sizeToFit];
        pCell.desc.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds);
        pCell.tweetsCount.text = [NSString stringWithFormat:@"%d", self.headerUser.tweetCount];
        pCell.followingCount.text = [NSString stringWithFormat:@"%d", self.headerUser.followingCount];
        pCell.followerCount.text = [NSString stringWithFormat:@"%d", self.headerUser.followerCount];
        pCell.profileImage.image = self.headerUser.profileImage;
        pCell.profileImage.layer.cornerRadius = 5;
        pCell.profileImage.clipsToBounds = YES;
        [pCell.profileImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [pCell.profileImage.layer setBorderWidth: 2.0];
        return pCell;
    }
    
    int newIdx = (int)indexPath.row;
    if (self.withHeaderCell) {
        newIdx -= 1;
    }
    
    // cell init
    NSString *cellIdentifier = @"tweetCell";
    TweetCell *cell = [self.homelineTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier];
    }
    
    // This line to prevent the case that the first shwon labels can't wrapp long text correctly
    cell.text.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds);
    
    Tweet *tweet = _tweets[newIdx];
    cell.text.text = tweet.text;
    
    cell.userName.text = tweet.user.name;
    cell.userScreenname.text = [NSString stringWithFormat:@"@%@", tweet.user.screenname];
    
    //NSLog(@"index path at row %ld %@", indexPath.row, tweet.idStr);
    if (tweet.user.profileImage == nil) {
    NSString *imageUrl = tweet.user.profileImageUrl;
    [cell.userProfileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.userProfileImage.alpha = 0.9;
        cell.userProfileImage.image = image;
        // fade in effect
        [UIView beginAnimations:@"fadeIn" context:nil];
        [UIView setAnimationDuration:5.0];
        cell.userProfileImage.alpha = 1.0;
        [UIView commitAnimations];
        tweet.user.profileImage = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        // network error
        NSLog(@"Error for retreiving profile image: %@", error);
    }];
    } else {
        [cell.userProfileImage setImage:tweet.user.profileImage];
    }
    
    UITapGestureRecognizer *tapOnProfileImage =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileImage:)];
    [cell.userProfileImage addGestureRecognizer:tapOnProfileImage];

    if (tweet.retweeter != nil) {
        cell.retweetedByWho.hidden = NO;
        cell.retweetImage.hidden = NO;
        cell.retweetedByWho.text = [NSString stringWithFormat:@"%@ retweeted", tweet.retweeter.name];
    } else {
        cell.retweetedByWho.hidden = YES;
        cell.retweetImage.hidden = YES;
    }
    //NSLog(@"tweet r%d f%d", tweet.retweet_count, tweet.favorite_count);
    if (tweet.retweeted) {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
    
    //NSLog(@"tweet user id %@ vs viewer id %@", tweet.user.idStr, [User currentUser].idStr);
    if ([tweet.user.idStr isEqualToString:[User currentUser].idStr]) {
        cell.retweetButton.enabled = NO;
    } else {
        cell.retweetButton.enabled = YES;
    }
    
    if (tweet.favorited) {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
    
    cell.createdAtByHour.text = tweet.displayDate;
    cell.delegate = self;
    cell.tweet = tweet;
    return cell;
    
   
}

- (void)tapOnProfileImage:(UIGestureRecognizer *)sender {
    NSLog(@"Tap on image from cell");
    //[self performSegueWithIdentifier:@"home2profile" sender:sender.view.superview.superview];
    TweetCell *cell = (TweetCell*)sender.view.superview.superview;
    NSIndexPath *idx = [self.homelineTable indexPathForCell:cell];
    Tweet *tweet = _tweets[idx.row];
    if (self.withHeaderCell) {
        tweet = _tweets[idx.row - 1];
    }
    [self.delegate controller:self DidSelectItem:@"Profile" Data:tweet.user];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)onMenu:(id)sender {
    [self.delegate controller:self DidPressMenuButton:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TweetCell *cell = (TweetCell*)sender;
    NSIndexPath *idx = [self.homelineTable indexPathForCell:cell];
    //Tweet *tweet = _tweets[idx.row];
    if ([segue.identifier isEqualToString:@"home2detail"]){
        if (self.withHeaderCell) {
            NSLog(@"origin cell prepare for segue");
           [self.tweetViewDelegator controller:self
                presentDetailWithTweet:_tweets[idx.row]];
        } else {
            TweetDetailViewController *dVC = segue.destinationViewController;
            dVC.tweet = _tweets[idx.row];
            dVC.delegate = self;
            dVC.originalCellIndex = idx;
        }
    } else if([segue.identifier isEqualToString:@"home2compose"]) {
        ComposeViewController *cVC = segue.destinationViewController;
        cVC.user = [User currentUser];
        cVC.delegate = self;
        NSLog(@"go to compose");
    } else if([segue.identifier isEqualToString:@"home2reply"]){
        NSLog(@"go to reply page");
        ComposeViewController *cVC = segue.destinationViewController;
        cVC.user = [User currentUser];
        cVC.idToReply = cell.tweet.idStr;
        
        if (cell.tweet.retweeter == nil) {
            cVC.prefix = [NSString stringWithFormat:@"@%@ ", cell.tweet.user.screenname];
        } else {
            cVC.prefix = [NSString stringWithFormat:@"@%@ %@ ", cell.tweet.user.screenname, cell.tweet.retweeter.screenname];
        }
        cVC.delegate = self;
     }/* else if([segue.identifier isEqualToString:@"home2profile"]){
         
         ProfilePageViewController *profileController = segue.destinationViewController;
         profileController.user = tweet.user;
         profileController.delegate = self.delegate;
     }*/
}

- (void) tweetCell:(TweetCell *)cell didRetweetedWithId:(NSString *)id {
    NSLog(@"onRetweet");
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.retweetButton.imageView.image = [UIImage imageNamed:@"retweet_on"];
        cell.tweet.retweeted = 1;
        cell.tweet.retweet_count++;
    });
    [[TwitterClient sharedInstance] retweet:id completion:^(Tweet *tweet, NSError *error) {
        if (error != nil) {
            cell.retweetButton.imageView.image = [UIImage imageNamed:@"retweet"];
            cell.tweet.retweeted = 0;
            cell.tweet.retweet_count--;
        }
    }];
}

- (void) tweetCell:(TweetCell *)cell didUnretweetedWithId:(NSString *)id {
    NSLog(@"onUnretweet");
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.tweet.retweeted = 0;
        cell.tweet.retweet_count--;
        cell.retweetButton.imageView.image = [UIImage imageNamed:@"retweet"];
    });
    [[TwitterClient sharedInstance] tweetDetail:id completion:^(Tweet *tweet, NSError *error) {
        if (error == nil) {
            NSString *trueTweetId = [tweet.rawDict valueForKeyPath:@"current_user_retweet.id_str"];
            //NSLog(@"zzz %@", tweet.rawDict);
            [[TwitterClient sharedInstance] deletTweete:trueTweetId completion:^(Tweet *tweet, NSError *error) {
                if (error) {
                    // rollback
                    cell.tweet.retweeted = 1;
                    cell.tweet.retweet_count++;
                    cell.retweetButton.imageView.image = [UIImage imageNamed:@"retweet_on"];
                    NSLog(@"unretweet error is %@", error);
                }
            }];
        }
    }];
}

- (void) tweetCell:(TweetCell *)cell didReplyWithId:(NSString *)id {
    NSLog(@"onReply");
    [self performSegueWithIdentifier:@"home2reply" sender:cell];
}

- (void) tweetCell:(TweetCell *)cell didFavoriteWithId:(NSString *)id {
    NSLog(@"onFavorite");
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.favoriteButton.imageView.image = [UIImage imageNamed:@"favorite_on"];
        cell.tweet.favorited = 1;
        cell.tweet.favorite_count++;
    });
    [[TwitterClient sharedInstance] favorite:id completion:^(Tweet *tweet, NSError *error) {
        if (error != nil) {
            cell.favoriteButton.imageView.image = [UIImage imageNamed:@"favorite"];
            cell.tweet.favorited = 0;
            cell.tweet.favorite_count--;
        }
    }];
}

- (void) tweetCell:(TweetCell *)cell didUnfavoriteWithId:(NSString *)id {
    NSLog(@"onUnfavorite");
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.favoriteButton.imageView.image = [UIImage imageNamed:@"favorite"];
        cell.tweet.favorited = 0;
        cell.tweet.favorite_count--;
    });
    [[TwitterClient sharedInstance] unfavorite:id completion:^(Tweet *tweet, NSError *error) {
        if (error != nil) {
            cell.favoriteButton.imageView.image = [UIImage imageNamed:@"favorite_on"];
            cell.tweet.favorited = 1;
            cell.tweet.favorite_count++;
        }
    }];
}


-(void)detailViewController:(TweetDetailViewController *)controller doActions:(NSString *)action {
    TweetCell *oriCell = (TweetCell*)[self.homelineTable cellForRowAtIndexPath:controller.originalCellIndex];
    if ([action isEqualToString:@"retweet"]) {
        [[TwitterClient sharedInstance] retweet:controller.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
            //[self.homelineTable reloadData];
            [oriCell.retweetButton.imageView setImage:[UIImage imageNamed:@"retweet_on"]];
        }];
    } else if ([action isEqualToString:@"favorite"]) {
        [[TwitterClient sharedInstance] favorite:controller.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
            
            [oriCell.favoriteButton.imageView setImage:[UIImage imageNamed:@"favorite_on"]];
            //[self.homelineTable reloadData];
        }];
    } else if ([action isEqualToString:@"unfavorite"]) {
        [[TwitterClient sharedInstance] unfavorite:controller.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
            
            [oriCell.favoriteButton.imageView setImage:[UIImage imageNamed:@"favorite"]];
            //[self.homelineTable reloadData];
        }];
    } else if ([action isEqualToString:@"unretweet"]) {
        NSString *tweetId = controller.tweet.idStr;
        if (controller.tweet.originalRetweetIdStr != nil) {
            tweetId = controller.tweet.originalRetweetIdStr;
        }
        [[TwitterClient sharedInstance] tweetDetail:tweetId completion:^(Tweet *tweet, NSError *error) {
            if (error == nil) {
                NSString *trueTweetId = [tweet.rawDict valueForKeyPath:@"current_user_retweet.id_str"];
                [[TwitterClient sharedInstance] deletTweete:trueTweetId completion:^(Tweet *tweet, NSError *error) {
                    
                    [oriCell.retweetButton.imageView setImage:[UIImage imageNamed:@"retweet"]];
                    NSLog(@"unretweet error is %@", error);
                    //[self.homelineTable reloadData];
                }];
            }
        }];
    }
}

- (void)composer:(ComposeViewController *) controller DidComposeWithText:(NSString *)text ReplyToId:(NSString *)id {
    [[TwitterClient sharedInstance] tweet:text repliesTo:id completion:^(Tweet *tweet, NSError *error) {
        NSLog(@"tweet success");
        //Todo append latest tweet
        if (tweet != nil) {
            [_tweets insertObject:tweet atIndex:0];
        }
        [self.navigationController popViewControllerAnimated:YES];
        [self.homelineTable reloadData];
        //error handling
    }];
}
// can not retweet/reply/fav cases
// cancel cases - unfav, unretweet

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
