//
//  MCBoldLabel.h
//  ScrapCalc
//
//  Created by word on 26.04.13.
//
//

#import <UIKit/UIKit.h>


@class MCBoldLabel;


@protocol MCBoldLabelDelegate <NSObject>

@optional
- (void)labelDidReceiveLongTap:(MCBoldLabel *)label;
- (void)labelDidReceiveSingleTap:(MCBoldLabel *)label;

@end


@interface MCBoldLabel : UILabel <UIGestureRecognizerDelegate>

@property (nonatomic, assign) IBOutlet NSObject<MCBoldLabelDelegate> *delegate;

@end
