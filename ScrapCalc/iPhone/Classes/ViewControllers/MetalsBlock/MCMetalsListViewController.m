//
//  MCNewsListViewController.m
//  ScrapCalc
//
//  Created by word on 11.04.13.
//
//

#import "MCMetalsListViewController.h"
#import "MCMetalCell.h"
#import "MCMetalCellNew.h"
#import "NSString+NumbersFormats.h"
#import "MCCalculatorViewController.h"
#import "MCCurrencyViewController.h"
#import "BaseNavigationController.h"

#define METAL_REFRESH_OFFSET    -52
#define PULL_TEXT       @"Pull down to refresh spot prices"
#define RELEASE_TEXT    @"Release to refresh spot prices"


@interface MCMetalsListViewController ()

@property (nonatomic, assign) BOOL needsBuyAlert;

@end


@implementation MCMetalsListViewController

@synthesize table;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            				 selector:@selector(applicationDidBecomeActive)
									     name:UIApplicationDidBecomeActiveNotification
				                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@""];
    self.needsBuyAlert = YES;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [[btn.widthAnchor constraintEqualToConstant:48] setActive:YES];
    [[btn.heightAnchor constraintEqualToConstant:24] setActive:YES];
    
    currencyLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 48, 21)];
    currencyLabel_.backgroundColor = [UIColor clearColor];
    currencyLabel_.textColor = ColorFromHexFormat(0xffffff);
    currencyLabel_.shadowColor = [UIColor blackColor];
    currencyLabel_.shadowOffset = CGSizeMake(0,1);
    currencyLabel_.text = [[ModelManager shared] selectedCurrency].shortname;
    currencyLabel_.font = FONT_MYRIAD_BOLD(14);
    currencyLabel_.textAlignment = NSTextAlignmentCenter;
    [btn addSubview:currencyLabel_];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"calc_unit.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(changeCurrency) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];    
    
    datetimeLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(6, self.navigationController.navigationBar.frame.size.height/2-9, 200, 21)];
    datetimeLabel_.backgroundColor = [UIColor clearColor];
    datetimeLabel_.textColor = ColorFromHexFormat(0x868686);
    datetimeLabel_.font = FONT_MYRIAD_BOLD(14);
    [self.navigationController.navigationBar addSubview:datetimeLabel_];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:bgView_.image];
    imgView.frame = self.table.bounds;
    self.table.backgroundView = imgView;
    [imgView release];
    
    reloadArrowView_ = [[UIImageView alloc] initWithFrame:CGRectMake(20, -42, 15, 40)];
    reloadArrowView_.image = [UIImage imageNamed:@"pulltorefreshArrow.png"];
    [self.table addSubview:reloadArrowView_];
    
    reloadTextLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(60, -42, 240, 40)];
    reloadTextLabel_.backgroundColor = [UIColor clearColor];
    reloadTextLabel_.textColor = [UIColor whiteColor];
    reloadTextLabel_.shadowColor = [UIColor blackColor];
    reloadTextLabel_.shadowOffset = CGSizeMake(0, 1);
    reloadTextLabel_.text = PULL_TEXT;
    reloadTextLabel_.font = FONT_MYRIAD_BOLD(16);
    [self.table addSubview:reloadTextLabel_];
    
    bReload = NO;
    
    [self reload];
}

- (void)viewDidUnload
{
    [currencyLabel_ release];
    [datetimeLabel_ release];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ModelManager shared] setDelegate:self];
    
    datetimeLabel_.hidden = NO;
    currencyLabel_.text = [[ModelManager shared] selectedCurrency].shortname;
    [self.table reloadData];
    
    Metal *metal = [[ModelManager shared] metalForID:1];
    if (metal.bidPrice < 0.1) {
        [[ModelManager shared] setNeedsFetch:YES];
    }
    
    if ([[ModelManager shared] needsFetch] ) {
        [[ModelManager shared] setNeedsFetch:NO];
        [self reload];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    [self setScreenName:METALS_LIST_SCREEN_NAME];
}

