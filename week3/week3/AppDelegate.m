//
//  AppDelegate.m
//  week3
//
//  Created by Yi-De Lin on 6/26/15.
//  Copyright (c) 2015 YD Lin. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TweetsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:UserDidLogoutNotificaiton object:nil];

    UIScreen *screen = [UIScreen mainScreen];
    UIWindow *window = [[UIWindow alloc] initWithFrame:screen.bounds];
    window.screen = screen;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainViewController = [storyboard instantiateInitialViewController];
    window.rootViewController = mainViewController;
    self.window = window;
    
    User *user = [User currentUser];
    if (user != nil) {
        NSLog(@"welcome back %@", user);
        dispatch_async(dispatch_get_main_queue(), ^{
            UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"navigation"];
            [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
            });
    } else {
        NSLog(@"Not logged in");
        //self.window.rootViewController = [[LoginViewController alloc] init];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)userDidLogout {
    NSLog(@"User has logged out, go to login page");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainViewController = [storyboard instantiateInitialViewController];
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[TwitterClient sharedInstance] openURL:url];
    return YES;
}

@end
