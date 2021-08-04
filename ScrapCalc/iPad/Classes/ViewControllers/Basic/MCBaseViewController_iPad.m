//
//  MCBaseViewController_iPad.m
//  ScrapCalc
//
//  Created by Domovik on 30.07.13.
//
//

#import "AppDelegate_iPad.h"
#import "MCBaseViewController_iPad.h"
#import "MCSettingsViewController_iPad.h"
#import "MCSplitViewController.h"

#import "IMBanner.h"
#define CONTAINER_BACKGROUND    @"calculator_background.png"


@interface MCBaseViewController_iPad ()

@property (nonatomic, strong) UIImageView *containerBackground;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *printButton;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end


@implementation MCBaseViewController_iPad


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = 0;
    self.containerView.backgroundColor = [UIColor clearColor];
    
    [self _createBackground];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.splitViewController update];
    
    NSString *class = NSStringFromClass(self.class);
    if ([class isEqualToString:@"MCMetalsListViewController_iPad"])
    {
        self.screenName = METALS_LIST_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCClientsListViewController_iPad"])
    {
        self.screenName = CLIENTS_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCClientDetailsViewController_iPad"])
    {
        self.screenName = CLIENT_DETAILS_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCClientEditViewController_iPad"])
    {
        self.screenName = EDIT_CLIENT_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCPurchaseListViewController_iPad"])
    {
        self.screenName = PURCHASES_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCPurchaseDetailsViewController_iPad"])
    {
        self.screenName = PURCHASE_DETAILS_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCSettingsViewController_iPad"])
    {
        self.screenName = SETTINGS_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCHomeScreenViewController_iPad"])
    {
        self.screenName = SETTINGS_HOME_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCCustomAssayViewController_iPad"])
    {
        self.screenName = CUSTOM_ASSAY_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCPushNotificationsViewController_iPad"])
    {
        self.screenName = PUSH_NOTFICATIONS_SCREEN_NAME;
    }
    else if ([class isEqualToString:@"MCPurchaseSettingsViewController_iPad"])
    {
        self.screenName = INAPP_PURCHASE_SCREEN_NAME;
    }
    
    [[VersionManager shared] setDidBecomeActive:NO];
}

- (void)setTrackedViewName:(NSString *)trackedViewName
{
    [super setScreenName:trackedViewName];
    NSLog(@"TRACKED VIEW NAME: %@", trackedViewName);
}

- (MCSplitViewController *)splitViewController
{
    return self.navigationViewController.splitViewController;
}

- (void)onClickBtnPrint:(UIButton *)sender
{
    
}

#pragma mark - BurstlyInterstitial


- (void)showAdIfNeeded
{
    if ([[VersionManager shared] needsAd]) {
        [self showInterstitialAd];
    }
}

- (void)showInterstitialAd
{
    if([[ModelManager shared] isInmobiShown])     return;
    
    adsInMobi = [[IMInterstitial alloc] initWithAppId:INMOBI_APPID];
    [adsInMobi setDelegate:self];
    [adsInMobi loadInterstitial];
    
    [self displayActivityIndicator:YES];
}

- (void)displayActivityIndicator:(BOOL)doDisplay
{
    if (doDisplay && [self activityIndicator] == nil)
    {
        [self setActivityIndicator:[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease]];
        [[self activityIndicator] setCenter:CGPointMake([[self view] frame].size.width / 2.0, [[self view] frame].size.height / 1.7)];
        [[self activityIndicator] startAnimating];
        [[self view] addSubview:[self activityIndicator]];
    }
    else if (!doDisplay && [self activityIndicator] != nil)
    {
        [[self activityIndicator] removeFromSuperview];
        [self setActivityIndicator:nil];
    }
}

#pragma mark IMMOBI delegate
#pragma mark Interstitial Request Notifications

/**
 * Sent when an interstitial ad request succeeded.
 * @param ad The IMInterstitial instance which finished loading.
 */
- (void)interstitialDidReceiveAd:(NSObject *)ad
{
    if([ad isKindOfClass:[IMInterstitial class]])   //inmobi
    {
        NSLog(@"An Interstitial Ad Request was successfully sent");
        if (adsInMobi.state == kIMInterstitialStateReady) {
            [adsInMobi presentInterstitialAnimated:YES];
        }
    }
    else    //admob
    {
        if(adMob.isReady)
        {
            [adMob presentFromRootViewController:self];
        }
    }
}

/**
 * Sent when an interstitial ad request failed
 * @param ad The IMInterstitial instance which failed to load.
 * @param error The IMError associated with the failure.
 */
- (void)interstitial:(NSObject *)ad
didFailToReceiveAdWithError:(IMError *)error
{
    NSLog(@"An Interstitial Ad Request was failed");
    NSLog(@"%@", error);
    
    if([ad isKindOfClass:[IMInterstitial class]])   //inmobi
    {
        //init admob ads
        adMob = [[GADInterstitial alloc] init];
        adMob.adUnitID = ADMOB_UNITID;
        adMob.delegate = self;
        [adMob loadRequest:[GADRequest request]];
    }
    else
    {
        [[ModelManager shared] setIsInmobiShown:NO];
        [self displayActivityIndicator:NO];
        [self showBuyNowAlert];
    }    
}

#pragma mark Interstitial Interaction Notifications

/**
 * Sent just before presenting an interstitial.  After this method finishes the
 * interstitial will animate onto the screen.  Use this opportunity to stop
 * animations and save the state of your application in case the user leaves
 * while the interstitial is on screen (e.g. to visit the App Store from a link
 * on the interstitial).
 * @param ad The IMInterstitial instance which will present the screen.
 */
- (void)interstitialWillPresentScreen:(IMInterstitial *)ad
{
    [[ModelManager shared] setIsInmobiShown:YES];
    [self displayActivityIndicator:NO];
}

/**
 * Sent before the interstitial is to be animated off the screen.
 * @param ad The IMInterstitial instance which will dismiss the screen.
 */
- (void)interstitialWillDismissScreen:(IMInterstitial *)ad
{
    [[ModelManager shared] setIsInmobiShown:NO];
    [self displayActivityIndicator:NO];
    [self showBuyNowAlert];
}

/**
 * Called when the interstitial failed to display.
 * This should normally occur if the state != kIMInterstitialStateReady.
 * @param ad The IMInterstitial instance responsible for this error.
 * @param error The IMError associated with this failure.
 */
- (void)interstitial:(IMInterstitial *)ad didFailToPresentScreenWithError:(IMError *)error
{
    NSLog(@"%@", [error description]);
    [[ModelManager shared] setIsInmobiShown:YES];
    [[ModelManager shared] setIsInmobiShown:NO];
    [self showBuyNowAlert];
}

#pragma mark - Background

- (void)_createBackground
{
    self.containerBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:CONTAINER_BACKGROUND]] autorelease];
    self.containerBackground.autoresizingMask = 0;
    if (self.needsBackground) {
        [self.view insertSubview:self.containerBackground atIndex:0];
    }
}

- (BOOL)needsBackground
{
    return NO;
}


#pragma mark - Back button

- (void)addBackButton
{
    if (self.backButton == nil ){
        [self _createBackButton];
    }
    if(self.needsMoveBackButtonToTheContainer)
    {
        [self.containerView addSubview:self.backButton];
    }
    else
    {
        [self.view addSubview:self.backButton];
    }
    [self _setupContainerView];
}

- (void)removeBackButton
{
    [self.backButton removeFromSuperview];
    self.backButton = nil;
    [self _setupContainerView];
}

- (void)_createBackButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    if(self.needsMoveBackButtonToTheContainer)
        button.frame = CGRectMake(16, 15, 101, 60);
    else
        button.frame = CGRectMake(55, 58, 101, 60);
    
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_norm.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_sel.png"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_sel.png"] forState:UIControlStateSelected];
    
    [button setTitle:@"  Back" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:25];
    button.titleLabel.textColor = [UIColor whiteColor];
    
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton = button;
}

- (IBAction)backAction:(id)sender
{
    if (self.navigationViewController.viewControllers.count > 1) {
        [self.navigationViewController popViewControllerAnimated:YES];
    }
    else {
        [self.splitViewController popToMasterAnimated:YES];
    }
}

#pragma mark - Print button

- (void)addPrintButton
{
    if (self.printButton == nil ){
        [self _createPrintButton];
    }
    if(self.needsMoveBackButtonToTheContainer)
    {
        [self.containerView addSubview:self.printButton];
    }
    else
    {
        [self.view addSubview:self.printButton];
    }
    [self _setupContainerView];
}

- (void)removePrintButton
{
    [self.printButton removeFromSuperview];
    self.printButton = nil;
    [self _setupContainerView];
}

- (void)_createPrintButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(self.needsMovePrintButtonToTheContainer)
        button.frame = CGRectMake(650, 15, 60, 60);
    else
        button.frame = CGRectMake(650, 58, 60, 60);
    
    [button setBackgroundImage:[UIImage imageNamed:@"purchase_print.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onClickBtnPrint:) forControlEvents:UIControlEventTouchUpInside];
    self.printButton = button;
}

#pragma mark - setters

-(void)setNeedsMoveBackButtonToTheContainer:(BOOL)needsMoveBackButtonToTheContainer
{
    _needsMoveBackButtonToTheContainer = needsMoveBackButtonToTheContainer;
    if(self.backButton)
    {
        [[self backButton] removeFromSuperview];
        self.backButton = nil;
        [self addBackButton];
        [self _setupContainerView];
    }    
}


#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self _setupBackgroundForOrientation:toInterfaceOrientation];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self setupForPortrait];
    }
    else {
        [self setupForLandscape];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

- (void)_setupBackgroundForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.containerBackground.frame = DETAIL_VC_FRAME_PORTRAIT;
    }
    else {
        self.containerBackground.frame = DETAIL_VC_FRAME_LANDSCAPE;
    }
    [self _setupContainerView];
}

- (void)_setupContainerView
{
    CGFloat d = 7;
    CGRect frame = self.containerBackground.frame;
    frame.origin.x += d;
    frame.origin.y += d + (self.backButton&&!self.needsMoveBackButtonToTheContainer?self.backButton.frame.size.height + 20.0 : 0);
    frame.size.width -= 2 * d;
    frame.size.height -= 2 * d + (self.backButton&&!self.needsMoveBackButtonToTheContainer?self.backButton.frame.size.height + 20.0 : 0);
    
    self.containerView.frame = frame;
    self.containerView.autoresizingMask = 0;
}

- (void)setupForPortrait
{
//    if (fabs(self.view.frame.size.height - self.navigationViewController.view.frame.size.height)  try this later
}

- (void)setupForLandscape
{
}

#pragma mark - Left Toolbar button

-(void)setLeftToolBarButtonHidden:(BOOL)hidden
{
    UIButton *button = [[[self splitViewController] toolbar] leftButton];
    [button setHidden:hidden];
    if(!hidden)
    {
        UIImage *bgImage = [self imageForLeftToolBarButton];
        button.frame = [self imageRectForLefToolBarButton];
        [button setBackgroundImage:bgImage forState:UIControlStateNormal];
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(actionForLeftButtonOnTheToolBar) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)actionForLeftButtonOnTheToolBar
{    
}

-(void)setRightToolBarButtonHidden:(BOOL)hidden
{
    UIButton *button = [[[self splitViewController] toolbar] rightButton];
    [button setHidden:hidden];
    if(!hidden)
    {
        UIImage *bgImage = [self imageForRightToolBarButton];
        button.frame = [self imageRectForRightToolBarButton];
        [button setBackgroundImage:bgImage forState:UIControlStateNormal];
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(actionForRightButtonOnTheToolBar) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)actionForRightButtonOnTheToolBar
{
}

- (BOOL)needsLeftToolBarButton
{
    return NO;
}

- (UIImage *)imageForLeftToolBarButton
{
    return [UIImage imageNamed:@""];
}

- (CGRect)imageRectForLefToolBarButton
{
    return CGRectMake(0, 0, 0, 0);
}

- (UIImage *)imageForRightToolBarButton
{
    return [UIImage imageNamed:@""];
}

- (CGRect)imageRectForRightToolBarButton
{
    return CGRectMake(0, 0, 0, 0);
}

#pragma mark - Alert

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    [[[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message okTitle:(NSString *)ok cancelTitle:(NSString *)cancel delegate:(id<UIAlertViewDelegate>)delegate
{
    [[[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancel otherButtonTitles:ok,nil] autorelease] performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

static BOOL isBuyAlertShown = NO;

- (void)showBuyNowAlert
{
    if(isBuyAlertShown)
        return;
    
    if([VersionManager shared].currentVersion == VersionExpired
       &&  self.splitViewController.selectedIndex != 3){
        [self showAlertWithTitle:@"" andMessage:BUY_PRO_MESSAGE okTitle:@"Buy Now" cancelTitle:nil delegate:self];
        
        AppDelegate_iPad* appDelegate_iPad = (AppDelegate_iPad*)[UIApplication sharedApplication].delegate;
        for(UIButton* button in appDelegate_iPad.toolbarView.tabBar.buttons){
            [button setEnabled:NO];                                             //disable when expire
        }
        [appDelegate_iPad.toolbarView selectTabIndex:3];
        
        isBuyAlertShown = YES;
        return;
    }
    else
    {
        isBuyAlertShown = YES;
        [self showAlertWithTitle:@"" andMessage:BUY_PRO_MESSAGE okTitle:@"Buy Now" cancelTitle:@"Cancel" delegate:self];
    }
}

- (void)showInternetAbsenceAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"The Internet connection appears to be offline."
                                                   delegate:nil
                                          cancelButtonTitle:@"ОК"
                                          otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{  
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        AppDelegate_iPad* appDelegate = (AppDelegate_iPad *)[UIApplication sharedApplication].delegate;
        [appDelegate.toolbarView selectTabIndex:3];
        appDelegate.splitViewController.shouldPresentPurchaseScreen = YES;
        [appDelegate.splitViewController.toolbar selectTabIndex:3];
    }
}

#pragma mark - Loading

- (void)showLoading
{
    [APP_DELEGATE showLoadingIndicator];
}

- (void)hideLoading
{
    [APP_DELEGATE hideLoadingIndicator];
}

#pragma mark - Memory

- (void)dealloc
{
    self.containerBackground = nil;
    self.backButton = nil;
    
    self.activityIndicator = nil;
   
    [super dealloc];
}

@end
