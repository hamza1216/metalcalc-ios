//
//  MCMetalsListViewController_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 30.07.13.
//
//

#import "MCBaseViewController_iPad.h"
#import "MCMetalCalculatorViewController_iPad.h"

#define PULLDOWN_REFRESH_OFFSET     -48
#define PULLDOWN_TEXT_PULL          @"Pull down to \nrefresh Spot Prices"
#define PULLDOWN_TEXT_RELEASE       @"Release to \nrefresh Spot Prices"

#define TABLE_FRAME_PORTRAIT        CGRectMake(41, 48, 690, 900)
#define TABLE_FRAME_LANDSCAPE       CGRectMake( 6, 48, 310, 700)


@protocol MCMetalCalculatorDelegate;

@protocol MCMetalsListDelegate

- (void)metalsListDidSelectMetal:(Metal *)metal;
- (void)metalsListDidSelectDiamond;

@end


@interface MCMetalsListViewController_iPad : MCBaseViewController_iPad
<
UITableViewDataSource,
UITableViewDelegate,
ModelManagerDelegate
>

@property (nonatomic, retain) IBOutlet UITableView *table;

@property (nonatomic, retain) IBOutlet UIView *pulldownView;
@property (nonatomic, retain) IBOutlet UIImageView *pulldownArrowImageView;
@property (nonatomic, retain) IBOutlet UILabel *pulldownTextLabel;

@property (nonatomic, assign) NSObject<MCMetalsListDelegate> *delegate;

- (void)setPulldownHidden:(BOOL)isHidden;

@end
