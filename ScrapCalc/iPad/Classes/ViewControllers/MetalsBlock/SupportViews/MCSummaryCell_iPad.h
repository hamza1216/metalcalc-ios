//
//  MCSummaryCell_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 05.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MCBoldLabel.h"


@class MCSummaryCell_iPad;


@protocol MCSummaryCellDelegate

@optional
- (void)summaryCellDidReceiveRemoveAction:(MCSummaryCell_iPad *)cell;

@end


@interface MCSummaryCell_iPad : UITableViewCell

@property (nonatomic, retain) IBOutlet MCBoldLabel *weightLabel;
@property (nonatomic, retain) IBOutlet MCBoldLabel *unitLabel;
@property (nonatomic, retain) IBOutlet MCBoldLabel *purityLabel;
@property (nonatomic, retain) IBOutlet MCBoldLabel *metalLabel;
@property (nonatomic, retain) IBOutlet MCBoldLabel *priceLabel;
@property (nonatomic, retain) IBOutlet UIButton *removeButton;

@property (nonatomic, assign) NSObject<MCSummaryCellDelegate> *delegate;

- (IBAction)removeAction:(id)sender;

- (void)setupWithPurchaseItem:(PurchaseItem *)item;
- (void)setRemoveButtonHidden:(BOOL)hidden;

@end
