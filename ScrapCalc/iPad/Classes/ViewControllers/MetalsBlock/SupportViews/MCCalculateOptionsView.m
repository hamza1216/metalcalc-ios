//
//  MCCalculateOptionsView.m
//  ScrapCalc
//
//  Created by Domovik on 01.08.13.
//
//

#import "MCCalculateOptionsView.h"


@interface MCCalculateOptionsView ()
{
    NSInteger _selectedUnitRow;
    NSInteger _selectedPurity;
    NSMutableArray *_purityButtons;
    double _subtotalValue;
}

@property (nonatomic, assign) Metal *currentMetal;

@end


@implementation MCCalculateOptionsView

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)initialSetup
{
    self.backgroundColor = [UIColor clearColor];
    _purityButtons = [NSMutableArray new];
}

- (void)awakeFromNib
{
    self.weightTextField.font = FONT_MYRIAD_BOLD(42);
    self.spotTextField.font = FONT_MYRIAD_BOLD(42);
}

#pragma mark - Private

- (void)_setup
{
    self.frame = self.isPortrait ? OPTIONS_FRAME_PORTRAIT : OPTIONS_FRAME_LANDSCAPE;
}

- (void)_valueChanged
{
    [self updateSubtotal];
    if ([self.delegate respondsToSelector:@selector(optionsViewDidChange)]) {
        [self.delegate optionsViewDidChange];
    }
}

- (void)_updatePickerLabel
{
    self.unitLabel.text = [[[[ModelManager shared] unitForID:self.currentMetal.savedUnit isBase:self.currentMetal.isBaseMetal] shortName] uppercaseString];
}

- (void)_updatePurityView
{
    for (UIButton *btn in _purityButtons) {
        [btn removeFromSuperview];
    }
    [_purityButtons removeAllObjects];
    
    Metal *metal = self.currentMetal;
    if (metal.purities.count < 2) {
        return;
    }
    
    CGFloat w = self.purityView.frame.size.width / metal.purities.count;
    CGFloat h = self.purityView.frame.size.height + 10;
    _selectedPurity = -1;
    
    for (NSInteger i = 0; i < metal.purities.count; ++i) {
        NSString *name = [metal.purities[i] allKeys][0];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];        
        btn.frame = CGRectMake(i*w, 2, w, h);
        btn.titleLabel.font = FONT_MYRIAD_SEMIBOLD(48);
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        btn.tag = i;
        [btn addTarget:self action:@selector(_purityChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.purityView addSubview:btn];
        [_purityButtons addObject:btn];
        
        if ([name.lowercaseString isEqualToString:metal.savedPurity.lowercaseString]) {
            [self _purityChanged:btn];
        }
    }
}

- (void)_purityChanged:(UIButton *)sender
{
    UIButton *prevActiveButton = _selectedPurity < 0 ? nil : (UIButton *)_purityButtons[_selectedPurity];
    if (prevActiveButton != sender) {
        
        [prevActiveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];        
        [sender setTitleColor:ColorFromHexFormat(0xde8b14) forState:UIControlStateNormal];        
        
        self.currentMetal.savedPurity = [sender titleForState:UIControlStateNormal];
        [[ModelManager shared] updateMetalWithSavedOptions:self.currentMetal];
        
        _selectedPurity = sender.tag;
        [self updateSubtotal];
    }
}

- (double)_calcSubtotalWithWeightText:(NSString *)weightText andSpotText:(NSString *)spotText
{
    Metal *metal = self.currentMetal;
    
    if (_selectedPurity >= metal.purities.count) {
        _selectedPurity = 0;
    }
    
    double purityWeight = [[metal.purities[_selectedPurity] allValues][0] doubleValue];
    double unitWeight = [[[ModelManager shared] unitForID:metal.savedUnit isBase:metal.isBaseMetal] weight];
    if (metal.isBaseMetal) {
        unitWeight = 1 / unitWeight;
    }
    double baseUnitWeight = ([[[ModelManager shared] unitForID:metal.priceUnit isBase:metal.isBaseMetal] weight] / unitWeight) * weightText.doubleValue;
    double spot = spotText.doubleValue / 100;
    return metal.bidPrice * baseUnitWeight * spot * purityWeight;
}

