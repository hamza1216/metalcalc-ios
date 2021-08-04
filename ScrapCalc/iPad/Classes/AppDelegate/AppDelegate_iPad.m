//
//  AppDelegate_iPad.m
//  ScarpCalc
//
//  Created by admin on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "MCLoadingView_iPad.h"
#import "MCBaseViewController_iPad.h"


@interface AppDelegate_iPad ()
{    
    MCLoadingView_iPad *_loading;
}

@end


@implementation AppDelegate_iPad

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[super applicationDidFinishLaunching:application];
    
    self.rootViewController = [[MCBaseViewController_iPad new] autorelease];
    self.window.rootViewController = self.rootViewController;
    
    self.splitViewController = [[MCSplitViewController new] autorelease];
    self.splitViewController.view.frame = self.rootViewController.view.bounds;
    self.splitViewController.view.backgroundColor = [UIColor redColor];
    
    [self.rootViewController addChildViewController:self.splitViewController];
    [self.rootViewController.view addSubview:self.splitViewController.view];
    
    self.toolbarView = [[[MCToolbarView alloc] initWithFrame:CGRectZero] autorelease];
    self.toolbarView.delegate = self.splitViewController;
    [self.rootViewController.view addSubview:self.toolbarView];
    self.splitViewController.toolbar = self.toolbarView;
}

- (UIViewController *)activeViewController
{
    MCNavigationController *nav = (MCNavigationController *)self.splitViewController.masterViewController;
    return nav.topViewController;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [super applicationDidBecomeActive:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [super applicationWillEnterForeground:application];
    [(MCBaseViewController_iPad *)self.activeViewController showAdIfNeeded];
}

#pragma mark - Override Loading

- (MCLoadingView_iPad *)loading
{
    if (_loading == nil) {
        _loading = [[MCLoadingView_iPad alloc] initWithFrame:self.rootViewController.view.bounds];
        [self.rootViewController.view addSubview:_loading];
    }
    return _loading;
}

- (void)showLoadingIndicator
{
    [self.loading show];
}

- (void)hideLoadingIndicator
{
    [self.loading hide];
}


#pragma mark - Memory management

- (void)dealloc
{
    self.splitViewController = nil;
    self.rootViewController = nil;
    
    [_loading release];
    [super dealloc];
}

@end
