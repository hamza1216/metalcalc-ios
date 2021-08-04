//
//  MCNavigationController.m
//  ScrapCalc
//
//  Created by Domovik on 07.08.13.
//
//

#import "MCNavigationController.h"


@interface MCNavigationController ()

@end


@implementation MCNavigationController

- (id)initWithRootViewController:(MCBaseViewController_iPad *)rootViewController
{
    self = [super init];
    if (self) {
        
        self.viewControllers = [NSMutableArray array];;
        
        rootViewController.navigationViewController = self;
        [self.view addSubview:rootViewController.view];
        [self addChildViewController:rootViewController];
        [self.viewControllers addObject:rootViewController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
}

- (MCBaseViewController_iPad *)topViewController
{
    if (self.viewControllers.count < 1) {
        return nil;
    }
    return self.viewControllers.lastObject;
}

- (MCBaseViewController_iPad *)rootViewController
{
    if (self.viewControllers.count < 1) {
        return nil;
    }
    return self.viewControllers[0];
}


#pragma mark - Transition management

- (void)pushViewController:(MCBaseViewController_iPad *)viewController animated:(BOOL)animated
{
    CGRect frame = self.view.bounds;
    
    CGRect rFrame = frame;
    rFrame.origin.x += rFrame.size.width;
    
    CGRect lFrame = frame;
    lFrame.origin.x -= rFrame.size.width;
    
    UIViewController *topVC = self.viewControllers.lastObject;
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    viewController.view.frame = rFrame;
    [self.view addSubview:viewController.view];
    [self addChildViewController:viewController];
    [self.viewControllers addObject:viewController];
    
    viewController.navigationViewController = self;
    [self _updateViewController:viewController forOrientation:topVC.interfaceOrientation];
    
    [viewController viewWillAppear:animated];
    [topVC viewWillDisappear:animated];
    
    
    AnimationBlock block = ^(void) {
        viewController.view.frame = frame;
        topVC.view.frame = lFrame;
    };
    
    CompletionBlock completionBlock = ^(BOOL finished) {
        topVC.view.hidden = YES;
        [topVC viewDidDisappear:animated];
        [viewController viewDidAppear:animated];
    };
        
    if (animated) {
        [UIView animateWithDuration:0.5
                         animations:block
                         completion:completionBlock];
    }
    else {
        block();
        completionBlock(YES);
    }
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    if (self.viewControllers.count < 2) {
        return;
    }
    
    UIViewController *rmVC = self.viewControllers.lastObject;
    UIViewController *nextVC = self.viewControllers[self.viewControllers.count-2];
    
    CGRect frame = self.view.bounds;
    
    CGRect rFrame = frame;
    rFrame.origin.x += rFrame.size.width;
    
    CGRect lFrame = frame;
    lFrame.origin.x -= rFrame.size.width;
    
    nextVC.view.frame = lFrame;
    nextVC.view.hidden = NO;
    
    [self _updateViewController:nextVC forOrientation:rmVC.interfaceOrientation];
    
    [rmVC viewWillDisappear:animated];
    [nextVC viewWillAppear:animated];
    
    
    AnimationBlock block = ^(void) {
        rmVC.view.frame = rFrame;
        nextVC.view.frame = frame;
    };
    
    CompletionBlock completionBlock = ^(BOOL finished) {
        [rmVC.view removeFromSuperview];
        [rmVC removeFromParentViewController];
        [self.viewControllers removeObject:rmVC];
        
        [rmVC viewDidDisappear:animated];
        [nextVC viewDidAppear:animated];
        nextVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.5
                         animations:block
                         completion:completionBlock];
    }
    else {
        block();
        completionBlock(YES);
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    while (self.viewControllers.count > 2) {
        [self popViewControllerAnimated:NO];
    }
    [self popViewControllerAnimated:animated];
}

- (void)_updateViewController:(UIViewController *)vc forOrientation:(UIInterfaceOrientation)orientation
{
    [vc willRotateToInterfaceOrientation:orientation duration:0];
}


#pragma mark - Setup

- (void)setupForPortrait
{
    [self.topViewController willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0];
}

- (void)setupForLandscape
{
    [self.topViewController willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:0];
}


#pragma mark - Autorotaiton

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"%@", NSStringFromCGRect(self.view.bounds));
}


#pragma mark - Memory management

- (void)dealloc
{    
    self.viewControllers = nil;
    [super dealloc];
}

@end
