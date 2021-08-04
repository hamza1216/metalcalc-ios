//
//  MCToolbarView.h
//  Solution
//
//  Created by Domovik on 07.08.13.
//  Copyright (c) 2013 Domovik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTabBar_iPad.h"

#define TOOLBAR_FRAME_FULL      CGRectMake(0, 0, 1024, 45)
#define TOOLBAR_FRAME_BAR       CGRectMake(0, 0,  650, 37)


typedef NS_ENUM(NSInteger, MCTabContent)
{
    MCTabMetalList  = 0,
    MCTabClients    = 1,
    MCTabPurchases  = 2,
    MCTabSettings   = 3,
    MCTabItemsCount
};


@protocol MCToolbarViewDelegate

@optional
- (void)toolbarDidSelectItemAtIndex:(NSInteger)index;

@end


@interface MCToolbarView : UIView <MCTabBarDelegate>

@property (nonatomic, readonly) MCTabBar_iPad *tabBar;
@property (nonatomic, assign) NSObject<MCToolbarViewDelegate> *delegate;
@property (nonatomic, retain) UIButton *leftButton;
@property (nonatomic, retain) UIButton *rightButton;

- (void)selectTabIndex:(NSInteger)index;

@end
