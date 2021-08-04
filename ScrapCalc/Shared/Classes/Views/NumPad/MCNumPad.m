//
//  MCNumPad.m
//  ScrapCalc
//
//  Created by Domovik on 08.10.13.
//
//

#import "MCNumPad.h"

#define NUMPAD_TAG_DIGIT    1
#define NUMPAD_TAG_ZERO     10
#define NUMPAD_TAG_COMA     11
#define NUMPAD_TAG_CLEAR    12


@interface MCNumPad ()

@property (nonatomic, assign) IBOutlet UIImageView *arrowImageView;

@end


@implementation MCNumPad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _customInit];
    }
    return self;
}

- (void)_customInit
{
    self.decimalDigits = 2;
    self.text = [NSMutableString string];
}

- (void)awakeFromNib
{
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:UIButton.class]) {
            button.titleLabel.font = FONT_MYRIAD_BOLD(42);
            button.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
        }
    }
}

- (void)setupWithText:(NSString *)theText
{
    NSMutableString *str = [NSMutableString string];
    for (NSInteger i = 0; i < theText.length; ++i) {
        char ch = [theText characterAtIndex:i];
        if ((ch >= '0' && ch <= '9') || ch == '.') {
            [str appendFormat:@"%c", ch];
        }
    }
    self.text = str;
}

- (void)_sendChangeTextMessage
{
    if ([self.delegate respondsToSelector:@selector(numpadDidChangeText:)]) {
        [self.delegate numpadDidChangeText:self.text];
    }
}

- (IBAction)buttonTouched:(UIButton *)sender
{
    switch (sender.tag)
    {
        case NUMPAD_TAG_CLEAR:
        {
            // if text is not empty, remove last char
            if (self.text.length > 0) {
                [self.text deleteCharactersInRange:NSMakeRange(self.text.length-1, 1)];
                [self _sendChangeTextMessage];
            }
            break;
        }
            
        case NUMPAD_TAG_COMA:
        {
            // forbid second coma
            if ([self.text rangeOfString:@"."].location != NSNotFound) {
                break;
            }
            
            // if text is empty, enter leading zero for user-friendly float format (e.g. ".5" -> "0.5")
            if (self.text.length == 0) {
                [self.text appendString:@"0"];
            }
            
            [self.text appendString:@"."];
            [self _sendChangeTextMessage];
            break;
        }
            
        case NUMPAD_TAG_ZERO:
        {
            // allow only 2 digits after coma
            NSUInteger location = [self.text rangeOfString:@"."].location;
            if (location != NSNotFound && self.text.length > (self.decimalDigits+1) && location <= self.text.length-(self.decimalDigits+1)) {
                break;
            }
            
            // allow only 1 leading zero
            if ([self.text isEqualToString:@"0"]) {
                break;
            }
            
            [self.text appendString:@"0"];
            [self _sendChangeTextMessage];
            break;
        }
            
        default:
        {
            // allow only 2 digits after coma
            NSUInteger location = [self.text rangeOfString:@"."].location;
            if (location != NSNotFound && self.text.length > (self.decimalDigits+1) && location <= self.text.length-(self.decimalDigits+1)) {
                break;
            }
            
            // replace single zero with entered digit
            if ([self.text isEqualToString:@"0"]) {
                [self.text deleteCharactersInRange:NSMakeRange(0, 1)];
            }
            
            [self.text appendFormat:@"%d", (int)(sender.tag - NUMPAD_TAG_DIGIT + 1)];
            [self _sendChangeTextMessage];
            break;
        }
    }
}

- (void)setArrowCenterX:(CGFloat)x
{
    CGPoint center = self.arrowImageView.center;
    center.x = x - self.frame.origin.x;
    self.arrowImageView.center = center;
}

- (void)dealloc
{
    self.text = nil;
    [super dealloc];
}

@end
