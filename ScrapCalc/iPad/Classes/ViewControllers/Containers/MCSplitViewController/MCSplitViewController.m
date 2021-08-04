//
//  MCSplitViewController.m
//  ScrapCalc
//
//  Created by Domovik on 31.07.13.
//
//

#import "MCSplitViewController.h"
#import "MCNavigationController.h"

#import "MCMetalsListViewController_iPad.h"
#import "MCMetalCalculatorViewController_iPad.h"

#import "MCClientsListViewController_iPad.h"
#import "MCClientDetailsViewController_iPad.h"

#import "MCPurchaseListViewController_iPad.h"
#import "MCPurchaseDetailsViewController_iPad.h"

#import "MCSettingsViewController_iPad.h"


@interface MCSplitViewController ()

@property (nonatomic, strong) MCNavigationController *metalsMasterNVC;
@property (nonatomic, strong) MCNavigationController *metalsDetailNVC;
@property (nonatomic, strong) MCNavigationController *clientsMasterNVC;
@property (nonatomic, strong) MCNavigationController *clientsDetailNVC;
@property (nonatomic, strong) MCNavigationController *purchasesMasterNVC;
@property (nonatomic, strong) MCNavigationController *purchasesDetailNVC;
@property (nonatomic, strong) MCNavigationController *settingsMasterNVC;
@property (nonatomic, strong) MCNavigationController *settingsDetailNVC;

@property (nonatomic, strong) MCMetalsListViewController_iPad *metalsListVC;
@property (nonatomic, strong) MCMetalCalculatorViewController_iPad *metalCalcVC;
@property (nonatomic, strong) MCClientsListViewController_iPad *clientsListVC;
@property (nonatomic, strong) MCClientDetailsViewController_iPad *clientDetailsVC;
@property (nonatomic, strong) MCPurchaseListViewController_iPad *purchasesListVC;
@property (nonatomic, strong) MCPurchaseDetailsViewController_iPad *purchaseDetailsVC;
@property (nonatomic, strong) MCSettingsViewController_iPad *settingsMainVC;
@property (nonatomic, strong) MCBaseViewController_iPad *settingsDetailVC;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImage *bgImagePortrait;
@property (nonatomic, strong) UIImage *bgImageLandscape;

@property (nonatomic, assign) BOOL increaseToolbarCenter;

@end


@implementation MCSplitViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _createBackground];
}


#pragma mark - Private

- (void)_createBackground
{
    self.backgroundImageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    
    self.bgImagePortrait = [UIImage imageNamed:@"background_portrait.png"];
    self.bgImageLandscape = [UIImage imageNamed:@"background_landscape.png"];
}

- (void)setupFramesForPortrait:(BOOL)isPortrait
{
    [super setupFramesForPortrait:isPortrait];
    self.backgroundImageView.image = isPortrait ? self.bgImagePortrait : self.bgImageLandscape;
}


#pragma mark - Override

- (void)update
{
    [super update];    
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [(MCNavigationController *)self.masterViewController setupForPortrait];
        [(MCNavigationController *)self.detailViewController setupForPortrait];
    }
    else {
        [(MCNavigationController *)self.masterViewController setupForLandscape];
        [(MCNavigationController *)self.detailViewController setupForLandscape];
    }
    
    self.toolbar.center = CGPointMake(self.view.center.x, self.toolbar.center.y);
    if (fabs(self.toolbar.frame.origin.y - IOS_20) > 1) {
        CGRect frame = self.toolbar.frame;
        frame.origin.y = IOS_20;
        self.toolbar.frame = frame;
    }
    
    if (self.selectedIndex == 3 && self.shouldPresentPurchaseScreen) {
        self.shouldPresentPurchaseScreen = NO;
        
        [self.settingsMasterNVC popToRootViewControllerAnimated:NO];
        [self.settingsMainVC pushPurchaseScreen];
    }
}

#pragma mark - MCToolbarViewDelegate

- (void)toolbarDidSelectItemAtIndex:(NSInteger)index
{
    [[VersionManager shared] verifyVersion];
    
    self.selectedIndex = index;
    self.showMasterOnRotateToPortrait = self.showOnlyMasterInLandscape = (index == MCTabSettings);
    
    MCNavigationController *master = [self masterForIndex:index];
    MCNavigationController *detail = [self detailForIndex:index];
    
    master.splitViewController = detail.splitViewController = self;
    
    self.masterViewController = master;
    self.detailViewController = detail;
    
    [self update];
}

- (MCNavigationController *)masterForIndex:(NSInteger)index
{
    switch (index)
    {
        case MCTabMetalList:
            return self.metalsMasterNVC;
        case MCTabClients:
            return self.clientsMasterNVC;
        case MCTabPurchases:
            return self.purchasesMasterNVC;
        case MCTabSettings:
            return self.settingsMasterNVC;
        default:
            return nil;
    }
}

- (MCNavigationController *)detailForIndex:(NSInteger)index
{
    switch (index)
    {
        case MCTabMetalList:
            return self.metalsDetailNVC;
        case MCTabClients:
            return self.clientsDetailNVC;
        case MCTabPurchases:
            return self.purchasesDetailNVC;
        case MCTabSettings:
            return self.settingsDetailNVC;
        default:
            return nil;
    }
}

#pragma mark - Navigation Controllers

- (MCNavigationController *)metalsMasterNVC
{
    if (_metalsMasterNVC == nil) {
        _metalsMasterNVC = [[MCNavigationController alloc] initWithRootViewController:self.metalsListVC];
    }
    return _metalsMasterNVC;
}

