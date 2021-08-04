//
//  MCCalculatorTopSlideView.h
//  ScrapCalc
//
//  Created by Domovik on 31.07.13.
//
//

#import <UIKit/UIKit.h>
#import "MCBoldLabel.h"
#import "MCSemiboldLabel.h"
#import "DotTextField.h"
#import "MCChartsView_iPad.h"

#define TOPSLIDE_BG_NORM_PORTRAIT   @"calculator_top_slide_portrait_norm.png"
#define TOPSLIDE_BG_NORM_LANDSCAPE  @"calculator_top_slide_norm.png"
#define TOPSLIDE_BG_NORM_FULL       @"calculator_top_slide_full.png"

#define TOP_SLIDE_FRAME_PORTRAIT    CGRectMake(0, 0, 694, 242)
#define TOP_SLIDE_FRAME_LANDSCAPE   CGRectMake(0, 0, 680, 166)
#define TOP_SLIDE_FRAME_FULL_P      CGRectMake(0, 0, 694, 582)
#define TOP_SLIDE_FRAME_FULL_L      CGRectMake(0, 0, 680, 516)

#define CHARTS_FRAME_PORTRAIT       CGRectMake(25, 80, 644, 360)
#define CHARTS_FRAME_LANDSCAPE      CGRectMake(18, 20, 644, 360)

#define CHANGE_RED_COLOR            0xba0000
#define CHANGE_GREEN_COLOR          0x2d6910
#define CHANGE_GRAY_COLOR           0x868686


@protocol MCCalculatorTopSlideViewDelegate

@optional
- (void)topSlideWillResizeToFullMode;
- (void)topSlideWillResizeToNormalMode;
- (void)topSlideDidChangeMetalPrice;

- (void)showOrHideNumPadForTextField:(DotTextField *)textField;

@end


@interface MCCalculatorTopSlideView : UIView <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet MCBoldLabel *priceLabel;
@property (nonatomic, retain) IBOutlet MCSemiboldLabel *changeLabel;
@property (nonatomic, retain) IBOutlet MCSemiboldLabel *datetimeLabel;
@property (nonatomic, retain) IBOutlet DotTextField *manualPriceTextField;

@property (nonatomic, retain) IBOutlet MCChartsView_iPad *chartsView;

@property (nonatomic, assign) BOOL isPortrait;
@property (nonatomic, assign) IBOutlet NSObject<MCCalculatorTopSlideViewDelegate> *delegate;

@property (nonatomic, assign) BOOL isFullSize;
- (void)setIsFullSize:(BOOL)isFullSize animated:(BOOL)animated;

- (void)updateForMetal:(Metal *)metal;

@end
