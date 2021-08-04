//
//  MCNavigationController.h
//  ScrapCalc
//
//  Created by Domovik on 07.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MCSplitViewController.h"
#import "MCBaseViewController_iPad.h"


@class MCBaseViewController_iPad;


@interface MCNavigationController : UIViewController

@property (nonatomic, assign) MCSplitViewController *splitViewController;
@property (nonatomic, readonly) MCBaseViewController_iPad *topViewController;
@property (nonatomic, readonly) MCBaseViewController_iPad *rootViewController;

@property (nonatomic, retain) NSMutableArray *viewControllers;


- (id)initWithRootViewController:(MCBaseViewController_iPad *)rootViewController;

- (void)pushViewController:(MCBaseViewController_iPad *)viewController animated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;
- (void)popToRootViewControllerAnimated:(BOOL)animated;

- (void)setupForPortrait;
- (void)setupForLandscape;

@end
