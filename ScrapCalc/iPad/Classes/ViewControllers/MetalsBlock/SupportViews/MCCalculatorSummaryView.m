//
//  MCCalculatorSummaryView.m
//  ScrapCalc
//
//  Created by Domovik on 01.08.13.
//
//

#import "MCCalculatorSummaryView.h"


@interface MCCalculatorSummaryView ()
{
    UIImageView *_backgroundView;
    CGRect _touchZone;
    CGPoint _touchBeganPoint;
}

@property (nonatomic, assign) Purchase *purchase;

@end


@implementation MCCalculatorSummaryView

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
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:_backgroundView atIndex:0];
}

#pragma mark - Override

static const CGSize touchZoneSize = (CGSize) {108, 50};

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _touchZone = CGRectMake((frame.size.width - touchZoneSize.width) / 2 - 11, 0, touchZoneSize.width, touchZoneSize.height);
}

#pragma mark - Public

- (void)setIsPortrait:(BOOL)isPortrait
{
    _isPortrait = isPortrait;
    [self _setupAnimated:NO];
}

- (void)setIsFullSize:(BOOL)isFullSize animated:(BOOL)animated
{
    self.isFullSize = isFullSize;
    [self _setupAnimated:animated];
}

- (void)updateWithPurchase:(Purchase *)purchase
{
    self.purchase = purchase;
    self.numberLabel.text = [@"#" stringByAppendingString:self.purchase.number];
    [self reloadSummary];
}

- (void)reloadSummary
{
    self.totalLabel.text = [NSString stringWithPrice:self.purchase.price];
    [self.table reloadData];
}

- (void)savePurchase
{
    [[ModelManager shared] approvePurchase];
    [self updateWithPurchase:[[ModelManager shared] activePurchase]];
}

#pragma mark - Private

- (void)_setupAnimated:(BOOL)animated
{    
    NSString *imageName = nil;
    CGRect frame, tableFrame;
    
    if (self.isFullSize) {
        imageName = SUMMARY_BG_NORM_FULL;
        frame = self.isPortrait ? SUMMARY_FRAME_FULL_P : SUMMARY_FRAME_FULL_L;
        tableFrame = self.isPortrait ? SUMMARY_TABLE_FRAME_FULL_P : SUMMARY_TABLE_FRAME_L;
    }
    else if (self.isPortrait) {
        imageName = SUMMARY_BG_NORM_PORTRAIT;
        frame = SUMMARY_FRAME_PORTRAIT;
        tableFrame = SUMMARY_TABLE_FRAME_P;
    }
    else {
        imageName = SUMMARY_BG_NORM_LANDSCAPE;
        frame = SUMMARY_FRAME_LANDSCAPE;
        tableFrame = SUMMARY_TABLE_FRAME_L;
    }
    
    SEL delegateSelector = self.isFullSize ? @selector(summaryWillResizeToFullMode) : @selector(summaryWillResizeToNormalMode);
    if ([self.delegate respondsToSelector:delegateSelector]) {
        [self.delegate performSelector:delegateSelector];
    }
    
    AnimationBlock block = ^{
        _backgroundView.image = [UIImage imageNamed:imageName];
        self.frame = frame;
        self.table.frame = tableFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.5
                         animations:block];
    }
    else {
        block();
    }
}

#pragma mark - Table DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.purchase.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const cellID = @"MCSummaryCell_iPadID";
    MCSummaryCell_iPad *cell = (MCSummaryCell_iPad *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MCSummaryCell_iPad" owner:self options:nil][0];
        cell.delegate = self;
    }
    
    PurchaseItem *item = self.purchase.items[indexPath.row];
    [cell setupWithPurchaseItem:item];
    
    cell.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}

#pragma mark - SummaryCell Delegate

- (void)summaryCellDidReceiveRemoveAction:(MCSummaryCell_iPad *)cell
{
    PurchaseItem *item = self.purchase.items[cell.tag];
    self.purchase.price -= item.price;
    
    [[ModelManager shared] deletePurchaseItemByID:item.itemID];
    [self.purchase.items removeObjectAtIndex:cell.tag];
    
    if (self.purchase.items.count < 1) {
        self.purchase.price = 0;
    }
    
    [self reloadSummary];
}

#pragma mark - IBActions

- (IBAction)addAction:(id)sender
{
    if (fabs([[ModelManager shared] activePurchase].price) < 0.0000001) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Would you like to save & link this purchase with a client?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save & Link", @"Save Only", nil];
    [alert show];
    [alert release];
}

#pragma mark - Label Delegate

- (void)labelDidReceiveSingleTap:(MCBoldLabel *)label
{
    for (PurchaseItem *item in self.purchase.items) {
        [[ModelManager shared] deletePurchaseItemByID:item.itemID];
    }
    [self.purchase.items removeAllObjects];
    
    self.purchase.price = 0;    
    [self reloadSummary];
}

#pragma mark - Alert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save Only"]) {
        [self savePurchase];
    }
    else {
        [self.delegate summaryShouldSelectClient];
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchBeganPoint = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(_touchZone, _touchBeganPoint)) {
        _touchBeganPoint = CGPointZero;
    }
}

static const CGFloat yToStartMove = 5;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (CGPointEqualToPoint(_touchBeganPoint, CGPointZero)) {
        return;
    }
    
    CGPoint currentTouch = [[touches anyObject] locationInView:self];
    
    if (currentTouch.y > _touchBeganPoint.y) {
        if (self.isFullSize && (currentTouch.y - _touchBeganPoint.y) >= yToStartMove) {
            self.isFullSize = NO;
            _touchBeganPoint = CGPointZero;
            [self _setupAnimated:YES];
        }
    }
    else {
        if (!self.isFullSize && (_touchBeganPoint.y - currentTouch.y) >= yToStartMove) {
            self.isFullSize = YES;
            _touchBeganPoint = CGPointZero;
            [self _setupAnimated:YES];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchBeganPoint = CGPointZero;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Memory management

- (void)dealloc
{
    [_backgroundView release];
    [super dealloc];
}

@end
