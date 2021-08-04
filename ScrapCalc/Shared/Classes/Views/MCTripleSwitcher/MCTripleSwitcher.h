//
//  MCTripleSwitcher.h
//  ScrapCalc
//
//  Created by Diana on 29.08.13.
//
//

#import <UIKit/UIKit.h>
#import "PushOption.h"

@class MCTripleSwitcher;

@protocol MCTripleSwitcherDelegate <NSObject>

- (void)tripleSwitcher:(MCTripleSwitcher *)slider didChangeValue:(NSInteger)value;

@end

@interface MCTripleSwitcher : UIView

@property (nonatomic) BOOL isFullSize;
@property (nonatomic, assign) id<MCTripleSwitcherDelegate>delegate;
@property (nonatomic) PushOptionType currentType;

- (void)setCurrentType:(PushOptionType)currentType animated:(BOOL)animated;

@end
