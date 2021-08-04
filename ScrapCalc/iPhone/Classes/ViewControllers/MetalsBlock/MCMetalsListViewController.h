//
//  MCNewsListViewController.h
//  ScrapCalc
//
//  Created by word on 11.04.13.
//
//

#import "BaseViewController.h"
#import "ModelManager.h"

@interface MCMetalsListViewController : BaseViewController <UITableViewDataSource,
                                                            UITableViewDelegate,
                                                            UIAlertViewDelegate,
                                                            ModelManagerDelegate>

{
    BOOL shouldReload_;
    UIImageView *reloadArrowView_;
    UILabel *reloadTextLabel_;
    UILabel *currencyLabel_;
    UILabel *datetimeLabel_;
    
    BOOL bReload;
}

@property (nonatomic, retain) IBOutlet UITableView *table;

@end
