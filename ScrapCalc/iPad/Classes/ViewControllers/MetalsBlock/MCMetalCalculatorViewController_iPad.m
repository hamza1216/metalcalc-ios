//
//  MCMetalCalculatorViewController_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 30.07.13.
//
//

#import "MCMetalCalculatorViewController_iPad.h"
#import "MCClientsListViewController_iPad.h"
#import "MCPickerPopover.h"


@interface MCMetalCalculatorViewController_iPad () <SPPickerViewDataSource, SPPickerViewDelegate>
{
    UIView *layoutView_;
}

@property (nonatomic, assign) Metal *currentMetal;
@property (nonatomic, retain) MCDiamondViewController_iPad *diamondVC;
@property (nonatomic, retain) MCPickerPopover *picker;
@property (nonatomic, retain) MCNumPad *numPad;
@property (nonatomic, retain) DotTextField *processingTextField;

@end


@implementation MCMetalCalculatorViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _createDiamondViewController];
    [self _createNumPad];
    [self _createPicker];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.topSlideView updateForMetal:self.currentMetal];
    [self.optionsView updateSubtotal];
    [self.summaryView updateWithPurchase:[[ModelManager shared] activePurchase]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkGA];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)_createDiamondViewController
{
    self.diamondVC = [[[MCDiamondViewController_iPad alloc] initWithNibName:nil bundle:nil] autorelease];
    self.diamondVC.view.hidden = [[[ModelManager shared] onMetals] count];
    [self.view addSubview:self.diamondVC.view];
}

#pragma mark - Setup for Interface Orientation

- (void)setupForPortrait
{
    [super setupForPortrait];
    [self.diamondVC setupForPortrait];
    
    self.topSlideView.isPortrait = YES;
    self.optionsView.isPortrait = YES;
    self.summaryView.isPortrait = YES;
    
    self.rotateButton.hidden = NO;
    self.needsMoveBackButtonToTheContainer = YES;
    [self addBackButton];
}

- (void)setupForLandscape
{
    [super setupForLandscape];
    [self.diamondVC setupForLandscape];
    
    self.topSlideView.isPortrait = NO;
    self.optionsView.isPortrait = NO;
    self.summaryView.isPortrait = NO;
    
    self.rotateButton.hidden = YES;
    [self removeBackButton];
}

#pragma mark - TopSlide Delegate

- (void)topSlideWillResizeToFullMode
{
    [self.summaryView setIsFullSize:NO animated:YES];
}

- (void)topSlideDidChangeMetalPrice
{
    [self.optionsView updateSubtotal];
    [self.delegate metalCalcDidChangePriceManually];
}

#pragma mark - Options Delegate

- (void)optionsViewDidChange
{
    [self.summaryView reloadSummary];
}

/*- (void)pickerWasShown
{
    [self _addLayout];
    //[self.containerView bringSubviewToFront:self.optionsView.picker];
}*/

#pragma mark - Summary Delegate

- (void)summaryWillResizeToFullMode
{
    [self.topSlideView setIsFullSize:NO animated:YES];
}

- (void)summaryShouldSelectClient
{
    MCClientsListViewController_iPad *clientsVC = [MCClientsListViewController_iPad new];
    clientsVC.selectClient = YES;
    [self.navigationViewController pushViewController:clientsVC animated:YES];
    [clientsVC release];
}

#pragma mark - IBActions

- (IBAction)rotateAction:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.transform = CGAffineTransformRotate(self.view.transform, M_PI);
    }];
}

- (void)didReceiveBackAction
{
    [self backAction:nil];
}

#pragma mark - Master Delegate

- (void)metalsListDidSelectMetal:(Metal *)metal
{
    if (metal == nil) {
        self.diamondVC.view.hidden = NO;
        [self checkGA];
        return;
    }
    
    self.diamondVC.view.hidden = YES;
    [self checkGA];
    
    if (metal != self.currentMetal) {
        [self _hideNumPad];
    }
    self.currentMetal = metal;
    
    [self.topSlideView updateForMetal:metal];
    [self.optionsView updateForMetal:metal];
}

- (void)metalsListDidSelectDiamond
{
    if (self.diamondVC.delegate == nil) {
        self.diamondVC.delegate = self;
    }
    self.diamondVC.view.hidden = NO;
    [self checkGA];
}

- (void)checkGA
{
    if (self.diamondVC.view.hidden) {
        self.screenName = METAL_CALCULATOR_SCREEN_NAME;
    }
    else {
        self.screenName = DIAMOND_CALCULATOR_SCREEN_NAME;
    }
}

#pragma mark - Keyboard

-(void) keyboardDidShow:(NSNotification *) notification
{
    [self _addLayout];
}

- (void)_addLayout
{
    if (layoutView_ == nil) {
        layoutView_ = [[UIView alloc] initWithFrame:self.view.bounds];
        layoutView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        layoutView_.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker:)];
        tapG.numberOfTapsRequired = 1;
        [layoutView_ addGestureRecognizer:tapG];
        [tapG release];
    }
    
    [[self containerView] addSubview:layoutView_];
}

- (void)_removeLayout
{
    [layoutView_ removeFromSuperview];
}

