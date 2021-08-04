//
//  MCCalculatorViewController.m
//  ScrapCalc
//
//  Created by word on 21.03.13.
//
//

#import "MCCalculatorViewController.h"
#import "MCClientsViewController.h"
#import "ModelManager.h"
#import "NSString+NumbersFormats.h"

#define PURCHASE_ANIMATION_DURATION     0.4f

#define PURCHASE_Y_FULL     164 + IOS_20
#define PURCHASE_Y_HIDED    298 + IOS_20

#define CHARTS_ANIMATION_DURATION       0.4f
#define CHARTS_FRAME_FULL               CGRectMake(0,   30 + IOS_20, 320, 360)
#define CHARTS_FRAME_HIDED              CGRectMake(0, -250 + IOS_20, 320, 374)

#define PICKER_FRAME                    CGRectMake(0,  193 + IOS_20, 320, 216)

#define PURITY_BUTTON_BASE_TAG          2000
#define MAX_POSSIBLE_AMOUNT             1000000000

#define ARR_UP_FRAME(ctrl)              CGRectMake(ctrl.frame.origin.x+ctrl.frame.size.width+dx, ctrl.frame.origin.y+ctrl.frame.size.height/2-dy-arrh, arrw, arrh)
#define ARR_DOWN_FRAME(ctrl)            CGRectMake(ctrl.frame.origin.x+ctrl.frame.size.width+dx, ctrl.frame.origin.y+ctrl.frame.size.height/2+dy, arrw, arrh)


@interface MCCalculatorViewController () <SPPickerViewDataSource, SPPickerViewDelegate>
{
    UIView *layoutView_;
}

@property (nonatomic, assign) Metal *currentMetal;
@property (nonatomic, assign) Purchase *activePurchase;

@property (nonatomic, retain) UIImageView *spotUpArrow;
@property (nonatomic, retain) UIImageView *spotDownArrow;

@property (nonatomic, assign) BOOL isDiamondCalculator;
@property (nonatomic, retain) MCNumPad *numPad;

@end

@implementation MCCalculatorViewController

@synthesize scroll;
@synthesize summaryView;

@synthesize priceLabel;
@synthesize spotLabel;
@synthesize dateLabel;

@synthesize calculateView;
@synthesize calculateWeightTextField;
@synthesize calculateSpotTextField;
@synthesize calculateSpotBgView;
@synthesize calculateUnitLabel;
@synthesize calculatePurityView;
@synthesize manualPriceTextField;

@synthesize ofSpotLabel;
@synthesize subtotalPriceLabel;
@synthesize currentMetal;

