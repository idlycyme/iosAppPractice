//
//  settingTableViewController.m
//  prework
//
//  Created by Yi-De Lin on 6/8/15.
//  Copyright (c) 2015 Yi-De Lin. All rights reserved.
//

#import "settingTableViewController.h"
#import "AppDelegate.h"

@interface settingTableViewController () {
    NSArray *settings;
    AppDelegate *appDelegate;
    NSArray *localeIds;
    NSMutableArray *regions;
}
@property NSInteger toggle;
@property (strong, nonatomic) UIPickerView *pickerView;
@end

@implementation settingTableViewController 



-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return regions.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [regions objectAtIndex:row];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    appDelegate.selectedLocale = [localeIds objectAtIndex:row];
    NSLog(@"current locale %@", [localeIds objectAtIndex:row]);
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f", 12345678.09]];
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[localeIds objectAtIndex:row]];
    [currencyFormatter setLocale:locale];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.sampleCurrencyLabel.text = [currencyFormatter stringFromNumber:amount];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:appDelegate.selectedLocale forKey:@"defaultLocale"];
    [defaults synchronize];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideKeyboardForTextField)];
    [self.view addGestureRecognizer:tap];
    
    localeIds = [NSLocale availableLocaleIdentifiers];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    regions = [[NSMutableArray alloc] init];
    for (int i=0; i<localeIds.count; i++) {
        NSString *name = [locale displayNameForKey:NSLocaleIdentifier value:[localeIds objectAtIndex:i]];
        [regions addObject:name];
        //NSLog(@"%@, %@, %@", name, [localeIds objectAtIndex:i], appDelegate.selectedLocale);
        if ([[localeIds objectAtIndex:i] isEqualToString:appDelegate.selectedLocale]) {
            [self.regionPicker selectRow:i inComponent:0 animated:NO];
        }
    }
    
    
    self.defaultCacheExpiration.text = [NSString stringWithFormat:@"%d", appDelegate.cacheExipration];
    self.defaultPercentageTextField.text = [NSString stringWithFormat:@"%d", appDelegate.defaultPercent];
    self.sampleCurrencyLabel.adjustsFontSizeToFitWidth = YES;

    //[self.regionPicker reloadAllComponents];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cacheExpirationChanged:(id)sender {
    int validExpiration =[appDelegate validIntRange:self.defaultCacheExpiration min:0 max:99999];
    self.defaultCacheExpiration.text = [NSString stringWithFormat:@"%d", validExpiration];
    appDelegate.cacheExipration = [self.defaultCacheExpiration.text intValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:appDelegate.cacheExipration forKey:@"cacheExpiration"];
    [defaults synchronize];
}


- (IBAction)defaulPercentageTextFieldChanged:(id)sender {
    int validPercentage =[appDelegate validIntRange: self.defaultPercentageTextField min:0 max:100];
    self.defaultPercentageTextField.text = [NSString stringWithFormat:@"%d", validPercentage];
    appDelegate.defaultPercent = [self.defaultPercentageTextField.text doubleValue];
}


- (void)hideKeyboardForTextField {
    [self.defaultPercentageTextField resignFirstResponder];
    [self.defaultCacheExpiration resignFirstResponder];
}

@end