- (void)hidePicker:(id)sender
{
    [self _hideNumPad];
    [self _hidePicker];
    [self.processingTextField endEditing:YES];
    
    [self.view endEditing:YES];
    
}

#pragma mark - Picker popover

- (void)showPickerForLabel:(MCBoldLabel *)label
{
    CGPoint pt = label.center;
    
    UIView *sv = label.superview;
    while (sv != self.numPad.superview) {
        pt.x += sv.frame.origin.x;
        pt.y += sv.frame.origin.y;
        sv = sv.superview;
    }
    [self _showPickerAtPoint:pt];
}

- (void)selectRowInPicker:(NSInteger)row
{
    [self.picker selectRow:row animated:NO];
}

- (void)_createPicker
{
    self.picker = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(MCPickerPopover.class) owner:self options:nil][0];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    self.picker.hidden = YES;
    [self.containerView addSubview:self.picker];
}

- (void)_showPickerAtPoint:(CGPoint)point
{
    CGRect frame = self.picker.frame;
    UIView *sv = self.picker.superview;
    
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    CGFloat margin = 10;
    
    frame.origin.x = point.x - w/2;
    frame.origin.y = point.y;
    
    if (frame.origin.x < margin) {
        frame.origin.x = margin;
    }
    else if (frame.origin.x + w > sv.bounds.size.width - margin) {
        frame.origin.x = sv.bounds.size.width - w - margin;
    }
    
    if (frame.origin.y < margin) {
        frame.origin.y = margin;
    }
    else if (frame.origin.y + h > sv.bounds.size.height - margin) {
        frame.origin.y = sv.bounds.size.height - h - margin;
    }
    
    [self _addLayout];
    
    self.picker.frame = frame;
    [self.picker show];
    [self.picker selectRow:[[ModelManager shared] unitIndexForID:self.currentMetal.savedUnit isBase:self.currentMetal.isBaseMetal] animated:NO];
    
    [self.picker.superview bringSubviewToFront:self.picker];
}

- (void)_hidePicker
{
    self.picker.hidden = YES;
    [self _removeLayout];
}

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
    self.currentMetal.savedUnit = self.currentMetal.isBaseMetal ? [[[[ModelManager shared] baseUnits][row] unitID] intValue] : [[[[ModelManager shared] units][row] unitID] intValue];
    [[ModelManager shared] updateMetalWithSavedOptions:self.currentMetal];
    [self.optionsView updateForMetal:self.currentMetal];
}

#pragma mark - NumPad

- (void)_createNumPad
{
    self.numPad = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(MCNumPad.class) owner:self options:nil][0];
    self.numPad.autoresizingMask = UIViewAutoresizingNone;
    self.numPad.delegate = self;
    self.numPad.hidden = YES;
    [self.containerView addSubview:self.numPad];
}

- (void)_showNumPadAtPoint:(CGPoint)point
{
    CGRect frame = self.numPad.frame;
    UIView *sv = self.numPad.superview;
    
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    CGFloat margin = 10;
    
    frame.origin.x = point.x - w/2;
    frame.origin.y = point.y;
    
    if (frame.origin.x < margin) {
        frame.origin.x = margin;
    }
    else if (frame.origin.x + w > sv.bounds.size.width - margin) {
        frame.origin.x = sv.bounds.size.width - w - margin;
    }
    
    if (frame.origin.y < margin) {
        frame.origin.y = margin;
    }
    else if (frame.origin.y + h > sv.bounds.size.height - margin) {
        frame.origin.y = sv.bounds.size.height - h - margin;
    }
    
    [self _addLayout];
    
    self.numPad.frame = frame;
    self.numPad.hidden = NO;
    
    [self.numPad.superview bringSubviewToFront:self.numPad];
}

- (void)_updateNumPadWithProcessingTextField
{
    if (self.processingTextField == nil) {
        return;
    }
    
    DotTextField *textField = self.processingTextField;
    CGPoint pt = textField.center;
    
    UIView *sv = textField.superview;
    while (sv != self.numPad.superview) {
        pt.x += sv.frame.origin.x;
        pt.y += sv.frame.origin.y;
        sv = sv.superview;
    }
    
    [self _showNumPadAtPoint:pt];
    
    [self.numPad setupWithText:self.processingTextField.text];
    [self.numPad setArrowCenterX:pt.x];
}

- (void)_hideNumPad
{
    if ([self.processingTextField.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        [self.processingTextField.delegate textFieldShouldReturn:self.processingTextField];
    }
    
    self.processingTextField = nil;
    self.numPad.hidden = YES;
    
    [self _removeLayout];
}

- (void)showOrHideNumPadForTextField:(DotTextField *)textField
{
    if (self.numPad.hidden) {
        self.processingTextField = textField;
        [self _updateNumPadWithProcessingTextField];
    }
    else {
        [self _hideNumPad];
    }
}

- (void)numpadDidChangeText:(NSString *)text
{
    self.processingTextField.text = text;
    
    // for immediate update
    if ([self.processingTextField.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.processingTextField.delegate textFieldDidEndEditing:self.processingTextField];
    }
}

#pragma mark - Autorotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self _updateNumPadWithProcessingTextField];
}

#pragma mark - Memory management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [_diamondVC release];
    [layoutView_ release];
    self.numPad = nil;
    self.picker = nil;
    [super dealloc];
}

@end
