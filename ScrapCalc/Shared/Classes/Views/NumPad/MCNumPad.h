//
//  MCNumPad.h
//  ScrapCalc
//
//  Created by Domovik on 08.10.13.
//
//

#import <UIKit/UIKit.h>


@protocol MCNumPadDelegate

@optional
- (void)numpadDidChangeText:(NSString *)text;

@end


@interface MCNumPad : UIView

@property (nonatomic, retain) NSMutableString *text;
@property (nonatomic, assign) CGFloat decimalDigits;    // by default 2
@property (nonatomic, assign) NSObject<MCNumPadDelegate> *delegate;

- (void)setupWithText:(NSString *)theText;
- (void)setArrowCenterX:(CGFloat)x;

@end