@synthesize selectMetalAfterLoad;
@synthesize spotDownArrow;
@synthesize spotUpArrow;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.spotLabel.font = FONT_MYRIAD_SEMIBOLD(21);
    self.spotLabel.textColor = ColorFromHexFormat(0x074258);
    self.dateLabel.font = FONT_MYRIAD_SEMIBOLD(15);
    self.dateLabel.textColor = ColorFromHexFormat(0x313131);
    
    scroll.scrollDelegate = self;
    [self _setupPicker];
    
    self.subtotalPriceLabel.adjustsFontSizeToFitWidth = YES;
    self.subtotalPriceLabel.minimumScaleFactor = 14;
    
    self.chartsView.frame = CHARTS_FRAME_HIDED;
    
    self.summaryView.frame = CGRectMake(0,  298, 320, IS_IPHONE_5_SCREEN?335:245);
    self.summaryView.headerHeight = 111;
    self.summaryView.delegate = self;
    
    selectedUnitIndex_ = [[ModelManager shared] selectedUnitIndex];
    
    if (self.selectMetalAfterLoad > 0) {
        [self updateScreen];
        [self selectMetal:[[ModelManager shared] metals][selectMetalAfterLoad-1]];
    }
    else {
        [self updateScreen];
    }
    
    CGFloat arrw = 10, arrh = 9;
    CGFloat dx = 1, dy = 2;
    
    UIImageView *weightUpArrow   = [self getArrowWithFrame:ARR_UP_FRAME(calculateWeightTextField)    down:NO];
    UIImageView *weightDownArrow = [self getArrowWithFrame:ARR_DOWN_FRAME(calculateWeightTextField)  down:YES];
    [self.calculateView addSubview:weightUpArrow];
    [self.calculateView addSubview:weightDownArrow];    
    
    UIImageView *unitUpArrow      = [self getArrowWithFrame:ARR_UP_FRAME(calculateUnitLabel)    down:NO];
    UIImageView *unitDownArrow    = [self getArrowWithFrame:ARR_DOWN_FRAME(calculateUnitLabel)  down:YES];
    unitUpArrow.frame   = CGRectMake(unitUpArrow.frame.origin.x, weightUpArrow.frame.origin.y, unitUpArrow.frame.size.width, unitUpArrow.frame.size.height);
    unitDownArrow.frame = CGRectMake(unitDownArrow.frame.origin.x, weightDownArrow.frame.origin.y, unitDownArrow.frame.size.width, unitDownArrow.frame.size.height);
    [self.calculateView addSubview:unitUpArrow];
    [self.calculateView addSubview:unitDownArrow];
    
    self.spotUpArrow    = [self getArrowWithFrame:ARR_UP_FRAME(calculateSpotTextField)      down:NO];
    self.spotDownArrow  = [self getArrowWithFrame:ARR_DOWN_FRAME(calculateSpotTextField)    down:YES];    
    [self.calculateView addSubview:self.spotUpArrow];
    [self.calculateView addSubview:self.spotDownArrow];
    
    self.manualPriceTextField.font = FONT_MYRIAD_BOLD(38);
    self.manualPriceTextField.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
    
    if (IS_IOS7) {
        for (UIView *sv in self.view.subviews) {
            CGRect frame = sv.frame;
            if (CGRectEqualToRect(frame, CHARTS_FRAME_HIDED)) {
                continue;
            }
            frame.origin.y += 20;
            sv.frame = frame;
        }
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
        statusBarView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:statusBarView];
        [statusBarView release];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    self.calculateSpotTextField.hidden = self.ofSpotLabel.hidden = self.calculateSpotBgView.hidden =
    self.spotDownArrow.hidden = self.spotUpArrow.hidden = [[[ModelManager shared] settings] showPercent] < 1;
    
    if ([[ModelManager shared] shouldSavePurchase]) {
        [self savePurchase];
        [[ModelManager shared] setShouldSavePurchase:NO];
    }
    
    [[ModelManager shared] setDelegate:self];
    [self updateScreen];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self isDiamondCalculator])
    {
        [self setScreenName:DIAMOND_CALCULATOR_SCREEN_NAME];
    }
    else
    {
        [self setScreenName:METAL_CALCULATOR_SCREEN_NAME];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [scroll updateScrollAnimated:NO];
    [[ModelManager shared] setDelegate:nil];
    [super viewWillDisappear:animated];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*if ([self.view.subviews containsObject:unitPicker_]) {
        [self unitAction:nil];
    }
    else {
        if ([self.calculateSpotTextField isFirstResponder]) {
            [self.calculateSpotTextField resignFirstResponder];
        }
        else if ([self.calculateWeightTextField isFirstResponder]) {
            [self.calculateWeightTextField resignFirstResponder];
        }
        else if ([self.manualPriceTextField isFirstResponder]) {
            [self.manualPriceTextField resignFirstResponder];
        }
    }*/
}

- (UIImageView *)getArrowWithFrame:(CGRect)frame down:(BOOL)down
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(down ? @"calc_arrow_down.png" : @"calc_arrow_up.png")]];
    imgView.frame = frame;
    return [imgView autorelease];
}

#pragma mark - MCScrollViewDelegate

- (void)scrollDidChangeIndex:(NSInteger)theIndex
{
    if ([self.view.subviews containsObject:unitPicker_]) {
        [unitPicker_ removeFromSuperview];
    }
    
    [self.calculateWeightTextField resignFirstResponder];
    [self.calculateSpotTextField resignFirstResponder];
    [self.manualPriceTextField resignFirstResponder];
    
    if (theIndex >= [[[ModelManager shared] metals] count]) {
        NSLog(@"setup for coins");
        return;
    }
    
    Metal *metal = [[ModelManager shared] metals][theIndex];
    [self updateScreenForMetal:metal];
}

#pragma mark - Private

- (void)_setupPicker
{
    
    unitPicker_ = [[SPPickerView alloc] initWithFrame:PICKER_FRAME];
    unitPicker_.backgroundColor = [UIColor whiteColor];
    unitPicker_.dataSource = self;
    unitPicker_.delegate = self;
    unitPicker_.rowFont = FONT_MYRIAD_BOLD(18);
    unitPicker_.selectedRowViewWidth = 290;
}

