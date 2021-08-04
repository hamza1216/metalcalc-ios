//
//  SPSplitViewController.m
//  Solution
//
//  Created by Domovik on 06.08.13.
//  Copyright (c) 2013 Domovik. All rights reserved.
//

#import "SPSplitViewController.h"


typedef void (^SplitAnimationBlock)();
typedef void (^SplitCompletionBlock)(BOOL);


@interface SPSplitViewController ()

@property (nonatomic, strong) UIViewController *masterVC;
@property (nonatomic, strong) UIViewController *detailVC;

@property (nonatomic, assign) CGRect frameMaster;
@property (nonatomic, assign) CGRect frameDetail;
@property (nonatomic, assign) CGRect framePortrait;
@property (nonatomic, assign) CGRect framePortraitPrev;
@property (nonatomic, assign) CGRect framePortraitNext;
@property (nonatomic, assign) CGRect frameLandscapeFull;


@end


@implementation SPSplitViewController

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        self.widthOfMaster = kSPSplitViewController_MasterWidth;
    }
    return self;
}


#pragma mark - Private

- (void)_createFrames
{
    self.frameMaster        = CGRectMake(   0, IOS_20, 320,  748);
    self.frameDetail        = CGRectMake( 320, IOS_20, 704,  748);
    self.framePortrait      = CGRectMake(   0, IOS_20, 768, 1004);
    self.framePortraitPrev  = CGRectMake(-768, IOS_20, 768, 1004);
    self.framePortraitNext  = CGRectMake( 768, IOS_20, 768, 1004);
    self.frameLandscapeFull = CGRectMake( 148, IOS_20, 768,  748);
    
    
    // I was really tired of this...
    
    /*CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    CGFloat mw = self.widthOfMaster;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        w -= 20;
        h += 20;
    }
    
    self.frameMaster   = CGRectMake( 0, 0,   mw, w);
    self.frameDetail   = CGRectMake(mw, 0, h-mw, w);
    
    w += 20;
    h -= 20;    
    self.framePortrait = CGRectMake( 0, 0, w, h);
    
    self.framePortraitPrev = CGRectMake(-w, 0, w, h);
    self.framePortraitNext = CGRectMake( w, 0, w, h);*/
}

- (void)_setupFramesForOrientation:(UIInterfaceOrientation)orientation
{
    [self setupFramesForPortrait:UIInterfaceOrientationIsPortrait(orientation)];
}


#pragma mark - Public

- (void)setupFramesForPortrait:(BOOL)isPortrait
{
    if (isPortrait) {
        if (self.showMasterOnRotateToPortrait) {
            self.masterVC.view.frame = self.framePortrait;
            self.detailVC.view.frame = self.framePortraitNext;
        }
        else {
            if (CGRectEqualToRect(self.masterVC.view.frame, self.framePortrait)) {
                self.masterVC.view.frame = self.framePortrait;
                self.detailVC.view.frame = self.framePortraitNext;
            }
            else {
                self.masterVC.view.frame = self.framePortraitPrev;
                self.detailVC.view.frame = self.framePortrait;
            }
        }
    }
    else {
        if (self.showOnlyMasterInLandscape) {
            self.masterVC.view.frame = self.frameLandscapeFull;
            self.detailVC.view.frame = CGRectZero;
        }
        else {
            self.masterVC.view.frame = self.frameMaster;
            self.detailVC.view.frame = self.frameDetail;
        }
    }
}

- (void)update
{
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    [self _createFrames];
    [self _setupFramesForOrientation:orientation];
}

- (void)pushDetailAnimated:(BOOL)animated
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        return;
    }
    
    [self _sendForViewController:self.masterVC appear:NO  will:YES animated:animated];
    [self _sendForViewController:self.detailVC appear:YES will:YES animated:animated];
    
    if (self.masterVC.view.frame.origin.x > -1) {
        
        SplitAnimationBlock block = ^{
            self.masterVC.view.frame = self.framePortraitPrev;
            self.detailVC.view.frame = self.framePortrait;
        };
        
        SplitCompletionBlock completion = ^(BOOL f) {
            [self _sendForViewController:self.masterVC appear:NO  will:NO animated:animated];
            [self _sendForViewController:self.detailVC appear:YES will:NO animated:animated];
        };
        
        
        if (animated) {
            [UIView animateWithDuration:0.5
                             animations:block
                             completion:completion];
        }
        else {
            block();
            completion(YES);
        }
    }
}

- (void)popToMasterAnimated:(BOOL)animated
{
    [self _sendForViewController:self.masterVC appear:YES will:YES animated:animated];
    [self _sendForViewController:self.detailVC appear:NO  will:YES animated:animated];
    
    if (self.masterVC.view.frame.origin.x < 0) {
        
        SplitAnimationBlock block = ^{
            self.masterVC.view.frame = self.framePortrait;
            self.detailVC.view.frame = self.framePortraitNext;
        };
        
        SplitCompletionBlock completion = ^(BOOL f) {
            [self _sendForViewController:self.masterVC appear:YES will:NO animated:animated];
            [self _sendForViewController:self.detailVC appear:NO  will:NO animated:animated];
        };
        
        
        if (animated) {
            [UIView animateWithDuration:0.5
                             animations:block
                             completion:completion];
        }
        else {
            block();
            completion(YES);
        }
    }
}

- (void)_sendForViewController:(UIViewController *)vc appear:(BOOL)appear will:(BOOL)will animated:(BOOL)animated
{
    if (will) {
        [vc willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
    }
    else {
        // did rotate ?
    }
    if ([vc respondsToSelector:@selector(pushViewController:animated:)]) {
        vc = [[(UINavigationController *)vc viewControllers] lastObject];
    }
    if (appear) {
        if (will) {
//            [vc viewWillAppear:animated];
        }
        else {
            [vc viewDidAppear:animated];
        }
    }
    else {
        if (will) {
//            [vc viewWillDisappear:animated];
        }
        else {
//            [vc viewDidDisappear:animated];
        }
    }
}

#pragma mark - Master/Detail management

- (void)setMasterViewController:(UIViewController *)masterViewController
{
    if (masterViewController != self.masterVC) {
        [self.masterVC.view removeFromSuperview];
        [self.masterVC removeFromParentViewController];
        
        self.masterVC = masterViewController;
        [self addChildViewController:self.masterVC];
        
        self.masterVC.view.autoresizingMask = 0;
        [self.view addSubview:self.masterVC.view];
    }
}

- (UIViewController *)masterViewController
{
    return self.masterVC;
}

- (void)setDetailViewController:(UIViewController *)detailViewController
{
    if (detailViewController != self.detailVC) {
        [self.detailVC.view removeFromSuperview];
        [self.detailVC removeFromParentViewController];
        
        self.detailVC = detailViewController;
        [self addChildViewController:self.detailVC];
        
        self.detailVC.view.autoresizingMask = 0;
        [self.view addSubview:self.detailVC.view];
    }
}

- (UIViewController *)detailViewController
{
    return self.detailVC;
}


#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self _setupFramesForOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

@end
