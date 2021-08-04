//
//  MCPurchaseView_iPad.m
//  ScrapCalc
//
//  Created by Diana on 06.08.13.
//
//

#import "MCPurchaseView_iPad.h"
#import "MCPurchaseItemCell_iPad.h"

@interface MCPurchaseView_iPad ()

@property (nonatomic, retain) Purchase *purchase;

@end

@implementation MCPurchaseView_iPad
@synthesize headerHeight = headerHeight_;

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
    totalTextLabel_ = [[MCBoldLabel alloc] initWithFrame:CGRectZero];
    [totalTextLabel_ awakeFromNib];
    totalTextLabel_.backgroundColor = [UIColor clearColor];
    totalTextLabel_.textColor = [UIColor whiteColor];
    totalTextLabel_.font = [totalTextLabel_.font fontWithSize:50.0];
    totalTextLabel_.shadowColor = [UIColor blackColor];
    totalTextLabel_.shadowOffset = SHADOW_OFFSET;
    
    totalTextLabel_.text = @"TOTAL:";
    [self addSubview:totalTextLabel_];
    
    totalValueLabel_ = [[MCBoldLabel alloc] initWithFrame:CGRectZero];
    [totalValueLabel_ awakeFromNib];
    totalValueLabel_.backgroundColor = [UIColor clearColor];
    totalValueLabel_.textColor = [UIColor whiteColor];
    totalValueLabel_.font = [totalTextLabel_.font fontWithSize:50.0];
    totalValueLabel_.shadowColor = [UIColor blackColor];
    totalValueLabel_.shadowOffset = SHADOW_OFFSET;
    totalValueLabel_.textAlignment = NSTextAlignmentRight;
    [self addSubview:totalValueLabel_];
    
    table_ = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    table_.backgroundColor = [UIColor clearColor];
    table_.separatorStyle = UITableViewCellSeparatorStyleNone;
    table_.dataSource = self;
    table_.delegate = self;
    [self addSubview:table_];
    
    separatorImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator_contentlist"]];
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
    return self.purchase.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PurchaseItemCell";
    MCPurchaseItemCell_iPad *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[MCPurchaseItemCell_iPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    [cell setupWithPurchaseItem:self.purchase.items[indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PURCHASEITEM_CELL_HEIGHT;
}

#pragma mark - Private

- (void)updateTableFrame
{
    if (self.purchase != nil) {
        CGFloat h = MIN(self.purchase.items.count * PURCHASEITEM_CELL_HEIGHT, self.frame.size.height - self.headerHeight);
        table_.frame = CGRectMake(0, self.headerHeight, self.frame.size.width, h);
        table_.scrollEnabled = (h < self.purchase.items.count * PURCHASEITEM_CELL_HEIGHT);
    }
    separatorImageView_.frame = CGRectMake(0, self.headerHeight-1, self.frame.size.width, 2);
    
    totalTextLabel_.frame = CGRectMake(8, 0, self.frame.size.width/3, self.headerHeight);
    CGFloat x = self.frame.size.width/2-36;
    totalValueLabel_.frame = CGRectMake(x, 0, self.frame.size.width-x-5, self.headerHeight);
}

#pragma mark - Public

- (void)setHeaderHeight:(CGFloat)theHeaderHeight
{
    headerHeight_ = theHeaderHeight;
    [self updateTableFrame];
}

- (void)setupWithPurchase:(Purchase *)thePurchase
{
    _purchase = thePurchase;
    totalValueLabel_.text = [NSString stringWithPrice:self.purchase.price];
    
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
