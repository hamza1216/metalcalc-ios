//
//  AppDelegate_iPad.h
//  ScarpCalc
//
//  Created by admin on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MCSplitViewController.h"
#import "MCBaseViewController_iPad.h"

#define APP_DELEGATE_IPAD (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate]


@interface AppDelegate_iPad : AppDelegate

@property (nonatomic, strong) MCBaseViewController_iPad *rootViewController;
@property (nonatomic, strong) MCSplitViewController *splitViewController;
@property (nonatomic, retain) MCToolbarView *toolbarView;

@end