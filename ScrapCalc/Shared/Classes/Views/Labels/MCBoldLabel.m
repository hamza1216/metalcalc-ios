//
//  MCBoldLabel.m
//  ScrapCalc
//
//  Created by word on 26.04.13.
//
//

#import "MCBoldLabel.h"

@implementation MCBoldLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = FONT_MYRIAD_BOLD(self.font.pointSize);
    
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    gestureRecognizer.delegate = self;
    [self addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    [tapGesture release];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)longTap:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(labelDidReceiveLongTap:)]) {
            [self.delegate labelDidReceiveLongTap:self];
        }
    }
}

- (void)singleTap:(UILongPressGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(labelDidReceiveSingleTap:)]) {
        [self.delegate labelDidReceiveSingleTap:self];
    }
}

@end
