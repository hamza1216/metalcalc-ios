//
//  MCCustomAssayViewController.h
//  ScrapCalc
//
//  Created by word on 15.04.13.
//
//

#import "BaseViewController.h"

@class Metal;

@interface MCCustomAssayViewController : BaseViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIView *activeView;
@property (nonatomic, retain) IBOutlet UILabel *proLabel;
@property (nonatomic, retain) Metal *metal;

@end