- (MCNavigationController *)metalsDetailNVC
{
    if (_metalsDetailNVC == nil) {
        _metalsDetailNVC = [[MCNavigationController alloc] initWithRootViewController:self.metalCalcVC];
    }
    return _metalsDetailNVC;
}

- (MCNavigationController *)clientsMasterNVC
{
    if (_clientsMasterNVC == nil) {
        _clientsMasterNVC = [[MCNavigationController alloc] initWithRootViewController:self.clientsListVC];
    }
    return _clientsMasterNVC;
}

- (MCNavigationController *)clientsDetailNVC
{
    if (_clientsDetailNVC == nil) {
        _clientsDetailNVC = [[MCNavigationController alloc] initWithRootViewController:self.clientDetailsVC];
    }
    return _clientsDetailNVC;
}

- (MCNavigationController *)purchasesMasterNVC
{
    if (_purchasesMasterNVC == nil) {
        _purchasesMasterNVC = [[MCNavigationController alloc] initWithRootViewController:self.purchasesListVC];
    }
    return _purchasesMasterNVC;
}

- (MCNavigationController *)purchasesDetailNVC
{
    if (_purchasesDetailNVC == nil) {
        _purchasesDetailNVC = [[MCNavigationController alloc] initWithRootViewController:self.purchaseDetailsVC];
    }
    return _purchasesDetailNVC;
}

- (MCNavigationController *)settingsMasterNVC
{
    if (_settingsMasterNVC == nil) {
        _settingsMasterNVC = [[MCNavigationController alloc] initWithRootViewController:self.settingsMainVC];
    }
    return _settingsMasterNVC;
}

- (MCNavigationController *)settingsDetailNVC
{
    if (_settingsDetailNVC == nil) {
        _settingsDetailNVC = [[MCNavigationController alloc] initWithRootViewController:self.settingsDetailVC];
    }
    return _settingsDetailNVC;
}


#pragma mark - View Controllers

#pragma mark Metals

- (MCMetalsListViewController_iPad *)metalsListVC
{
    if (_metalsListVC == nil) {
        [self _createMetalsBlock];
    }
    return _metalsListVC;
}

- (MCMetalCalculatorViewController_iPad *)metalCalcVC
{
    if (_metalCalcVC == nil) {
        [self _createMetalsBlock];
    }
    return _metalCalcVC;
}

- (void)_createMetalsBlock
{
    self.metalsListVC = [[MCMetalsListViewController_iPad new] autorelease];
    self.metalCalcVC = [[MCMetalCalculatorViewController_iPad new] autorelease];
    
    self.metalsListVC.delegate = self.metalCalcVC;
    self.metalCalcVC.delegate = self.metalsListVC;
}

#pragma mark Clients

- (MCClientsListViewController_iPad *)clientsListVC
{
    if (_clientsListVC == nil) {
        [self _createClientsBlock];
    }
    return _clientsListVC;
}

- (MCClientDetailsViewController_iPad *)clientDetailsVC
{
    if (_clientDetailsVC == nil) {
        [self _createClientsBlock];
    }
    return _clientDetailsVC;
}

- (void)_createClientsBlock
{
    self.clientsListVC = [[MCClientsListViewController_iPad new] autorelease];
    self.clientDetailsVC = [[MCClientDetailsViewController_iPad new] autorelease];
    self.clientsListVC.delegate = self.clientDetailsVC;
    self.clientDetailsVC.delegate = self.clientsListVC;
}

#pragma mark Purchases

- (MCPurchaseListViewController_iPad *)purchasesListVC
{
    if (_purchasesListVC == nil) {
        [self _createPurchasesBlock];
    }
    return _purchasesListVC;
}

- (MCPurchaseDetailsViewController_iPad *)purchaseDetailsVC
{
    if (_purchaseDetailsVC == nil) {
        [self _createPurchasesBlock];
    }
    return _purchaseDetailsVC;
}

- (void)_createPurchasesBlock
{
    self.purchasesListVC = [[MCPurchaseListViewController_iPad new] autorelease];
    self.purchaseDetailsVC = [[MCPurchaseDetailsViewController_iPad new] autorelease];
    self.purchasesListVC.delegate = self.purchaseDetailsVC;
    self.purchaseDetailsVC.delegate = self.purchasesListVC;
}

#pragma mark Settings

- (MCSettingsViewController_iPad *)settingsMainVC
{
    if (_settingsMainVC == nil) {
        [self _createSettingsBlock];
    }
    return _settingsMainVC;
}

- (MCBaseViewController_iPad *)settingsDetailVC
{
    if (_settingsDetailVC == nil) {
        [self _createSettingsBlock];
    }
    return _settingsDetailVC;
}

- (void)_createSettingsBlock
{
    self.settingsMainVC = [[MCSettingsViewController_iPad new] autorelease];
    self.settingsDetailVC = [[MCBaseViewController_iPad new] autorelease];
}


#pragma mark - Memory Management

- (void)dealloc
{
    [_metalsMasterNVC       release];
    [_metalsDetailNVC       release];
    [_clientsMasterNVC      release];
    [_clientsDetailNVC      release];
    [_purchasesMasterNVC    release];
    [_purchasesDetailNVC    release];
    [_settingsMasterNVC     release];
    [_settingsDetailNVC     release];
    
    self.metalsListVC       = nil;
    self.metalCalcVC        = nil;
    self.clientsListVC      = nil;
    self.clientDetailsVC    = nil;
    self.purchasesListVC    = nil;
    self.purchaseDetailsVC  = nil;
    self.settingsMainVC     = nil;
    self.settingsDetailVC   = nil;
    
    self.backgroundImageView = nil;
    self.toolbar = nil;    
    [super dealloc];
}


@end
