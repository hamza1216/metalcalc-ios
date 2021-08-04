//
//  MCPurchasesViewController.h
//  ScrapCalc
//
//  Created by word on 18.03.13.
//
//

#import "BaseViewController.h"
#import "ModelManager.h"
#import <MessageUI/MessageUI.h>

@interface MCPurchasesViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    UITableView *table_;
    NSMutableDictionary *items_;
    NSMutableArray *keys_;
}

@property (nonatomic, retain) Client *associateClient;

@end
