//
//  MCPurchaseDetailsViewController.h
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import "MCBaseDetailViewController_iPad.h"
#import "MCPurchaseListViewController_iPad.h"
#import "MCPurchasesBlockProtocol.h"

@class MCPurchaseView_iPad;

@interface MCPurchaseDetailsViewController_iPad : MCBaseDetailViewController_iPad <MCPurchaseListViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UILabel *clientLabel;
@property (nonatomic, retain) IBOutlet MCPurchaseView_iPad *purchaseView;
@property (nonatomic, retain) IBOutlet UIView *clientView;
@property (nonatomic, retain) Purchase *purchase;
@property (nonatomic, assign) id<MCPurchaseDetailsViewControllerDelegate> delegate;


@end
