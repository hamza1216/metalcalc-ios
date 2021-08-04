//
//  MCPurchaseSummaryView.h
//  ScrapCalc
//
//  Created by word on 21.03.13.
//
//

#import <UIKit/UIKit.h>
#import "Purchase.h"

@protocol MCPurchaseSummaryViewDelegate

@optional
- (void)purchaseSummaryShouldMoveUp;
- (void)purchaseSummaryShouldMoveDown;

- (void)purchaseDidReceiveAddAction;
- (void)purchaseDidReceiveClearAction;

@end


@interface MCPurchaseSummaryView : UIView <UITableViewDataSource, UITableViewDelegate> {
    CGRect touchZone_;
    BOOL properTouch_;
    CGPoint startTouchPoint_;
    
    UILabel *totalTextLabel_;
    UILabel *totalValueLabel_;
    UILabel *numberLabel_;
    UIButton *addButton_;
    UIButton *clearButton_;
    
    UITableView *table_;
    UIImageView *headerBg_;
    UIImageView *separatorView_;
}

@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) NSObject<MCPurchaseSummaryViewDelegate> *delegate;
@property (nonatomic, assign) BOOL isFullSize;

- (void)setupWithPurchase:(Purchase *)purchase;
- (void)reload;

@end