- (void)updateScreen
{
    if (scroll.dataSource.count < 1) {
        NSMutableArray *ds = [NSMutableArray array];
        for (Metal *met in [[ModelManager shared] metals]) {
            [ds addObject:met.name];
        }
        scroll.dataSource = ds;
        [scroll reloadData];
    }
    
    self.calculateSpotTextField.text = [NSString stringWithWeight:[[[ModelManager shared] settings] spot]];
    
    if (self.currentMetal) {
        [self updateScreenForMetal:self.currentMetal];
    }
    else {
        [self updateScreenForMetal:[[ModelManager shared] metals][0]];
    }
    
    self.activePurchase = [[ModelManager shared] activePurchase];
    [self.summaryView setupWithPurchase:self.activePurchase];
}

- (void)bidPriceSetupForMetal:(Metal *)metal
{
    if ([metal.bidPercent isEqualToString:@"0.0000%"] && metal.bidChange == 0.0) {
        self.spotLabel.text = @"0.00% 0.0000%";
        self.spotLabel.textColor = ColorFromHexFormat(0x868686);
        return;
    }
    
    BOOL plus = ([metal.bidPercent hasPrefix:@"+"]);
    
    self.spotLabel.text = [NSString stringWithFormat:@"%.2lf %@", metal.bidChange, metal.bidPercent];
    if (plus) {
        self.spotLabel.text = [@"+" stringByAppendingString:self.spotLabel.text];
    }
    
    if ([self.spotLabel.text hasPrefix:@"+"]) {
        self.spotLabel.textColor = ColorFromHexFormat(0x2d6910);
    }
    else {
        self.spotLabel.textColor = ColorFromHexFormat(0xba0000);
    }
}

