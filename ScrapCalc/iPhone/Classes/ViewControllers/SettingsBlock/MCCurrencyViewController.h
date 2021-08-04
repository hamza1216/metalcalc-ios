//
//  MCCurrencyViewController.h
//  ScrapCalc
//
//  Created by word on 18.04.13.
//
//

#import "BaseViewController.h"

@interface MCCurrencyViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
    NSMutableArray *keys_;
    NSMutableDictionary *items_;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UISearchBar *search;

@end
