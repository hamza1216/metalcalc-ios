//
//  MCSettingsCell_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MCSemiboldLabel.h"

#define SETTINGS_CELL_HEIGHT            67

#define SETTINGS_CELL_BG_IMAGE_NORM     @"settings_cell_background_norm"
#define SETTINGS_CELL_BG_IMAGE_SEL      @"settings_cell_background_sel"

#define SETTINGS_CELL_ARR_IMAGE_NORM    @"settings_arrow_norm.png"
#define SETTINGS_CELL_ARR_IMAGE_SEL     @"settings_arrow_sel.png"

#define SETTINGS_CELL_CHECK_IMAGE_SEL   @"settings_checkbutton.png"

#define SETTINGS_CELL_ARROW_FRAME       CGRectMake(0, 0, 24, 36)
#define SETTINGS_CELL_CHECK_FRAME       CGRectMake(0, 0, 38, 28)


typedef NS_ENUM(NSInteger, MCSettingsCellType) {
    MCSettingsCellTypeOnOff,
    MCSettingsCellTypeCheckbox,
    MCSettingsCellTypeDisclosure,
    MCSettingsCellTypeNone
};


@class MCSettingsCell_iPad;

@protocol MCSettingsCellDelegate

- (void)cell:(MCSettingsCell_iPad *)cell didChangeValue:(BOOL)newValue;

@optional

- (void)cellDidTapButton:(MCSettingsCell_iPad *)cell;

@end


@interface MCSettingsCell_iPad : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, retain) IBOutlet MCSemiboldLabel *titleLabel;
@property (nonatomic, retain) IBOutlet UISwitch *onOff;

@property (nonatomic, assign) MCSettingsCellType cellType;
@property (nonatomic, assign) BOOL isChecked;
- (void)setIsChecked:(BOOL)isChecked animated:(BOOL)animated;

@property (nonatomic, assign) NSObject<MCSettingsCellDelegate> *delegate;

@end
