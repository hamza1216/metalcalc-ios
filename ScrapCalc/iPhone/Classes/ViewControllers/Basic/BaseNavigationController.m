//
//  BaseNavigationController.m
//  ScrapCalc
//
//  Created by word on 19.03.13.
//
//

#import "BaseNavigationController.h"
#import "BaseViewController.h"

@implementation BaseNavigationController

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{    
    self.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 1) {
        if([VersionManager shared].currentVersion != VersionExpired)
            [(BaseViewController *)viewController initBackButton];
    }
}

#pragma mark - Memory

- (void)dealloc
{
    [super dealloc];
}

@end
