//
//  MCCustomAssayViewController_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 08.08.13.
//
//

#import "MCCustomAssayViewController_iPad.h"
#import "MCAssayCell.h"

#define ASSAY_Y_OFFSET          60
#define ASSAY_FIELD_WIDTH       100
#define ASSAY_FIELD_HEIGHT      80
#define ASSAY_FIELD_FRAME(y)    CGRectMake((self.assayView.frame.size.width-ASSAY_FIELD_WIDTH) / 2, y, ASSAY_FIELD_WIDTH, ASSAY_FIELD_HEIGHT)


@interface MCCustomAssayViewController_iPad ()
{
    UIView *layoutView_;
}

@property (nonatomic, strong) MCNumPad *numPad;
@property (nonatomic, strong) UITextField *processingTextField;

@end


@implementation MCCustomAssayViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = self.metal.name.uppercaseString;
    
    [self addBackButton];
    self.needsMoveBackButtonToTheContainer = YES;
    
    [self _initNumPad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.proLabel.hidden = [[ModelManager shared] isProVersion];
    [self.table reloadData];
}

- (BOOL)needsBackground
{
    return YES;
}


#pragma mark - NumPad

- (void)_initNumPad
{
    self.numPad = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(MCNumPad.class) owner:self options:nil][0];
    self.numPad.autoresizingMask = UIViewAutoresizingNone;
    self.numPad.decimalDigits = 3;
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
        CGFloat newY = sv.bounds.size.height - h - margin;
        CGFloat dy = newY - frame.origin.y;
        frame.origin.y = newY;
        
        [self.table setContentOffset:CGPointMake(0, -dy) animated:YES];
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
    
    UITextField *textField = self.processingTextField;
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
    self.processingTextField = nil;
    self.numPad.hidden = YES;
    
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self _removeLayout];
}

- (void)numpadDidChangeText:(NSString *)text
{
    if ([text hasPrefix:@"0"]) {
        text = [text substringFromIndex:1];
    }
    
    if (text.length < 1) {
        text = @".";
        [self.numPad setupWithText:@"0."];
    }
    else if (text.length > 4) {
        text = [text substringToIndex:4];
        [self.numPad setupWithText:[@"0" stringByAppendingString:text]];
    }
    
    self.processingTextField.text = text;
}


#pragma mark - Layout

- (void)_addLayout
{
    if (layoutView_ == nil) {
        layoutView_ = [[UIView alloc] initWithFrame:self.view.bounds];
        layoutView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        layoutView_.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hideNumPad)];
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


#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.metal.purities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const cellID = @"MCAssayCellID";
    MCAssayCell *cell = (MCAssayCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MCAssayCell" owner:self options:nil][0];
        cell.textField.delegate = self;
    }
    
    NSDictionary *purity = self.metal.purities[indexPath.row];
    NSString *text = [[NSString stringWithFormat:@"%.5lf", [purity.allValues[0] doubleValue]] substringFromIndex:1];
    while ([text hasSuffix:@"0"] && text.length > 4) {
        text = [text substringToIndex:text.length-1];
    }
    
    BOOL isPro = [[ModelManager shared] isProVersion];
    
    if (isPro) {        
        cell.textField.text = text;
        cell.textField.placeholder = @"";
    }
    else {
        cell.textField.placeholder = text;
        cell.textField.text = @"";
    }
    cell.textField.enabled = isPro;
    
    cell.textField.tag = indexPath.row;
    cell.titleLabel.text = purity.allKeys[0];

    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}



#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.processingTextField == textField) {
        [self _hideNumPad];
    }
    else {
        self.processingTextField = textField;
        [self _updateNumPadWithProcessingTextField];
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    [self.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    return YES;
}


#pragma mark - Memory

- (void)dealloc
{
    [layoutView_ release];
    self.processingTextField = nil;
    self.numPad = nil;
    [super dealloc];
}

@end
