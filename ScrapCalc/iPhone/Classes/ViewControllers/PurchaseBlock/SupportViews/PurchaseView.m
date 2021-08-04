//
//  PurchaseView.m
//  ScrapCalc
//
//  Created by word on 19.03.13.
//
//

#import "PurchaseView.h"
#import "PurchaseItemCell.h"
#import "NSString+NumbersFormats.h"


@interface PurchaseView ()

@property (nonatomic, retain) Purchase *purchase;

@end


@implementation PurchaseView

@synthesize purchase;
@synthesize headerHeight;

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
    totalTextLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    totalTextLabel_.backgroundColor = [UIColor clearColor];
    totalTextLabel_.textColor = [UIColor whiteColor];
    totalTextLabel_.font = [UIFont boldSystemFontOfSize:24];
    totalTextLabel_.text = @"TOTAL:";
    [self addSubview:totalTextLabel_];
    
    totalValueLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    totalValueLabel_.backgroundColor = [UIColor clearColor];
    totalValueLabel_.textColor = [UIColor whiteColor];
    totalValueLabel_.font = [UIFont boldSystemFontOfSize:24];
    totalValueLabel_.textAlignment = NSTextAlignmentRight;
    [self addSubview:totalValueLabel_];
    
    table_ = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    table_.backgroundColor = [UIColor clearColor];
    table_.separatorStyle = UITableViewCellSeparatorStyleNone;
    table_.dataSource = self;
    table_.delegate = self;
    [self addSubview:table_];
    
    separatorImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator_full.png"]];
    [self addSubview:separatorImageView_];
    
    self.headerHeight = 70;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateTableFrame];
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return purchase.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PurchaseItemCell";
    PurchaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[PurchaseItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    [cell setupWithPurchaseItem:purchase.items[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PURCHASEITEM_CELL_HEIGHT;
}

#pragma mark - Private

- (void)updateTableFrame
{
    if (purchase != nil) {
        CGFloat h = MIN(purchase.items.count * PURCHASEITEM_CELL_HEIGHT, self.frame.size.height - headerHeight);
        table_.frame = CGRectMake(0, headerHeight, self.frame.size.width, h);
        table_.scrollEnabled = (h < purchase.items.count * PURCHASEITEM_CELL_HEIGHT);
    }
    separatorImageView_.frame = CGRectMake(0, headerHeight-1, self.frame.size.width, 2);
    
    totalTextLabel_.frame = CGRectMake(8, 0, self.frame.size.width/3, headerHeight);
    CGFloat x = self.frame.size.width/2-36;
    totalValueLabel_.frame = CGRectMake(x, 0, self.frame.size.width-x-5, headerHeight);
}

#pragma mark - Public

- (void)setHeaderHeight:(CGFloat)theHeaderHeight
{
    headerHeight = theHeaderHeight;
    [self updateTableFrame];
}

- (void)setupWithPurchase:(Purchase *)thePurchase
{
    self.purchase = thePurchase;
    totalValueLabel_.text = [NSString stringWithPrice:purchase.price];
    
    [table_ reloadData];
    [self updateTableFrame];
}

#pragma mark - Memory

- (void)dealloc
{
    [totalTextLabel_ release];
    [totalValueLabel_ release];
    [table_ release];
    [separatorImageView_ release];
    [super dealloc];
}

@end
