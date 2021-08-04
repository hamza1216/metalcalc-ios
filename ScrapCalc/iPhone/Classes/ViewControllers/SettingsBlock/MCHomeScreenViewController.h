//
//  HomeScreenViewController.h
//  ScrapCalc
//
//  Created by Diana on 09.08.13.
//
//

#import "BaseViewController.h"

@interface MCHomeScreenViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *table;

- (UITableViewCell *)homeCellAtIndexPath:(NSIndexPath*)indexPath;

-(void)switcherAction:(UISwitch *)sender;

@end
