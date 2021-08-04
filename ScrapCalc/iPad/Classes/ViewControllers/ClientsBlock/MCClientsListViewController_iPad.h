//
//  MCClientsListViewController_iPad.h
//  ScrapCalc
//
//  Created by Diana on 31.07.13.
//
//

#import "MCBaseDetailViewController_iPad.h"
#import "MCClientsBlockProtocol.h"

#define CLIENT_TABLE_FRAME_PORTRAIT        CGRectMake(0, 80, 690, 868)
#define CLIENT_TABLE_FRAME_LANDSCAPE       CGRectMake( 0, 16, 310, 700)
#define CLIENT_TABLE_FRAME_PORTRAIT_WITH_BACK        CGRectMake(0, 80, 690, 820)
#define CLIENT_TABLE_FRAME_LANDSCAPE_WITH_BACK       CGRectMake( 10, 80, 670, 620)
@class Client;
@class MCBaseDetailViewController_iPad;

@interface MCClientsListViewController_iPad : MCBaseViewController_iPad <MCClientDetailsViewControllerDelegate>

@property (nonatomic, assign) BOOL selectClient;
@property (nonatomic, retain) Purchase *associatePurchase;
@property (nonatomic, assign) id<MCClientsListViewControllerDelegate> delegate;

@end
