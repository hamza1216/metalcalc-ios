//
//  MCPurchaseSummaryView.m
//  ScrapCalc
//
//  Created by word on 21.03.13.
//
//

#import "MCPurchaseSummaryView.h"
#import "NSString+NumbersFormats.h"
#import "PurchaseItemCell.h"
#import "ModelManager.h"

#define PURCHASE_ITEM_ROWHEIGHT 44


@interface MCPurchaseSummaryView ()

@property (nonatomic, retain) Purchase *purchase;

@end


@implementation MCPurchaseSummaryView

@synthesize headerHeight;
@synthesize delegate;
@synthesize purchase;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    CGFloat w = 60;
    touchZone_ = CGRectMake((self.frame.size.width - w) / 2, 0, w, 30);
    
    headerBg_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calc_total_bg.png"]];
    [self addSubview:headerBg_];
    
    totalTextLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    totalTextLabel_.backgroundColor = [UIColor clearColor];
    totalTextLabel_.textColor = [UIColor whiteColor];
    totalTextLabel_.shadowColor = [UIColor grayColor];
    totalTextLabel_.shadowOffset = CGSizeMake(0, 1);
    totalTextLabel_.text = @"TOTAL: ";
    totalTextLabel_.textAlignment = NSTextAlignmentCenter;
    totalTextLabel_.font = FONT_MYRIAD_BOLD(28);
    totalTextLabel_.minimumScaleFactor = 10;
    totalTextLabel_.adjustsFontSizeToFitWidth = YES;
    [self addSubview:totalTextLabel_];
    
    totalValueLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    totalValueLabel_.backgroundColor = [UIColor clearColor];
    totalValueLabel_.textColor = [UIColor whiteColor];
    totalValueLabel_.shadowColor = [UIColor grayColor];
    totalValueLabel_.shadowOffset = CGSizeMake(0, 1);
    totalValueLabel_.textAlignment = NSTextAlignmentRight;
    totalValueLabel_.font = FONT_MYRIAD_BOLD(30);
    totalValueLabel_.minimumScaleFactor = 10;
    totalValueLabel_.adjustsFontSizeToFitWidth = YES;
    [self addSubview:totalValueLabel_];
    
    numberLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    numberLabel_.backgroundColor = [UIColor clearColor];
    numberLabel_.textColor = [UIColor whiteColor];
    numberLabel_.shadowColor = [UIColor grayColor];
    numberLabel_.shadowOffset = CGSizeMake(0, 1);
    numberLabel_.font = [UIFont systemFontOfSize:17];
    [self addSubview:numberLabel_];
    
    addButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [addButton_ setBackgroundImage:[UIImage imageNamed:@"calc_add_button.png"] forState:UIControlStateNormal];
    [addButton_ addTarget:self action:@selector(addButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addButton_];
    
    clearButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    clearButton_.backgroundColor = [UIColor clearColor];
    [clearButton_ setTitle:@"CLEAR" forState:UIControlStateNormal];
    [clearButton_ setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [clearButton_ addTarget:self action:@selector(clearButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clearButton_];
    
    separatorView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator_full.png"]];
    [self addSubview:separatorView_];
    
    table_ = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table_.backgroundColor = [UIColor clearColor];
    
    table_.separatorStyle = UITableViewCellSeparatorStyleNone;
    table_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    table_.dataSource = self;
    table_.delegate = self;
    table_.bounces = NO;
    [self addSubview:table_];

    self.headerHeight = 60;
    [self placeSubviews];
}

- (void)setHeaderHeight:(CGFloat)theHeight
{
    headerHeight = theHeight;
    [self placeSubviews];
}

#pragma mark - UI setup

- (void)placeSubviews
{
    CGFloat w = self.frame.size.width;
    CGFloat h = headerHeight;
    headerBg_.frame = self.bounds;
    
    totalTextLabel_.frame = CGRectMake(0, 0+2, w/3, 2*h/3+4);
    totalValueLabel_.frame = CGRectMake(w/3, 0+2, 2*w/3, 2*h/3+4);
    addButton_.frame = CGRectMake(7, 2*h/3 + 4, 24, 24);
    numberLabel_.frame = CGRectMake(addButton_.frame.origin.x + addButton_.frame.size.width + 6, 2*h/3-5, w/2 - addButton_.frame.size.width, h/3);
    clearButton_.frame = CGRectMake(w-70, 2*h/3-5, 70, h/3);
    
    separatorView_.frame = CGRectMake(0, headerHeight-1, w, 2);
}

- (void)setupWithPurchase:(Purchase *)thePurchase
{
    self.purchase = thePurchase;
    totalValueLabel_.text = [NSString stringWithPrice:purchase.price];
    numberLabel_.text = [@"#" stringByAppendingString: purchase.number];
    [table_ reloadData];
}

- (void)reload
{
    totalValueLabel_.text = [NSString stringWithPrice:purchase.price];
    [table_ reloadData];
}

#pragma mark - UITableView data source and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat h = purchase.items.count * PURCHASE_ITEM_ROWHEIGHT;
    CGFloat h1 = self.isFullSize ? self.frame.size.height - headerHeight:88.0;
    table_.frame = CGRectMake(0, headerHeight, self.frame.size.width, MIN(h,h1));
    return purchase.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PurchaseItemCellID";
    PurchaseItemCell *cell = (PurchaseItemCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[PurchaseItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.configureWithButton = YES;
        [cell.button addTarget:self action:@selector(removePurchaseItem:) forControlEvents:UIControlEventTouchUpInside];
    }

    [cell setupWithPurchaseItem:purchase.items[indexPath.row]];
    cell.button.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margin
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    [cell setBackgroundColor:[UIColor clearColor]];
//}

#pragma mark - Action

- (void)removePurchaseItem:(UIButton *)sender
{
    PurchaseItem *item = self.purchase.items[sender.tag];
    self.purchase.price -= item.price;
    totalValueLabel_.text = [NSString stringWithPrice:purchase.price];
    
    [[ModelManager shared] deletePurchaseItemByID:item.itemID];
    [self.purchase.items removeObjectAtIndex:sender.tag];
    
    if (self.purchase.items.count < 1) {
        self.purchase.price = 0;
    }
    
    [table_ reloadData];
}

- (void)addButtonTouch:(UIButton *)sender
{
    if ([delegate respondsToSelector:@selector(purchaseDidReceiveAddAction)]) {
        [delegate purchaseDidReceiveAddAction];
    }
}

- (void)clearButtonTouch:(UIButton *)sender
{
    self.purchase.price = 0;
    totalValueLabel_.text = [NSString stringWithPrice:purchase.price];
    
    for (PurchaseItem *item in self.purchase.items) {
        [[ModelManager shared] deletePurchaseItemByID:item.itemID];
    }
    [self.purchase.items removeAllObjects];
    [table_ reloadData];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    properTouch_ = (touchZone_.origin.x <= location.x && location.x <= touchZone_.origin.x + touchZone_.size.width &&
                    touchZone_.origin.y <= location.y && location.y <= touchZone_.origin.y + touchZone_.size.height);
    startTouchPoint_ = location;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat y = [[touches anyObject] locationInView:self].y;
    if (properTouch_ && ABS(y - startTouchPoint_.y) >= 5) {
        if (y > startTouchPoint_.y) {
            if ([delegate respondsToSelector:@selector(purchaseSummaryShouldMoveDown)]) {
                self.isFullSize = NO;
                [table_ reloadData];
                [delegate purchaseSummaryShouldMoveDown];
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(purchaseSummaryShouldMoveUp)]) {
                self.isFullSize = YES;
                [table_ reloadData];
                [delegate purchaseSummaryShouldMoveUp];
            }
        }
        properTouch_ = NO;
    }
}

#pragma mark - Memory

- (void)dealloc
{
    [headerBg_ release];
    [totalTextLabel_ release];
    [totalValueLabel_ release];
    [numberLabel_ release];
    [addButton_ release];
    [clearButton_ release];
    [separatorView_ release];
    [table_ release];
    [super dealloc];
}

@end
