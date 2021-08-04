//
//  MCCustomAssayViewController_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCBaseViewController_iPad.h"
#import "MCBoldLabel.h"
#import "MCNumPad.h"


@interface MCCustomAssayViewController_iPad : MCBaseViewController_iPad <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MCNumPadDelegate>

@property (nonatomic, strong) IBOutlet MCBoldLabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet MCBoldLabel *proLabel;

@property (nonatomic, assign) Metal *metal;

@end
