//
//  MCCalculatorViewController.h
//  ScrapCalc
//
//  Created by word on 21.03.13.
//
//

#import "BaseViewController.h"
#import "MCScrollView.h"
#import "MCPurchaseSummaryView.h"
#import "MCChartsView.h"
#import "ModelManager.h"
#import "MCBoldLabel.h"
#import "DotTextField.h"
#import "MCDiamondViewController.h"
#import "MCNumPad.h"
#import "SPPickerView.h"


@interface MCCalculatorViewController : BaseViewController <MCScrollViewDelegate, MCPurchaseSummaryViewDelegate, MCChartsViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, ModelManagerDelegate, MCBoldLabelDelegate, MCNumPadDelegate> {
    SPPickerView *unitPicker_;
    NSInteger selectedPurityIndex_;
    NSInteger selectedUnitIndex_;
    double subtotal_;
    
    MCDiamondViewController *diamondVC_;
}

@property (nonatomic, retain) IBOutlet MCScrollView *scroll;
@property (nonatomic, retain) IBOutlet MCPurchaseSummaryView *summaryView;
@property (nonatomic, retain) IBOutlet MCChartsView *chartsView;

@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UILabel *spotLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;

@property (nonatomic, retain) IBOutlet UIView *calculateView;
@property (nonatomic, retain) IBOutlet UITextField *calculateWeightTextField;
@property (nonatomic, retain) IBOutlet UITextField *calculateSpotTextField;
@property (nonatomic, retain) IBOutlet UIView *calculateSpotBgView;
@property (nonatomic, retain) IBOutlet UILabel *calculateUnitLabel;
@property (nonatomic, retain) IBOutlet UIView *calculatePurityView;

@property (nonatomic, retain) IBOutlet UILabel *ofSpotLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtotalPriceLabel;
@property (nonatomic, retain) IBOutlet DotTextField *manualPriceTextField;

@property (nonatomic, assign) NSInteger selectMetalAfterLoad;

- (void)selectMetal:(Metal *)metal;

- (void)setupAsSimpleCalc;
- (void)setupAsDiamondCalc;

@end
