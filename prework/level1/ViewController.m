//
//  ViewController.m
//  level1
//
//  Created by Yi-De Lin on 6/4/15.
//  Copyright (c) 2015 Yi-De Lin. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
@interface ViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = [[UIApplication sharedApplication] delegate];
    self.percentLabel.text = [NSString stringWithFormat:@"%d", appDelegate.defaultPercent];
    self.percentSlider.value = appDelegate.defaultPercent;
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *stringValue = [defaults objectForKey:@"lastAmount"];
    double lastSaveTime = [defaults doubleForKey:@"lastSaveTime"];

    appDelegate.cacheExipration = (int)[defaults integerForKey:@"cacheExpiration"];
    NSDate* date = [NSDate date];
    NSTimeInterval epochSeconds = [date timeIntervalSince1970];
    if (stringValue != nil && (epochSeconds - lastSaveTime < appDelegate.cacheExipration*60)) {
        self.billAmountTextField.text = stringValue;
        appDelegate.selectedLocale = [defaults objectForKey:@"defaultLocale"];
    } else if (appDelegate.selectedLocale == nil) {
        appDelegate.selectedLocale = @"zh_Hant_TW";
    }
    self.billAmountTextField.adjustsFontSizeToFitWidth = YES;
    self.tipLabel.adjustsFontSizeToFitWidth = YES;
    
    if (appDelegate.currentAmountText) {
        self.billAmountTextField.text = appDelegate.currentAmountText;
    }
    [self calculateTip];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.billAmountTextField becomeFirstResponder];
}

- (IBAction)amountChanged:(id)sender {
    appDelegate.currentAmountText = self.billAmountTextField.text;
    [self saveAmount];
    [self calculateTip];
}
- (IBAction)percentSliding:(id)sender {
    [self calculateTip];
    self.percentLabel.text = [NSString stringWithFormat:@"%d", (int)self.percentSlider.value];
}
- (IBAction)percentChanged:(id)sender {
    int validPercentage =[appDelegate validIntRange:self.percentLabel min:0 max:100];
    self.percentLabel.text = [NSString stringWithFormat:@"%d", validPercentage];
    [self calculateTip];
    self.percentSlider.value = [self.percentLabel.text intValue];
}
- (void)saveAmount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.billAmountTextField.text forKey:@"lastAmount"];
    
    NSDate* date = [NSDate date];
    NSTimeInterval epochSeconds = [date timeIntervalSince1970];
    [defaults setDouble:epochSeconds forKey:@"lastSaveTime"];
    [defaults synchronize];
}

- (void)calculateTip {
    NSString *amt;
    if (![self.billAmountTextField.text isEqualToString:@""]) {
        amt = self.billAmountTextField.text;
    } else {
        amt = @"0";
    }
    NSLog(@"%@",appDelegate.selectedLocale);
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:amt];
    
    NSDecimalNumber *per = [NSDecimalNumber decimalNumberWithString:self.percentLabel.text];
    
    NSDecimalNumber *tip = [amount decimalNumberByMultiplyingBy:per];
    tip = [tip decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];

    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:appDelegate.selectedLocale];
    [currencyFormatter setLocale:locale];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.tipLabel.text = [currencyFormatter stringFromNumber:tip];
    //NSLog(@"%@", [currencyFormatter stringFromNumber:tip]);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
