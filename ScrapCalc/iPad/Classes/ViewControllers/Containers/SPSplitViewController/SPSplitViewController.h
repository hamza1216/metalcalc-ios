//
//  SPSplitViewController.h
//  Solution
//
//  Created by Domovik on 06.08.13.
//  Copyright (c) 2013 Domovik. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSPSplitViewController_MasterWidth          320
#define kSPSplitViewController_TransitionDuration   0.5


@interface SPSplitViewController : UIViewController

@property (nonatomic, strong) UIViewController *masterViewController;
@property (nonatomic, strong) UIViewController *detailViewController;

@property (nonatomic, assign) CGFloat widthOfMaster;

@property (nonatomic, assign) BOOL showMasterOnRotateToPortrait;
@property (nonatomic, assign) BOOL showOnlyMasterInLandscape;

- (void)update;

- (void)pushDetailAnimated:(BOOL)animated;
- (void)popToMasterAnimated:(BOOL)animated;

- (void)setupFramesForPortrait:(BOOL)isPortrait;

@end
