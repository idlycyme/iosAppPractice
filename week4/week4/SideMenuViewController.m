//
//  SideMenuViewController.m
//  week4
//
//  Created by Yi-De Lin on 7/3/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "SideMenuViewController.h"
#import "User.h"
#import "AccountCell.h"
#import <UIImageView+AFNetworking.h>
#import "TwitterClient.h"
@interface SideMenuViewController () <UITableViewDataSource,
    UITableViewDelegate, accountCellDelegate>

@end

UINib *nib;
BOOL accountsExpanded;
NSArray *defaultCells;
//CGPoint startLocation;

@implementation SideMenuViewController


- (void)loadView {
    [super loadView];
    
    nib = [UINib nibWithNibName:@"SideMenu" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    NSArray *objects = [nib instantiateWithOwner:self options:nil];
    [self.view addSubview:[objects lastObject]];
    // init menu table
    self.menuView.frame = self.view.frame;
    
    // cell nib
    [self.menuTable registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    accountsExpanded = NO;
    defaultCells = @[@"Profile", @"Home", @"Mentions"];
    self.menuTable.estimatedRowHeight = 100;
    self.menuTable.rowHeight = UITableViewAutomaticDimension;
    
    self.menuTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UISwipeGestureRecognizer *swipeBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipLeft:)];
    [swipeBack setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeBack];
}

- (IBAction)onSwipLeft:(id)sender {
    [self.delegate didHideMenuController:self];
    NSLog(@"on swipe left in menu");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Table view methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id data;
    long mainIndex = indexPath.row;
    if (accountsExpanded && indexPath.row < [[User otherLoggedinUsers] count] + 1) {
        mainIndex = 0;
    } else if (accountsExpanded && indexPath.row >= [[User otherLoggedinUsers] count] + 1) {
        mainIndex = indexPath.row - [[User otherLoggedinUsers] count];
    }
    
    NSString *action = nil;
    if (mainIndex) {
        action = defaultCells[mainIndex - 1];
    } else {
        action = @"Account";
        accountsExpanded = !accountsExpanded;
        if (indexPath.row) {
            NSArray *users = [[User otherLoggedinUsers] allValues];
            User *user =users[indexPath.row-1];
            [User removeLoggedinUser:user.screenname];
            [User addLoggedinUser:[User currentUser]];
            [User setCurrentUser:user];
            [TwitterClient setSharedInstanceAccessToken:user.token];
            NSLog(@"change token to %@", user.token.secret);
            [self.menuTable reloadData];
            [self.delegate controller:self DidSelectItem:@"Account" Data:user.screenname];
        } else {
            [self.menuTable reloadData];
            return;
        }
    }
    
    if ([action isEqualToString:@"Profile"]) {
        data = [User currentUser];
    }
    
    [self.delegate controller:self DidSelectItem:action Data:data];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"menu cell count %@", [User otherLoggedinUsers]);
    if (accountsExpanded) {
        return  [defaultCells count] + [[User otherLoggedinUsers] count] + 1;
    } else {
        return [defaultCells count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    long mainIndex = indexPath.row;
    if (accountsExpanded && indexPath.row < [[User otherLoggedinUsers] count] + 1) {
            mainIndex = 0;
    } else if (accountsExpanded && indexPath.row >= [[User otherLoggedinUsers] count] + 1) {
            mainIndex = indexPath.row - [[User otherLoggedinUsers] count];
    }
    
    NSString *cellId;
    if (mainIndex) {
        cellId = @"GeneralCell";
    } else {
        cellId = @"AccountCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:cellId];
    }
    if (mainIndex) {
        NSString *title = defaultCells[mainIndex - 1];
        cell.imageView.image = [UIImage imageNamed:title];
        cell.textLabel.text = title;
        
    } else {
        // current user
        User *currentUser;
        if (indexPath.row == 0) {
            currentUser = [User currentUser];
        } else {
            NSArray *users = [[User otherLoggedinUsers] allValues];
            currentUser = users[indexPath.row - 1];
        }
        NSLog(@"name is %@", currentUser.screenname);
        
            AccountCell *aCell = (AccountCell *)cell;
            [aCell.profileImage setImage:currentUser.profileImage];
            if (currentUser.profileImage == nil) {
                NSString *imageUrl = currentUser.profileImageUrl;
                [aCell.profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    aCell.profileImage.alpha = 0.9;
                    aCell.profileImage.image = image;
                    // fade in effect
                    [UIView beginAnimations:@"fadeIn" context:nil];
                    [UIView setAnimationDuration:5.0];
                    aCell.profileImage.alpha = 1.0;
                    [UIView commitAnimations];
                    currentUser.profileImage = image;
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    // network error
                    NSLog(@"Error for retreiving profile image: %@", error);
                }];
            } else {
                [aCell.profileImage setImage:currentUser.profileImage];
            }
            aCell.delegate = self;
            aCell.name.text = currentUser.name;
            aCell.screenname.text = [NSString stringWithFormat:@"@%@", currentUser.screenname];
        CGRect normalFrame = self.view.frame;
        CGRect realFrame = CGRectMake(normalFrame.origin.x, normalFrame.origin.y, normalFrame.size.width - 50, normalFrame.size.height);
        aCell.normalFrame = realFrame;
        [aCell addPanGesture];
    }
    
    return cell;
}

- (IBAction)onAddAccount:(id)sender {
    NSLog(@"on add account");
    [self.delegate controller:self DidSelectItem:@"addAccount" Data:nil];
}

- (void)cell:(AccountCell *)cell userLogout:(NSString *)userScreenname {
    NSLog(@"delegate user logout");
    [User logout:userScreenname];
    [self.menuTable reloadData];
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
