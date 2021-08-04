//
//  MCPurchaseView_iPad.h
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MCBoldLabel.h"

@interface MCPurchaseView_iPad : UIView <UITableViewDataSource, UITableViewDelegate> {
    UITableView *table_;
    MCBoldLabel *totalTextLabel_;
    MCBoldLabel *totalValueLabel_;
    UIImageView *separatorImageView_;
}

@property (nonatomic, assign) CGFloat headerHeight;

- (void)setupWithPurchase:(Purchase *)thePurchase;

@end
