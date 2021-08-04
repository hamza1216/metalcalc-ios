//
//  MCCalculateOptionsView.h
//  ScrapCalc
//
//  Created by Domovik on 01.08.13.
//
//

#import <UIKit/UIKit.h>
#import "DotTextField.h"
#import "MCBoldLabel.h"
#import "MCSemiboldLabel.h"
#import "SPPickerView.h"

#define OPTIONS_FRAME_PORTRAIT    CGRectMake(0, 205, 694, 414)
#define OPTIONS_FRAME_LANDSCAPE   CGRectMake(0, 129, 680, 414)


@protocol MCCalculateOptionsViewDelegate

@optional
- (void)optionsViewDidChange;

- (void)showOrHideNumPadForTextField:(DotTextField *)textField;
- (void)showPickerForLabel:(MCBoldLabel *)label;
- (void)selectRowInPicker:(NSInteger)row;

@end


@interface MCCalculateOptionsView : UIView <UITextFieldDelegate, MCBoldLabelDelegate>

@property (nonatomic, retain) IBOutlet DotTextField *weightTextField;
@property (nonatomic, retain) IBOutlet DotTextField *spotTextField;
@property (nonatomic, retain) IBOutlet MCBoldLabel *unitLabel;
@property (nonatomic, retain) IBOutlet MCBoldLabel *subtotalLabel;
@property (nonatomic, retain) IBOutlet UIView *purityView;

@property (nonatomic, retain) IBOutlet MCSemiboldLabel *ofSpotTextLabel;
@property (nonatomic, retain) IBOutlet UIImageView *ofSpotUpArrow;
@property (nonatomic, retain) IBOutlet UIImageView *ofSpotDownArrow;
@property (nonatomic, retain) IBOutlet UIImageView *ofSpotBackgroundImageView;

@property (nonatomic, assign) BOOL isPortrait;
@property (nonatomic, assign) IBOutlet NSObject<MCCalculateOptionsViewDelegate> *delegate;

- (void)updateForMetal:(Metal *)metal;
- (void)updateSubtotal;

@end
