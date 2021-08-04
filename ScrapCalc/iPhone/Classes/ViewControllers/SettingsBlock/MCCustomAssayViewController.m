//
//  MCCustomAssayViewController.m
//  ScrapCalc
//
//  Created by word on 15.04.13.
//
//

#import "MCCustomAssayViewController.h"
#import "ModelManager.h"

#define ASSAY_Y_OFFSET          60
#define ASSAY_FIELD_WIDTH       68
#define ASSAY_FIELD_HEIGHT      27
#define ASSAY_FIELD_FRAME(y)    CGRectMake((self.view.frame.size.width-ASSAY_FIELD_WIDTH)/2, y, ASSAY_FIELD_WIDTH, ASSAY_FIELD_HEIGHT)


@implementation MCCustomAssayViewController

@synthesize activeView;
@synthesize proLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationTitle:self.metal.name.uppercaseString];
    
    CGFloat y = ASSAY_Y_OFFSET;
    NSInteger cnt = 0;
    
    BOOL pro = [[ModelManager shared] isProVersion];
    self.proLabel.hidden = pro;
    [self initBackButton];
    for (NSDictionary *purity in self.metal.purities) {
        
        UITextField *field = [[UITextField alloc] initWithFrame:ASSAY_FIELD_FRAME(y)];
        field.textAlignment = NSTextAlignmentCenter;
        field.delegate = self;
        field.borderStyle = UITextBorderStyleRoundedRect;
        field.tag = cnt++;
        field.enabled = pro;
        
        NSString *text = [[NSString stringWithFormat:@"%.5lf", [purity.allValues[0] doubleValue]] substringFromIndex:1];
        while ([text hasSuffix:@"0"] && text.length > 4) {
            text = [text substringToIndex:text.length - 1];
        }
        
        if (pro) {
            field.text = text;
        }
        else {
            field.placeholder = text;
        }
        
        [self.activeView addSubview:field];
        [field release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(field.frame.origin.x - 60, y, 50, ASSAY_FIELD_HEIGHT)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentRight;
        label.text = purity.allKeys[0];
        [self.activeView addSubview:label];
        [label release];
        
        y += ASSAY_FIELD_HEIGHT + 17;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[[self metal] metalID] isEqualToString:@"1"])
    {
        [self setScreenName:GOLD_ASSAY_SCREEN_NAME];
    }
    else if ([[[self metal] metalID] isEqualToString:@"2"])
    {
        [self setScreenName:SILVER_ASSAY_SCREEN_NAME];
    }
}

- (void)moveActiveViewUp
{
    [self moveActiveViewForY:-50];
}

- (void)moveActiveViewDown
{
    [self moveActiveViewForY:0];
}

- (void)moveActiveViewForY:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        self.activeView.frame = CGRectMake(0, y, self.view.frame.size.width, activeView.frame.size.height);
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag > 1) {
        CGFloat yFit = self.view.frame.size.height - ((self.metal.purities.count == textField.tag + 1) ? 211 : 255);
        [self moveActiveViewForY:yFit-textField.frame.origin.y];
    }
    else {
        [self moveActiveViewDown];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.doubleValue < 0.0000001) {
        textField.text = @".000";
    }
    if (textField.text.length < 4) {
        textField.text = [[NSString stringWithFormat:@"%.3lf", textField.text.doubleValue] substringFromIndex:1];
    }
    
    NSDictionary *purity = self.metal.purities[textField.tag];
    NSDictionary *newPurity = @{ purity.allKeys[0]:textField.text };
    [self.metal.purities replaceObjectAtIndex:textField.tag withObject:newPurity];
    [[ModelManager shared] updateMetal:self.metal withPurity:newPurity];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (![newText hasPrefix:@"."]) {
        return NO;
    }
    NSString *pattern = @"^.[0-9]{0,5}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:newText];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];
    [self moveActiveViewDown];
    return YES;
}

@end
