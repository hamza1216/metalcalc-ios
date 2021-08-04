//
//  MCPurchasesBlockProtocol.h
//  ScrapCalc
//
//  Created by Diana on 12.08.13.
//
//

#import <Foundation/Foundation.h>

@protocol MCPurchaseListViewControllerDelegate <NSObject>

- (void)purchaseListDidSelectPurchase:(Purchase *)purchase;

@end

@protocol MCPurchaseDetailsViewControllerDelegate <NSObject>

- (void)setAddPurchaseButtonHidden:(BOOL)hidden;

@end