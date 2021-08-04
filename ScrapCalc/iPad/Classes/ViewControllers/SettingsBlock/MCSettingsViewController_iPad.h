//
//  MCSettingsViewController_iPad.h
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCBaseViewController_iPad.h"
#import "MCSettingsCell_iPad.h"
#import "MCBoldLabel.h"


typedef NS_ENUM(NSInteger, MCSettingsSectionType) {
    MCSettingsSectionTypeHomeScreen,
    MCSettingsSectionTypeCalculator,
    MCSettingsSectionTypeCustomAssay,
    MCSettingsSectionTypeCompanyDetails,
    MCSettingsSectionTypeOther,
    MCSettingsSectionTypeCount
};

typedef NS_ENUM(NSInteger, MCSettingsCustomAssayType) {
    MCSettingsCustomAssayTypeGold,
    MCSettingsCustomAssayTypeSilver,
    MCSettingsCustomAssayTypeCount
};

typedef NS_ENUM(NSInteger, MCSettingsOtherType) {
    MCSettingsOtherTypePushNotifications,
    MCSettingsOtherTypePurchases,
    MCSettingsOtherTypeCurrency,
    MCSettingsOtherTerms,
    MCSettingsOtherPrivacyPolicy,
    MCSettingsOtherEnterCode,
    MCSettingsOtherTypeCount
};


@interface MCSettingsViewController_iPad : MCBaseViewController_iPad <UITableViewDataSource, UITableViewDelegate, MCSettingsCellDelegate, ModelManagerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet MCBoldLabel *titleLabel;

- (void)setupCell:(MCSettingsCell_iPad *)cell forIndexPath:(NSIndexPath *)indexPath;
- (void)pushPurchaseScreen;

@end
