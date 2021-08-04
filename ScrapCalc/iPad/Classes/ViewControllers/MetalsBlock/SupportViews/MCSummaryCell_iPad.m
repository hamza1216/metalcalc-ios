//
//  MCSummaryCell_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 05.08.13.
//
//

#import "MCSummaryCell_iPad.h"

@implementation MCSummaryCell_iPad

#pragma mark - IBActions

- (IBAction)removeAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(summaryCellDidReceiveRemoveAction:)]) {
        [self.delegate summaryCellDidReceiveRemoveAction:self];
    }
}

#pragma mark - Public

- (void)setupWithPurchaseItem:(PurchaseItem *)item
{
    self.weightLabel.text = [NSString stringWithWeight:item.weight];
    self.unitLabel.text   = item.unit.shortName.uppercaseString;
    self.purityLabel.text = item.purityName;
    self.metalLabel.text  = item.metal.name.uppercaseString;
    self.priceLabel.text  = [NSString stringWithPrice:item.price];
}

- (void)setRemoveButtonHidden:(BOOL)hidden
{
    self.removeButton.hidden = hidden;
}

@end
