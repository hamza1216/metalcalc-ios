//
//  PurchaseView.h
//  ScrapCalc
//
//  Created by word on 19.03.13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Purchase.h"

@interface PurchaseView : UIView <UITableViewDataSource, UITableViewDelegate> {
    UITableView *table_;
    UILabel *totalTextLabel_;
    UILabel *totalValueLabel_;
    UIImageView *separatorImageView_;
}

@property (nonatomic, assign) CGFloat headerHeight;

- (void)setupWithPurchase:(Purchase *)thePurchase;

@end
