//
//  MCMetalCalculatorViewController_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 30.07.13.
//
//

#import "MCBaseDetailViewController_iPad.h"
#import "MCMetalsListViewController_iPad.h"
#import "MCCalculatorTopSlideView.h"
#import "MCCalculateOptionsView.h"
#import "MCCalculatorSummaryView.h"
#import "MCDiamondViewController_iPad.h"
#import "MCNumPad.h"


@protocol MCMetalsListDelegate;

@protocol MCMetalCalculatorDelegate

- (void)metalCalcDidChangePriceManually;

@end


@interface MCMetalCalculatorViewController_iPad : MCBaseDetailViewController_iPad
<
MCCalculatorTopSlideViewDelegate,
MCCalculateOptionsViewDelegate,
MCCalculatorSummaryViewDelegate,
MCDiamondViewControllerDelegate,
MCNumPadDelegate
>

@property (nonatomic, retain) IBOutlet MCCalculatorTopSlideView *topSlideView;
@property (nonatomic, retain) IBOutlet MCCalculateOptionsView *optionsView;
@property (nonatomic, retain) IBOutlet MCCalculatorSummaryView *summaryView;

@property (nonatomic, retain) IBOutlet UIButton *rotateButton;

@property (nonatomic, assign) NSObject<MCMetalCalculatorDelegate> *delegate;

@end
