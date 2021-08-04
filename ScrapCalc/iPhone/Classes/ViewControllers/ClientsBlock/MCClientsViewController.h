//
//  MCClientsViewController.h
//  ScrapCalc
//
//  Created by word on 13.03.13.
//
//

#import "BaseViewController.h"
#import "ModelManager.h"

@interface MCClientsViewController : BaseViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    UITableView *table_;
    NSMutableDictionary *items_;
    NSMutableArray *keys_;
}

@property (nonatomic, assign) BOOL selectClient;
@property (nonatomic, retain) Purchase *associatePurchase;

@end
