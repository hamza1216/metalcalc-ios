//
//  MCPushNotificationCell.h
//  ScrapCalc
//
//  Created by Diana on 09.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MCSettingsCell_iPad.h"
#import "MCTripleSwitcher.h"

@class MCPushNotificationCell;

@protocol MCPushNotificationsCellDelegate

- (void)cellDidTapButton:(MCPushNotificationCell *)cell;

@end

@interface MCPushNotificationCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *rangeButton;
@property (nonatomic, retain) IBOutlet UILabel *rangeLabel;
@property (nonatomic, retain) MCTripleSwitcher *switcher;
@property (nonatomic, assign) NSObject<MCPushNotificationsCellDelegate> *delegate;

- (void)setUpWithMetal:(Metal *)metal;
- (NSString *)titleForRangeButtonWithMetal:(Metal *)metal;

@end
