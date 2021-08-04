//
//  MCDetailedPurchaseViewController.h
//  ScrapCalc
//
//  Created by word on 19.03.13.
//
//

#import "BaseViewController.h"
#import "PurchaseView.h"

@interface MCDetailedPurchaseViewController : BaseViewController

@property (nonatomic, retain) IBOutlet UILabel *clientLabel;
@property (nonatomic, retain) IBOutlet PurchaseView *purchaseView;
@property (nonatomic, retain) IBOutlet UIView *clientView;
@property (nonatomic, retain) Purchase *purchase;

- (NSString*) makeHTMLTextForAirPrint;
@end
