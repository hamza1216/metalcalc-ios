//
//  MCMetalsListViewController_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 30.07.13.
//
//

#import "MCMetalsListViewController_iPad.h"
#import "MCMetalCalculatorViewController_iPad.h"
#import "MCMetalCell_iPad.h"


@interface MCMetalsListViewController_iPad ()
{
    NSInteger _selectedMetalID;
    BOOL _shouldReload;
    UIImageView *reloadArrowView_;
    UILabel *reloadTextLabel_;
}

@property (nonatomic, assign) BOOL needsBuyAlert;

@end


@implementation MCMetalsListViewController_iPad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _shouldReload = NO;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.needsBuyAlert = YES;
    if ([[[ModelManager shared] onMetals] count]) {
        _selectedMetalID = [[[[ModelManager shared] onMetals][0] metalID] integerValue];
    }
    else {
        _selectedMetalID = 0;
    }
    reloadArrowView_ = [[UIImageView alloc] initWithFrame:CGRectMake(20, -42, 32, 40)];
    reloadArrowView_.image = [UIImage imageNamed:@"pulldown_icon.png"];
    [self.table addSubview:reloadArrowView_];
    [reloadArrowView_ setHidden:YES];
    
    reloadTextLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(60, -42, 240, 40)];
    reloadTextLabel_.backgroundColor = [UIColor clearColor];
    reloadTextLabel_.textColor = [UIColor whiteColor];
    reloadTextLabel_.shadowColor = [UIColor blackColor];
    reloadTextLabel_.shadowOffset = CGSizeMake(0, 1);
    reloadTextLabel_.text = [PULLDOWN_TEXT_PULL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    reloadTextLabel_.font = FONT_MYRIAD_BOLD(16);
    [self.table addSubview:reloadTextLabel_];
    [reloadTextLabel_ setHidden:YES];
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setRightToolBarButtonHidden:YES];
    
    [[ModelManager shared] setDelegate:self];
    [self setLeftToolBarButtonHidden:YES];
    [self didReceiveNewBids];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[ModelManager shared] setDelegate:nil];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup for Interface Orientation

- (void)setupForPortrait
{
    [super setupForPortrait];
    
    self.pulldownView.hidden = YES;
    reloadTextLabel_.hidden = NO;
    reloadArrowView_.hidden = NO;
    self.table.frame = TABLE_FRAME_PORTRAIT;
    [self.table reloadData];
}

- (void)setupForLandscape
{
    [super setupForLandscape];
    
    self.pulldownView.hidden = NO;
    reloadTextLabel_.hidden = YES;
    reloadArrowView_.hidden = YES;
    self.table.frame = TABLE_FRAME_LANDSCAPE;
    [self.table reloadData];
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_selectedMetalID != 0) {
        BOOL found = NO;
        for (Metal *metal in [[ModelManager shared] onMetals]) {
            if (metal.metalID.integerValue == _selectedMetalID) {
                found = YES;
                break;
            }
        }
        
        if (!found) {
            
            if ([[[ModelManager shared] onMetals] count] < 1) {
                _selectedMetalID = 0;
                [self.delegate metalsListDidSelectDiamond];
            }
            else {                
                Metal *metal = nil;
                
                for (NSInteger i = 0; i < [[[ModelManager shared] onMetals] count] - 1; ++i) {
                    Metal *prevMetal = [[ModelManager shared] onMetals][i];
                    Metal *nextMetal = [[ModelManager shared] onMetals][i+1];
                    
                    if (prevMetal.metalID.integerValue < _selectedMetalID && nextMetal.metalID.integerValue > _selectedMetalID) {
                        metal = prevMetal;
                        break;
                    }
                }
                
                if (metal == nil) {
                    metal = [[ModelManager shared] onMetals][0];
                }
                _selectedMetalID = metal.metalID.integerValue;
                [self.delegate metalsListDidSelectMetal:metal];
            }
        }
    }
    
    return [[[ModelManager shared] onMetals] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const cellID = @"MCMetalCell_iPadID";
    MCMetalCell_iPad *cell = (MCMetalCell_iPad *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MCMetalCell_iPad" owner:self options:nil][0];
    }
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    BOOL isSelected;
    if (indexPath.row == [[[ModelManager shared] onMetals] count]) {
        isSelected = (_selectedMetalID == 0);
    }
    else {
        isSelected = (_selectedMetalID == [[[[ModelManager shared] onMetals][indexPath.row] metalID] integerValue]);
    }
    
    MCMetalCellType type;
    if (isPortrait) {
        type = (isSelected ? MCMetalCellTypeSelectedLong : MCMetalCellTypeNormalLong);
    }
    else {
        type = (isSelected ? MCMetalCellTypeSelectedShort : MCMetalCellTypeNormalShort);
    }
    
    if ([[[ModelManager shared] onMetals] count] == indexPath.row) {
        [cell setupWithType:type andMetal:nil];
    }
    else {
        Metal *metal = [[ModelManager shared] onMetals][indexPath.row];
        [cell setupWithType:type andMetal:metal];    
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[ModelManager shared] onMetals] count] == indexPath.row) {
        _selectedMetalID = 0;
        [self.delegate metalsListDidSelectDiamond];
    }
    else {
        Metal *metal = [[ModelManager shared] onMetals][indexPath.row];
        _selectedMetalID = metal.metalID.integerValue;
        [self.delegate metalsListDidSelectMetal:metal];
    }
    
    [self.table reloadData];
    [self.splitViewController pushDetailAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MCMetallCelliPad_Height;
}

