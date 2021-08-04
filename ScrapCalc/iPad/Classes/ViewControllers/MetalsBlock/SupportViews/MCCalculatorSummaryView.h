//
//  MCCalculatorSummaryView.h
//  ScrapCalc
//
//  Created by Domovik on 01.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MCBoldLabel.h"
#import "MCRegularLabel.h"
#import "MCSummaryCell_iPad.h"

#define SUMMARY_BG_NORM_PORTRAIT    @"calculator_bottom_slide_portrait_norm.png"
#define SUMMARY_BG_NORM_LANDSCAPE   @"calculator_bottom_slide_norm.png"
#define SUMMARY_BG_NORM_FULL        @"calculator_bottom_slide_full.png"

#define SUMMARY_FRAME_PORTRAIT      CGRectMake(0, 588, 694, 368)
#define SUMMARY_FRAME_LANDSCAPE     CGRectMake(0, 512, 680, 184)
#define SUMMARY_FRAME_FULL_P        CGRectMake(0, 356, 694, 600)
#define SUMMARY_FRAME_FULL_L        CGRectMake(0, 166, 680, 530)

#define SUMMARY_TABLE_FRAME_L       CGRectMake(0, 190, 680, 338)
#define SUMMARY_TABLE_FRAME_P       CGRectMake(0, 190, 694, 176)
#define SUMMARY_TABLE_FRAME_FULL_P  CGRectMake(0, 190, 694, 408)


@protocol MCCalculatorSummaryViewDelegate

@required
- (void)summaryShouldSelectClient;

@optional
- (void)summaryWillResizeToFullMode;
- (void)summaryWillResizeToNormalMode;

@end


@interface MCCalculatorSummaryView : UIView <MCBoldLabelDelegate, MCSummaryCellDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet MCBoldLabel *totalLabel;
@property (nonatomic, retain) IBOutlet MCRegularLabel *numberLabel;
@property (nonatomic, retain) IBOutlet UITableView *table;

@property (nonatomic, assign) IBOutlet NSObject<MCCalculatorSummaryViewDelegate> *delegate;

@property (nonatomic, assign) BOOL isPortrait;
@property (nonatomic, assign) BOOL isFullSize;
- (void)setIsFullSize:(BOOL)isFullSize animated:(BOOL)animated;

- (void)reloadSummary;
- (void)updateWithPurchase:(Purchase *)purchase;
- (void)savePurchase;

@end