- (void)updateScreenForMetal:(Metal *)metal
{
    [[ModelManager shared] setIsBaseMetal:metal.isBaseMetal];
    
    self.priceLabel.text = [NSString stringWithPrice:metal.bidPrice];
    [self bidPriceSetupForMetal:metal];
    self.dateLabel.text = metal.bidDatetime;
    
    self.calculateWeightTextField.text = [NSString stringWithWeight:metal.savedWeight];
    self.calculateUnitLabel.text = [[[[ModelManager shared] unitForID:metal.savedUnit] shortName] uppercaseString];
    self.calculateSpotTextField.text = [NSString stringWithWeight:metal.savedSpot];
    
    if (metal == currentMetal) {
        [self updateSubtotal];
        return;
    }    
    self.currentMetal = metal;    
    [self.chartsView changeMetal:metal];
    
    // Purities row
    
    NSArray *svArr = [NSArray arrayWithArray:calculatePurityView.subviews];
    for (UIView *sv in svArr) {
        [sv removeFromSuperview];
    }
    
    if (metal.purities.count < 2) {        
        [self updateSubtotal];
        return;
    }
    
    selectedPurityIndex_ = 0;
    CGFloat w = self.view.frame.size.width / metal.purities.count;
    for (NSInteger i = 0; i < metal.purities.count; ++i) {
        NSString *name = [metal.purities[i] allKeys][0];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*w, 0, w, calculatePurityView.frame.size.height+10);
        btn.titleLabel.font = FONT_MYRIAD_SEMIBOLD(21);
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        btn.tag = PURITY_BUTTON_BASE_TAG + i;
        [btn addTarget:self action:@selector(purityChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        [calculatePurityView addSubview:btn];
        
        if ([name.lowercaseString isEqualToString:metal.savedPurity.lowercaseString]) {
            [self purityChanged:btn];
        }
    }    
    [self updateSubtotal];
}

- (double)calcSubtotalWithWeightText:(NSString *)weightText andSpotText:(NSString *)spotText
{
    if (selectedPurityIndex_-PURITY_BUTTON_BASE_TAG >= currentMetal.purities.count) {
        selectedPurityIndex_ = PURITY_BUTTON_BASE_TAG;
    }
    
    double purityWeight = [[currentMetal.purities[selectedPurityIndex_ - PURITY_BUTTON_BASE_TAG] allValues][0] doubleValue];
    double unitWeight = [[[ModelManager shared] unitForID:self.currentMetal.savedUnit] weight];
    if (self.currentMetal.isBaseMetal) {
        unitWeight = 1 / unitWeight;
    }
    double baseUnitWeight = ([[[ModelManager shared] unitForID:currentMetal.priceUnit] weight] / unitWeight) * weightText.doubleValue;
    double spot = spotText.doubleValue / 100;
    return currentMetal.bidPrice * baseUnitWeight * spot * purityWeight;
}

- (void)updateSubtotal
{
    subtotal_ = [self calcSubtotalWithWeightText:calculateWeightTextField.text andSpotText:calculateSpotTextField.text];
    subtotalPriceLabel.text = [NSString stringWithPrice:subtotal_];
}

#pragma mark - Actions

- (IBAction)unitAction:(id)sender
{
    if ([self.view.subviews containsObject:unitPicker_]) {
        [unitPicker_ removeFromSuperview];
        return;
    }
    
    [self _addLayout];
    
    [calculateWeightTextField resignFirstResponder];
    [calculateSpotTextField resignFirstResponder];
    [manualPriceTextField resignFirstResponder];
    
    selectedUnitIndex_ = [[ModelManager shared] unitIndexForID:self.currentMetal.savedUnit];
    
    [self.view addSubview:unitPicker_];
    [unitPicker_ showPicker];
    [unitPicker_ reloadData];
    [unitPicker_ selectRow:selectedUnitIndex_ inComponent:0 animated:NO];
}

- (IBAction)createItem:(id)sender
{
    if (fabs(self.currentMetal.bidPrice) < 0.0000001) {
        return;
    }
    
    PurchaseItem *item = [PurchaseItem new];
    item.purchaseID = self.activePurchase.purchaseID;
    item.metal = self.currentMetal;
    item.purityName = [currentMetal.purities[selectedPurityIndex_ - PURITY_BUTTON_BASE_TAG] allKeys][0];
    item.unit = [[ModelManager shared] unitForID:self.currentMetal.savedUnit];
    item.weight = [self.calculateWeightTextField.text doubleValue];
    item.price = subtotal_;
    
    if (![[ModelManager shared] addPurchaseItem:item]) {
        // TODO: show alert
    }
    [item release];
    [self.summaryView reload];
}

- (void)purchaseDidReceiveAddAction
{
    if (fabs([[ModelManager shared] activePurchase].price) < 0.0000001) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Would you like to save & link this purchase with a client?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save & Link", @"Save Only", nil];
    [alert show];
    [alert release];
}

- (void)savePurchase
{
    [[ModelManager shared] approvePurchase];
    self.activePurchase = [[ModelManager shared] activePurchase];
    [self.summaryView setupWithPurchase:self.activePurchase];
}

- (void)selectMetal:(Metal *)metal
{
    [self.chartsView changeMetal:metal];
    for (NSInteger i = 0; i < [[[ModelManager shared] metals] count]; ++i) {
        if ([[ModelManager shared] metals][i] == metal) {
            [self.scroll setupForItem:i];
            break;
        }
    }
}

#pragma mark - ModelManager delegate

- (void)didReceiveNewBids
{
    if (self.currentMetal == nil) {
        [self updateScreen];
    }
    else {
        [self updateScreenForMetal:self.currentMetal];
    }
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
        return;
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save Only"]) {
        [self savePurchase];
    }
    else {
        [[ModelManager shared] setShouldSavePurchase:NO];
        
        MCClientsViewController *vc = [MCClientsViewController new];
        vc.selectClient = YES;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(SPPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(SPPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.currentMetal.isBaseMetal ? [[[ModelManager shared] baseUnits] count] : [[[ModelManager shared] units] count];
}

- (NSString *)pickerView:(SPPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.currentMetal.isBaseMetal ? [[[ModelManager shared] baseUnits][row] name] : [[[ModelManager shared] units][row] name];
}

- (void)pickerView:(SPPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedUnitIndex_ = row;
    
    self.currentMetal.savedUnit = self.currentMetal.isBaseMetal ? [[[[ModelManager shared] baseUnits][selectedUnitIndex_] unitID] intValue] : [[[[ModelManager shared] units][selectedUnitIndex_] unitID] intValue];
    [[ModelManager shared] updateMetalWithSavedOptions:self.currentMetal];
    
    self.calculateUnitLabel.text = [[[[ModelManager shared] unitForID:self.currentMetal.savedUnit] shortName] uppercaseString];
    [self updateSubtotal];
}

#pragma mark - TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.view.subviews containsObject:unitPicker_]) {
        [self unitAction:nil];
    }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == calculateWeightTextField) {
        self.currentMetal.savedWeight = textField.text.doubleValue;
        [[ModelManager shared] updateMetalWithSavedOptions:self.currentMetal];
    }
    else if (textField == calculateSpotTextField) {
        self.currentMetal.savedSpot = textField.text.doubleValue;
        [[ModelManager shared] updateMetalWithSavedOptions:self.currentMetal];
    }
    else if (textField == manualPriceTextField) {
        textField.hidden = !(priceLabel.hidden = NO);
        self.currentMetal.bidPrice = textField.text.doubleValue * [[[ModelManager shared] selectedCurrency] value];
        self.priceLabel.text = [NSString stringWithPrice:self.currentMetal.bidPrice];
        [[ModelManager shared] updateMetalWithNewBids:self.currentMetal];
    }
    
    [self updateSubtotal];
}