#pragma mark - Pulldown

- (void)setPulldownHidden:(BOOL)isHidden
{
    self.pulldownView.hidden = isHidden;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_shouldReload != (scrollView.contentOffset.y < PULLDOWN_REFRESH_OFFSET)) {
        _shouldReload = !_shouldReload;
        if (_shouldReload) {
            reloadTextLabel_.text = [PULLDOWN_TEXT_RELEASE stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.pulldownTextLabel.text = PULLDOWN_TEXT_RELEASE;
            [UIView animateWithDuration:0.3 animations:^{
                reloadArrowView_.transform = CGAffineTransformMakeRotation(M_PI);
                self.pulldownArrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
        else {
            reloadTextLabel_.text = [PULLDOWN_TEXT_PULL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            self.pulldownTextLabel.text = PULLDOWN_TEXT_PULL;
            [UIView animateWithDuration:0.3 animations:^{
                reloadArrowView_.transform = CGAffineTransformIdentity;
                self.pulldownArrowImageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (_shouldReload && ![[ModelManager shared] isInmobiShown]) {
        self.needsBuyAlert = YES;
        [self reload];
    }
}

#pragma mark - Reload data

- (void)reload
{
    [[ModelManager shared] fetchBidsWithDelegate:self];
}

- (void)didReceiveNewBids
{
    [self.table reloadData];
    
    if(self.needsBuyAlert)
    {
        [[VersionManager shared] setDidBecomeActive:YES];
        [self showAdIfNeeded];
        self.needsBuyAlert = NO;
    }
    
    
    if (_selectedMetalID != 0) {
        Metal *metal = [[ModelManager shared] metalForID:_selectedMetalID];
        [self.delegate metalsListDidSelectMetal:metal];
    }
    else {
        [self.delegate metalsListDidSelectDiamond];
    }
    
}

- (void)didFailReceivingBidsError:(NSError *)error
{
    if([error code] == ERInternetAbsenceErrorCode)
    {
        [self showInternetAbsenceAlertView];
    }
    else
    {
        [self didForbidReceiveBids];
    }
}

- (void)didForbidReceiveBids
{
    [self.table reloadData];
    
    if(self.needsBuyAlert)
    {
        [[VersionManager shared] setDidBecomeActive:YES];
        [self showAdIfNeeded];
        [[VersionManager shared] setDidBecomeActive:NO];
        self.needsBuyAlert = NO;
    }
}


#pragma mark - MCMetalCalc Delegate

- (void)metalCalcDidChangePriceManually
{
    [self.table reloadData];
}

@end
