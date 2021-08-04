//
//  ScarpCalcAppDelegate.m
//  ScarpCalc
//
//  Created by nixx on 10/6/09.
//  Copyright Home 2009. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "MCLoadingView_iPad.h"
#import "BaseViewController.h"

@interface AppDelegate_iPhone ()
{
    MCLoadingView_iPad *_loading;
}

@end


@implementation AppDelegate_iPhone

- (UIView *)viewForBanner
{
    return nil;
}

#pragma mark - Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar_bg"]];
    if (IS_IOS7)
    {
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    }
//    [self.tabBarController.tabBar setDelegate:self];
	[super applicationDidFinishLaunching:application];
}

- (UIViewController *)activeViewController
{
    UINavigationController *nav = (UINavigationController *)self.tabBarController.selectedViewController;
    return nav.topViewController;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [super applicationDidBecomeActive:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [super applicationWillEnterForeground:application];
    [(BaseViewController *)self.activeViewController showAdIfNeeded];
}

#pragma tabbar
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    NSLog(@"%d", self.tabBarController.selectedIndex);
    
}

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//    [[VersionManager shared] verifyVersion];
//}

//#pragma mark - Override Loading
//
//- (MCLoadingView_iPad *)loading
//{
//    if (_loading == nil) {
//        _loading = [[MCLoadingView_iPad alloc] initWithFrame:self.tabBarController.view.bounds];
//        [self.tabBarController.view addSubview:_loading];
//    }
//    return _loading;
//}
//
//- (void)showLoadingIndicator
//{
//    [self.loading show];
//}
//
//- (void)hideLoadingIndicator
//{
//    [self.loading hide];
//}

#pragma mark - Memory management

- (void)dealloc
{
    self.tabBarController = nil;
//    [_loading release];
	[super dealloc];
}

@end

