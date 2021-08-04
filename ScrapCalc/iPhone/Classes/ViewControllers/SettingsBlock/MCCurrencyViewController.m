//
//  MCCurrencyViewController.m
//  ScrapCalc
//
//  Created by word on 18.04.13.
//
//

#import "MCCurrencyViewController.h"
#import "MCCurrencyCell.h"
#import "ModelManager.h"


@interface MCCurrencyViewController ()

@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, copy) NSString *selectedAbbr;

@end


@implementation MCCurrencyViewController

@synthesize table = table_;
@synthesize search = search_;
@synthesize searchText;
@synthesize selectedAbbr;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initBackButton];
    [self setNavigationTitle:@"CURRENCY"];
    
    self.table.backgroundView = bgView_;
    self.table.tableHeaderView = self.search;
    
    for (UIView *v in self.search.subviews) {
        if ([v conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)v setClearButtonMode:UITextFieldViewModeNever];
        }
    }
    
    keys_ = [NSMutableArray new];
    items_ = [NSMutableDictionary new];
    
    [self reload];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setScreenName:CURRENCY_SCREEN_NAME];
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
    
    [table_ reloadData];
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
    MCCurrencyCell *cell = (MCCurrencyCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[MCCurrencyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        [cell.button addTarget:self action:@selector(cellButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    Currency *cur = items_[keys_[indexPath.section]][indexPath.row];
    [cell setFullText:cur.fullname];
    [cell setShortText:cur.shortname];
    
    [cell makeSelectedCell:[cur.currencyID isEqualToString:[[[ModelManager shared] selectedCurrency] currencyID]]];
    cell.button.tag = indexPath.section * 10000 + indexPath.row;
    
    return cell;
}

- (IBAction)cellButtonTouched:(UIButton *)sender
{
    NSInteger row = sender.tag % 10000;
    NSInteger section = sender.tag / 10000;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self tableView:table_ didSelectRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return keys_[section];
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

@end
