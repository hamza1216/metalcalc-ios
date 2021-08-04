//
//  MCSettingsViewController.h
//  ScrapCalc
//
//  Created by word on 11.04.13.
//
//

#import "BaseViewController.h"


typedef NS_ENUM(NSInteger, SettingsSection) {
    SettingsSectionHomeScreen,
    SettingsSectionCalculatorScreen,
    SettingsSectionCustomAssay,
    SettingsSectionCompanyDetails,
    SettingsSectionOther,
    SettingsSectionCount,
    SettingsSectionCurrencyScreen
};


@interface MCSettingsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ModelManagerDelegate> {
    UITableView *table_;
}

@property (nonatomic, assign) BOOL shouldPushPurchase;

@end