#pragma mark - Label LongTap Delegate

- (void)labelDidReceiveLongTap:(MCBoldLabel *)label
{
    self.priceLabel.hidden = !(self.manualPriceTextField.hidden = NO);
    self.manualPriceTextField.text = [NSString stringWithFormat:@"%.2lf",self.currentMetal.bidPrice];
    [self.manualPriceTextField becomeFirstResponder];
}

#pragma mark - Purity action

- (void)purityChanged:(UIButton *)sender
{
    UIButton *prevActiveButton = (UIButton *)[calculatePurityView viewWithTag:selectedPurityIndex_];
    if (prevActiveButton != sender) {
        if ([prevActiveButton isKindOfClass:[UIButton class]]) {
            [prevActiveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [sender setTitleColor:ColorFromHexFormat(0xde8b14) forState:UIControlStateNormal];
        selectedPurityIndex_ = sender.tag;
        
        [self updateSubtotal];
        
        self.currentMetal.savedPurity = [sender titleForState:UIControlStateNormal];
        [[ModelManager shared] updateMetalWithSavedOptions:self.currentMetal];
    }
}

#pragma mark Charts frame

- (void)chartsShouldMoveDown
{
    [self setChartsFrameAnimated:CHARTS_FRAME_FULL];
}

- (void)chartsShouldMoveUp
{
    [self setChartsFrameAnimated:CHARTS_FRAME_HIDED];
}

- (void)chartsSimpleTap
{
    [self touchesBegan:nil withEvent:nil];
}

- (void)setChartsFrameAnimated:(CGRect)theFrame
{
    [UIView animateWithDuration:CHARTS_ANIMATION_DURATION animations:^{
        self.chartsView.frame = theFrame;
    }];
}

#pragma mark PurchaseSummary frame

- (void)purchaseSummaryShouldMoveUp
{
    CGRect frame = self.summaryView.frame;
    frame.origin.y = PURCHASE_Y_FULL;
    [self setPurchaseFrameAnimated:frame];
}

- (void)purchaseSummaryShouldMoveDown
{
    CGRect frame = self.summaryView.frame;
    frame.origin.y = PURCHASE_Y_HIDED;
    [self setPurchaseFrameAnimated:frame];
}

- (void)setPurchaseFrameAnimated:(CGRect)theFrame
{
    [UIView animateWithDuration:PURCHASE_ANIMATION_DURATION animations:^{
        self.summaryView.frame = theFrame;
    }];
}

#pragma mark - Diamond

- (void)setupAsSimpleCalc
{
    [self setIsDiamondCalculator:NO];
    
    if (diamondVC_)
    {
        [diamondVC_.view removeFromSuperview];
    }
}

- (void)setupAsDiamondCalc
{
    [self setIsDiamondCalculator:YES];
    
    if (nil == diamondVC_)
    {
        diamondVC_ = [MCDiamondViewController new];
    }
    diamondVC_.view.frame = self.view.bounds;
    [self.view addSubview:diamondVC_.view];
}


#pragma mark - Keyboard

-(void) keyboardDidShow:(NSNotification *) notification
{
    [self _addLayout];
}

#pragma mark - NumPad

- (void)numpadDidChangeText:(NSString *)text
{
    NSLog(@"%@", text);
}


#pragma mark - layout

- (void)_addLayout
{
    if (layoutView_ == nil) {
        layoutView_ = [[UIView alloc] initWithFrame:self.view.bounds];
        layoutView_.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker:)];
        tapG.numberOfTapsRequired = 1;
        [layoutView_ addGestureRecognizer:tapG];
        
        [[self view] addSubview:layoutView_];
        [[self view] bringSubviewToFront:layoutView_];
        
        [tapG release];
        [layoutView_ release];
    }
}

- (void)hidePicker:(id)sender
{
    [self.view endEditing:YES];
    if ([self.view.subviews containsObject:unitPicker_]) {
        [self unitAction:nil];
    }
    [layoutView_ removeFromSuperview];
    layoutView_ = nil;
}

#pragma mark - Memory

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [unitPicker_ release];
    [diamondVC_ release];
    
    self.numPad = nil;
    
    [super dealloc];
}

@end
