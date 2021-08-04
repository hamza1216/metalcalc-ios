//
//  MCPurchaseSettingsViewController.h
//  ScrapCalc
//
//  Created by Domovik on 09.08.13.
//
//

#import "BaseViewController.h"

@interface MCPurchaseSettingsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, VersionManagerDelegate> {
    UITableView *table_;
    UILabel *statusLabel_;
}

@end