#pragma mark - Public

- (void)setIsPortrait:(BOOL)isPortrait
{
    _isPortrait = isPortrait;
    [self _setup];
}

- (void)updateForMetal:(Metal *)metal
{
    self.currentMetal = metal;

    _selectedUnitRow = [[ModelManager shared] unitIndexForID:self.currentMetal.savedUnit isBase:self.currentMetal.isBaseMetal];
    [[self delegate] selectRowInPicker:_selectedUnitRow];
    [self _updatePickerLabel];
    
    [self.weightTextField resignFirstResponder];
    [self.spotTextField resignFirstResponder];    
    self.weightTextField.text = [NSString stringWithWeight:metal.savedWeight];
    self.spotTextField.text = [NSString stringWithWeight:metal.savedSpot];
    
    [self _updatePurityView];
    [self updateSubtotal];
}

- (void)updateSubtotal
{
    _subtotalValue = [self _calcSubtotalWithWeightText:self.weightTextField.text andSpotText:self.spotTextField.text];
    self.subtotalLabel.text = [NSString stringWithPrice:_subtotalValue];
    
    self.ofSpotTextLabel.hidden = self.ofSpotUpArrow.hidden = self.ofSpotDownArrow.hidden = self.spotTextField.hidden = ([[[ModelManager shared] settings] showPercent] == 0);
    self.ofSpotBackgroundImageView.image = [UIImage imageNamed:(([[[ModelManager shared] settings] showPercent] == 0) ? @"amount_boxes_nospot.png" : @"amount_boxes.png")];
}

#pragma mark - IBActions

- (IBAction)subtotalAction:(id)sender
{
    if (fabs(self.currentMetal.bidPrice) < 0.0000001) {
        return;
    }
    
    PurchaseItem *item = [PurchaseItem new];
    item.purchaseID = [[ModelManager shared] activePurchase].purchaseID;
    item.metal = self.currentMetal;
    item.purityName = [self.currentMetal.purities[_selectedPurity] allKeys][0];
    item.unit = [[ModelManager shared] unitForMetal:self.currentMetal];
    item.weight = self.weightTextField.text.doubleValue;
    item.price = _subtotalValue;
    
    [[ModelManager shared] addPurchaseItem:item];
    [item release];
    
    [self _valueChanged];
}

#pragma mark - Label Delegate

- (void)labelDidReceiveSingleTap:(MCBoldLabel *)label
{
    [[self delegate] showPickerForLabel:label];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.weightTextField || textField == self.spotTextField) {
        if ([self.delegate respondsToSelector:@selector(showOrHideNumPadForTextField:)]) {
            [self.delegate showOrHideNumPadForTextField:(DotTextField *)textField];
        }
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.weightTextField) {
        self.currentMetal.savedWeight = textField.text.doubleValue;
        [[ModelManager shared] updateMetalWithSavedOptions:self.currentMetal];
    }
    else if (textField == self.spotTextField) {
        self.currentMetal.savedSpot = textField.text.doubleValue;
        [[ModelManager shared] updateMetalWithSavedOptions:self.currentMetal];
    }
    [self _valueChanged];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    NSString *pattern = @"^[0-9.]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }
    
    NSString *tmp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (tmp.doubleValue > 999999) {
        return NO;
    }
    
    NSInteger delta = tmp.length - [tmp stringByReplacingOccurrencesOfString:@"." withString:@""].length;
    if (delta > 1) {
        return NO;
    }
    
    static NSInteger maxDecimalLength = 2;
    NSRange dotRange = [tmp rangeOfString:@"."];
    if (dotRange.location != NSNotFound && tmp.length - dotRange.location > maxDecimalLength+1) {
        return NO;
    }
    
    if (string.length > 0 && [string characterAtIndex:0] == '.' && textField.text.length < 1) {
        textField.text = @"0";
    }
    if ([textField.text isEqualToString:@"0"] && ([string doubleValue] != 0 || [string isEqualToString:@"0"])) {
        textField.text = @"";
    }
    
    return YES;
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    [self.weightTextField resignFirstResponder];
    [self.spotTextField resignFirstResponder];
}

#pragma mark - Memory management

- (void)dealloc
{
    [_purityButtons release];
    [super dealloc];
}

@end
