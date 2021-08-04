//
//  MCCurrencyViewController_iPad.m
//  ScrapCalc
//
//  Created by Diana on 14.08.13.
//
//

#import "MCCurrencyViewController_iPad.h"
#import "MCCurrencyCell_iPad.h"

#define SECTION_INDEX_WIDTH 30.0

@interface MCCurrencyViewController_iPad () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSMutableArray *keys_;
    NSMutableDictionary *items_;
}

@property (nonatomic, retain) IBOutlet UISearchBar *search;

@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, copy) NSString *selectedAbbr;

@end

@implementation MCCurrencyViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.table.tableHeaderView = self.search;
    
    self.titleLabel.text = @"CURRENCIES";
    
    [self addBackButton];
    self.needsMoveBackButtonToTheContainer = YES;
    
    for (UIView *v in self.search.subviews) {
        if ([v conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)v setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    
    keys_ = [NSMutableArray new];
    items_ = [NSMutableDictionary new];
    
    [self reload];
}

- (void)reload
{
    NSMutableArray *curs = [NSMutableArray arrayWithArray:[[ModelManager shared] currencies]];
    
    if (self.searchText.length > 0) {
        NSInteger cnt = curs.count;
        
        for (NSInteger i = 0; i < cnt; ++i) {
            Currency *cur = curs[i];
            
            if (![self isString:self.searchText substringOf:cur.shortname] &&
                ![self isString:self.searchText substringOf:cur.fullname]) {
                
                [curs removeObjectAtIndex:i];
                i--;
                cnt--;
            }
        }
    }
    
    [keys_ removeAllObjects];
    [items_ removeAllObjects];
    
    for (Currency *cur in curs) {
//        NSString *key = [cur.fullname substringToIndex:1];
        NSString *key = cur.category;
        if(cur.value == 0.f)
        {
            continue;
        }
        if (items_[key] == nil) {
            items_[key] = [NSMutableArray array];
            [keys_ addObject:key];
        }
        [items_[key] addObject:cur];
    }
    
    NSArray *sortedKeys = [keys_ sortedArrayUsingSelector:@selector(compare:)];
    [keys_ removeAllObjects];
    [keys_ addObjectsFromArray:sortedKeys];
    
    [self.table reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return keys_.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items_[keys_[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"CurrencyCellID";
    MCCurrencyCell_iPad *cell = (MCCurrencyCell_iPad *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = (MCCurrencyCell_iPad *)[[NSBundle mainBundle] loadNibNamed:@"MCCurrencyCell_iPad" owner:self options:nil][0];
        CGRect cellFrame = cell.frame;
        cellFrame.size.width = self.table.frame.size.width;
        cell.frame = cellFrame;
        //cell = [[[MCCurrencyCell_iPad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        [cell.button addTarget:self action:@selector(cellButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    Currency *cur = items_[keys_[indexPath.section]][indexPath.row];
    [cell setFullText:cur.fullname];
    [cell setShortText:cur.shortname];
    
    [cell makeSelectedCell:[cur.currencyID isEqualToString:[[[ModelManager shared] selectedCurrency] currencyID]]];
    cell.button.tag = indexPath.section * 10000 + indexPath.row;
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (IBAction)cellButtonTouched:(UIButton *)sender
{
    NSInteger row = sender.tag % 10000;
    NSInteger section = sender.tag / 10000;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self tableView:self.table didSelectRowAtIndexPath:indexPath];
}

static const CGFloat headerHeight = 45;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = self.table.frame;
    frame.origin.y = 0;
    frame.size.height = headerHeight - 3;
    
    UIView *headerView = [[[UIView alloc] initWithFrame:frame] autorelease];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:headerView.bounds];
    bgImage.image = [UIImage imageNamed:@"settings_header_background.png"];
    [headerView addSubview:bgImage];
    [bgImage release];
    
    CGRect textFrame = headerView.bounds;
    textFrame.origin.x += 20;
    textFrame.origin.y += 4;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:textFrame];
    textLabel.tag = 10;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.shadowColor = [UIColor blackColor];
    textLabel.shadowOffset = CGSizeMake(0, 1);
    textLabel.font = FONT_MYRIAD_SEMIBOLD(32);
    [headerView addSubview:textLabel];
    
    textLabel.text = keys_[section];
    
    [textLabel release];
    return headerView;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    NSMutableArray *arr = [NSMutableArray arrayWithArray:keys_];
//    [arr insertObject:@"{search}" atIndex:0];
//    return arr;
//}
//
//- (NSInteger)tableView:(UITableView*)_tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
//{
//	if (index == 0) {
//		[_tableView scrollRectToVisible:self.search.frame animated:NO];
//	}
//	return index - 1;
//}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Currency *cur = items_[keys_[indexPath.section]][indexPath.row];
    [[[ModelManager shared] settings] setCurrencyID:cur.currencyID];
    [[ModelManager shared] synchronizeSettings];
    
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchText = searchBar.text;
    [self reload];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Substring search

- (BOOL)isString:(NSString *)check substringOf:(NSString *)source
{
    NSInteger cnt = source.length - check.length;
    for (NSInteger i = 0; i <= cnt; ++i) {
        if ([check.lowercaseString isEqualToString:[source.lowercaseString substringWithRange:NSMakeRange(i, check.length)]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Memory

- (void)dealloc
{
    [items_ release];
    [keys_ release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