- (void)viewWillDisappear:(BOOL)animated
{
    datetimeLabel_.hidden = YES;
    [[ModelManager shared] setDelegate:nil];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Public methods

- (void)applicationDidBecomeActive
{
}


#pragma mark - Actions

- (void)changeCurrency
{
    if ([[VersionManager shared] canFetchData]) {
        MCCurrencyViewController *vc = [MCCurrencyViewController new];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    else {
        [self showBuyNowAlert];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[ModelManager shared] onMetals] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"MetalCellID";
    MCMetalCellNew *cell = (MCMetalCellNew *)[tableView dequeueReusableCellWithIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        cell = [[[MCMetalCellNew alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    if (indexPath.section == [[[ModelManager shared] onMetals] count]) {
        [cell setupWithDiamond];
    }
    else {
        Metal *metal = [[ModelManager shared] onMetals][indexPath.section];
        [cell setupWithMetal:metal];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return METAL_CELL_NEW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BaseNavigationController *nvc = (BaseNavigationController *)self.tabBarController.viewControllers[1];
    [nvc popToRootViewControllerAnimated:NO];
    
    MCCalculatorViewController *vc = (MCCalculatorViewController *)nvc.viewControllers[0];
    
    if (indexPath.section == [[[ModelManager shared] onMetals] count]) {        
        [vc setupAsDiamondCalc];
    }
    else {
        [vc setupAsSimpleCalc];
        
        if (vc.selectMetalAfterLoad < 1) {
            NSInteger cnt = 1;
            for (Metal *metal in [[ModelManager shared] metals]) {
                if (metal == [[ModelManager shared] onMetals][indexPath.section]) {
                    vc.selectMetalAfterLoad = cnt;
                    break;
                }
                cnt++;
            }
        }
        [vc selectMetal:[[ModelManager shared] onMetals][indexPath.section]];
    }
    
    self.tabBarController.selectedIndex = 1;
}

#pragma mark - Pull-to-refresh

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (shouldReload_ != (scrollView.contentOffset.y < METAL_REFRESH_OFFSET)) {
        shouldReload_ = !shouldReload_;
        if (shouldReload_) {
            reloadTextLabel_.text = RELEASE_TEXT;
            [UIView animateWithDuration:0.2 animations:^{
                reloadArrowView_.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
        else {
            reloadTextLabel_.text = PULL_TEXT;
            [UIView animateWithDuration:0.2 animations:^{
                reloadArrowView_.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (shouldReload_ && ![[ModelManager shared] isInmobiShown]) {
        self.needsBuyAlert = YES;
        [self reload];
    }
}

#pragma mark - Reload data

- (void)reload
{
    [[ModelManager shared] fetchBidsWithDelegate:self];
}

//*

- (void)didReceiveNewBids
{
    datetimeLabel_.text = [NSString stringWithFormat:@"AS OF %@", [[[ModelManager shared] metals][0] bidDatetime]];
//    if (bReload) {
        [self.table reloadData];
//    }
//    else
//        bReload = YES;
    if(self.needsBuyAlert)
    {
        [[VersionManager shared] setDidBecomeActive:YES];
        [self showAdIfNeeded];
        self.needsBuyAlert = NO;
    }
}

- (void)didFailReceivingBidsError:(NSError *)error
{
    if ([error code] == ERInternetAbsenceErrorCode) {
        [self showInternetAbsenceAlertView];
    }
    else {
        [self didForbidReceiveBids];
    }
}

- (void)didForbidReceiveBids
{
    [[[ModelManager shared] settings] setCurrencyID:@"88"];
    [[ModelManager shared] synchronizeSettings];
    currencyLabel_.text = [[ModelManager shared] selectedCurrency].shortname;
    
    [self.table reloadData];
    
    if(self.needsBuyAlert)
    {
        [[VersionManager shared] setDidBecomeActive:YES];
        [self showAdIfNeeded];
        [[VersionManager shared] setDidBecomeActive:NO];
        self.needsBuyAlert = NO;
    }
}
//*/
#pragma mark - Memory

- (void)dealloc
{
    [reloadArrowView_ release];
    [reloadTextLabel_ release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    [super dealloc];
}

@end
