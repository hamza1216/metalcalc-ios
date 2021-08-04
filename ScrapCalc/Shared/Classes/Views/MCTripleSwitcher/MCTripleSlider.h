//
//  MCTripleSlider.h
//  ScrapCalc
//
//  Created by Diana on 28.08.13.
//
//

#import <UIKit/UIKit.h>
#import "PushOption.h"

@class MCTripleSlider;

@protocol MCTripleSliderDelegate <NSObject>

- (void)tripleSlider:(MCTripleSlider *)slider didChangeValue:(NSInteger)value;

@end

@interface MCTripleSlider : UIView

@property (nonatomic, assign) id<MCTripleSliderDelegate>delegate;
@property (nonatomic) PushOptionType currentType;

@end
