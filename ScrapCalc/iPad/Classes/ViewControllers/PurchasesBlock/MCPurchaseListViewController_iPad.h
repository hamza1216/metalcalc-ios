//
//  MCPurchaseListViewController.h
//  ScrapCalc
//
//  Created by Domovik on 05.08.13.
//
//

#import "MCBaseViewController_iPad.h"
#import "MCPurchasesBlockProtocol.h"
#import <MessageUI/MessageUI.h>

#define CLIENT_TABLE_FRAME_PORTRAIT        CGRectMake(0, 80, 690, 868)
#define CLIENT_TABLE_FRAME_LANDSCAPE       CGRectMake( 0, 16, 310, 700)
#define CLIENT_TABLE_FRAME_PORTRAIT_WITH_BACK        CGRectMake(0, 80, 690, 820)
#define CLIENT_TABLE_FRAME_LANDSCAPE_WITH_BACK       CGRectMake( 10, 80, 670, 620)



@interface MCPurchaseListViewController_iPad : MCBaseViewController_iPad <MCPurchaseDetailsViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
    NSMutableDictionary *items_;
    NSMutableArray *keys_;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) Client *associateClient;

@property (nonatomic, assign) id<MCPurchaseListViewControllerDelegate> delegate;

@end
