//
//  FilterController.m
//  week2
//
//  Created by Yi-De Lin on 6/21/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "FilterController.h"
#import "FilterCell.h"
@interface FilterController () <
                                UITableViewDataSource,
                                UITableViewDelegate,
                                FilterCellDelegate
                               >

@end

NSArray *categories;
int lastShownCategoryIndex;
static int shownCategoryInc = 4;
int expandRadius;
int predefinedRadius[5] = {1, 3, 5, 10, 20};

@implementation FilterController

-(void)filterCell:(FilterCell*)cell didChangeFilter:(NSString*)key Value:(NSObject*)value {
    if ([key isEqualToString:@"category"]) {
        NSIndexPath *indexPath = [self.filterTable indexPathForCell:cell];
        NSMutableDictionary *categoriesSetting = [self.filterSettings objectForKey:@"category"];
        NSString *subKey = [[categories objectAtIndex:indexPath.row] valueForKeyPath:@"alias"];
        [categoriesSetting setValue:value forKey:subKey];
        [self.filterSettings setValue:categoriesSetting forKey:key];
    } else {
       [self.filterSettings setValue:value forKey:key];
    }
    NSLog(@"changed filter settings %@", self.filterSettings);
}

-(NSArray*)loadCategoryFromJSON:(NSString*)path {
    NSError *deserializingError;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType:@"json"];
    NSURL *localFileURL = [NSURL fileURLWithPath:fullPath];
    //NSLog(@"%@", localFileURL);
    
    NSData *contentOfLocalFile = [NSData dataWithContentsOfURL:localFileURL];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:contentOfLocalFile
                                                options:kNilOptions
                                                  error:&deserializingError];
    

    return json;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    categories = [self loadCategoryFromJSON:@"categories_resturants"];
    //NSLog(@"%@", categories);
    expandRadius = 0;
    lastShownCategoryIndex = shownCategoryInc;
    NSDictionary *categoryFilters = [NSMutableDictionary dictionary];
    /*for (int i=0; i<[categories count]; i++) {
        NSString *key = [[categories objectAtIndex:i] valueForKeyPath:@"alias"];
        NSLog(@"key is %@", key);
        [categoryFilters setValue:@NO forKey:key];
    }*/
    if (self.filterSettings == nil) {
        self.filterSettings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      @3, @"distance",
                      @0, @"sortBy",
                      @NO, @"deals",
                      categoryFilters, @"category",
                      nil];
    }
    //self.navigationItem
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.filterTable.estimatedRowHeight = 60.0;
    //self.filterTable.rowHeight = UITableViewAutomaticDimension;
    //NSLog(@"%@", self.filterSettings);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onDone:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate filterController:self didUpdateFilters:self.filterSettings];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0: // deals
            sectionName = nil;
            break;
        case 1: // distance
            sectionName = @"Distance";
            break;
        case 2: // sort by
            sectionName = @"Sort By";
            break;
        case 3: // category
            sectionName = @"Catgory";
            break;
        default:
            break;
    }
    return sectionName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int nRow = 0;
    switch (section) {
        case 0: // deals
            nRow = 1;
            break;
        case 1: // distance
            if (expandRadius) {
                nRow = 6;
            } else {
                nRow = 1;
            }
            break;
        case 2: // sort by
            nRow = 1;
            break;
        case 3: // category
            if (lastShownCategoryIndex != -1) {
                nRow = lastShownCategoryIndex + 2; // one for load more
            } else {
                nRow = (int)[categories count];
            }
            break;
        default:
            break;
    }
    return nRow;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"filterCell";

    switch(indexPath.section) {
        case 0:
            cellIdentifier = @"switchCell";
            break;
        case 1:
            if (indexPath.row) {
                cellIdentifier = @"expandRadiusCell";
            } else {
                cellIdentifier = @"distanceCell";
            }
            break;
        case 2:
            cellIdentifier = @"sortByCell";
            break;
        case 3:
            cellIdentifier = @"categorySwitchCell";
            break;
            
    }
    FilterCell *cell = [self.filterTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FilterCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    if (indexPath.section == 0) {
        NSLog(@"deals is %@", [self.filterSettings valueForKey:@"deals"]);
        cell.dealSwitch.on = [[self.filterSettings valueForKey:@"deals"] boolValue];
    } else if (indexPath.section == 1) {
        NSLog(@"sec 1 %ld", indexPath.row);
        if (indexPath.row == 0) {
            float d = [[self.filterSettings valueForKey:@"distance"] floatValue];
            cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f KM", d];
            cell.distanceSlider.value = d;
        } else {
            NSString *imageFile;
            if ([[self.filterSettings objectForKey:@"distance"] intValue] == predefinedRadius[indexPath.row-1]) {
                imageFile = @"Ok Filled-50";
            } else {
                imageFile = @"Ok-50";
            }
            UIImage *image = [UIImage imageNamed:imageFile];
            [cell.checkStatusImage setImage:image];
            cell.predefinedRadiusLabel.text = [NSString stringWithFormat:@"%d KM", predefinedRadius[indexPath.row-1]];
        }
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (indexPath.section == 2) {
        int i = [[self.filterSettings valueForKey:@"sortBy"] intValue];
        [cell.sortBySegment setSelectedSegmentIndex:i];
    } else if (indexPath.section == 3) {
        if (lastShownCategoryIndex != -1 && lastShownCategoryIndex+1 == indexPath.row) {
            cell.categoryLabel.textColor = [UIColor redColor];
            cell.categoryLabel.text = @"Load all";
            cell.categorySwitch.hidden = YES;
        } else {
            cell.categoryLabel.text = [[categories objectAtIndex:indexPath.row] valueForKeyPath:@"title"];
            cell.categorySwitch.hidden = NO;
            cell.categoryLabel.textColor = [UIColor blackColor];
            NSMutableDictionary *categoriesSetting = [self.filterSettings objectForKey:@"category"];
            cell.categorySwitch.on = [[categoriesSetting valueForKey:[[categories objectAtIndex:indexPath.row] valueForKeyPath:@"alias"]] boolValue];
        }
    }
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3 && lastShownCategoryIndex != -1 && indexPath.row == lastShownCategoryIndex+1) {
        //lastShownCategoryIndex += shownCategoryInc;
        lastShownCategoryIndex = -1;
        [self.filterTable reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:NO];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (expandRadius == 0) {
                expandRadius = 1;
            } else {
                expandRadius = 0;
            }
        } else {
            expandRadius = 0;
            NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
            FilterCell *cell = (FilterCell*)[tableView cellForRowAtIndexPath:firstRow];
            [self filterCell:cell didChangeFilter:@"distance" Value:[NSNumber numberWithFloat:predefinedRadius[indexPath.row-1]]];
        }
        //[self.filterTable reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:NO];
        [self.filterTable reloadData];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
