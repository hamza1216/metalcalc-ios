//
//  MCSplitViewController.h
//  ScrapCalc
//
//  Created by Domovik on 31.07.13.
//
//

#import <UIKit/UIKit.h>
#import "SPSplitViewController.h"
#import "MCToolbarView.h"


@interface MCSplitViewController : SPSplitViewController <MCToolbarViewDelegate>

@property (nonatomic, strong) MCToolbarView *toolbar;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL shouldPresentPurchaseScreen;

@end
